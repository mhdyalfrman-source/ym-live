'use strict';
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const mysql = require('mysql2/promise');
const admin = require('firebase-admin');
const serviceAccount = require(path.join(__dirname, 'private', 'firebase-service-account.json'));
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id,
  });
}

// Load .env without requiring dotenv.
const envFile = path.join(__dirname, '.env');
if (fs.existsSync(envFile)) {
  for (const raw of fs.readFileSync(envFile, 'utf8').split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const pos = line.indexOf('=');
    if (pos < 1) continue;
    const key = line.slice(0, pos).trim();
    let value = line.slice(pos + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) value = value.slice(1, -1);
    process.env[key] = value;
  }
}

const required = ['DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DB_NAME', 'ITS_ACCESS_HASH', 'ITS_TOKEN_SECRET'];
const missing = required.filter((k) => !process.env[k]);
if (missing.length) {
  console.error(`Missing .env values: ${missing.join(', ')}`);
  process.exit(1);
}
const pool = mysql.createPool({
  host: process.env.DB_HOST, port: Number(process.env.DB_PORT || 3306),
  database: process.env.DB_NAME, waitForConnections: true,
  connectionLimit: 5, queueLimit: 0, charset: 'utf8mb4'
});
const uploadsDir = path.join(__dirname, 'uploads');
fs.mkdirSync(uploadsDir, { recursive: true, mode: 0o750 });
const app = express();
app.disable('x-powered-by');
app.set('trust proxy', 1);
app.use(helmet());
app.use(express.json({ limit: '16kb' }));
app.use('/api', rateLimit({ windowMs: 15 * 60 * 1000, max: 1000, standardHeaders: true, legacyHeaders: false }));
app.use(express.static(path.join(__dirname, 'public')));
app.use('/media', express.static(uploadsDir, { fallthrough: false, maxAge: '7d', immutable: true }));
const TOKEN_SECRET = process.env.ITS_TOKEN_SECRET;
const ACCESS_HASH = process.env.ITS_ACCESS_HASH.toLowerCase();

function sha256(s) { return crypto.createHash('sha256').update(s, 'utf8').digest('hex'); }
function equalHex(a, b) {
  if (!/^[a-f0-9]{64}$/i.test(a) || !/^[a-f0-9]{64}$/i.test(b)) return false;
  return crypto.timingSafeEqual(Buffer.from(a, 'hex'), Buffer.from(b, 'hex'));
}
function makeToken(data) {
  const body = Buffer.from(JSON.stringify(data)).toString('base64url');
  const sig = crypto.createHmac('sha256', TOKEN_SECRET).update(body).digest('base64url');
  return `${body}.${sig}`;
}
function readToken(token) {
  if (typeof token !== 'string' || token.length > 2048) return null;
  const parts = token.split('.');
  if (parts.length !== 2) return null;
  const expected = crypto.createHmac('sha256', TOKEN_SECRET).update(parts[0]).digest();
  let actual;
  try { actual = Buffer.from(parts[1], 'base64url'); } catch { return null; }
  if (actual.length !== expected.length || !crypto.timingSafeEqual(actual, expected)) return null;
  try {
    const p = JSON.parse(Buffer.from(parts[0], 'base64url').toString('utf8'));
    if (!p || !['sender', 'receiver'].includes(p.role) || !/^[a-f0-9]{64}$/.test(p.installationId) || !Number.isInteger(p.exp) || p.exp <= Math.floor(Date.now() / 1000)) return null;
    return p;
  } catch { return null; }
}
async function auth(req, res, next) {
  try {
    const h = req.headers.authorization || '';
    const p = readToken(h.startsWith('Bearer ') ? h.slice(7) : '');
    if (!p) return res.status(401).json({ success: false, error: 'unauthorized' });
    const [rows] = await pool.execute(
      'SELECT slot FROM authorized_devices WHERE slot = ? AND installation_id = ? AND active = 1 LIMIT 1',
      [p.role, p.installationId]
    );
    if (!rows.length) return res.status(403).json({ success: false, error: 'device_not_authorized' });
    req.its = p;
    next();
  } catch (e) { next(e); }
}

app.get('/health', (_req, res) => res.json({ success: true, app: 'Nabd Qalbi API', status: 'online' }));
app.get('/api/health', (_req, res) => res.json({ success: true, status: 'online' }));

const DEFAULT_APP_CONFIG = {
  senderName: '♛ 𝐈𝐓𝐒 : MINE ♛',
  receiverName: '#¹♥ 𝐈𝐓𝐒 : MY ♕︎.',
  openingMessage: 'احبج',
  morningGreeting: 'صباح الخير يحليوه ❤️',
  musicLabel: '11:11 💍',
  latestVersion: '1.2.0',
  downloadUrl: ''
};
const CONFIG_KEY_MAP = {
  senderName: 'sender_name', receiverName: 'receiver_name', openingMessage: 'opening_message',
  morningGreeting: 'morning_greeting', musicLabel: 'music_label', latestVersion: 'latest_version', downloadUrl: 'download_url'
};

async function readAppConfig() {
  const config = { ...DEFAULT_APP_CONFIG };
  try {
    const [rows] = await pool.query('SELECT setting_key, setting_value FROM its_app_settings');
    for (const row of rows) {
      const key = Object.keys(CONFIG_KEY_MAP).find((k) => CONFIG_KEY_MAP[k] === row.setting_key);
      if (key) config[key] = row.setting_value;
    }
  } catch (e) {
    if (e.code !== 'ER_NO_SUCH_TABLE') throw e;
  }
  return config;
}

function adminAuthorized(req) {
  const expected = process.env.ITS_ADMIN_KEY || '';
  const supplied = String(req.headers['x-admin-key'] || '');
  if (!expected || !supplied) return false;
  const a = Buffer.from(expected);
  const b = Buffer.from(supplied);
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

app.get('/api/app-config', async (_req, res, next) => {
  try { res.json({ success: true, config: await readAppConfig() }); }
  catch (e) { next(e); }
});

app.post('/api/admin/config', async (req, res, next) => {
  if (!adminAuthorized(req)) return res.status(403).json({ success: false, error: 'admin_forbidden' });
  const values = req.body && typeof req.body === 'object' ? req.body : {};
  const allowed = Object.keys(CONFIG_KEY_MAP);
  try {
    for (const key of allowed) {
      if (values[key] === undefined) continue;
      if (typeof values[key] !== 'string' || values[key].length > 300) {
        return res.status(400).json({ success: false, error: 'invalid_config_value', key });
      }
      if (key === 'downloadUrl' && values[key] && !/^https:\/\//i.test(values[key])) {
        return res.status(400).json({ success: false, error: 'download_url_must_be_https' });
      }
      await pool.execute(
        'INSERT INTO its_app_settings (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)',
        [CONFIG_KEY_MAP[key], values[key]]
      );
    }
    res.json({ success: true, config: await readAppConfig() });
  } catch (e) { next(e); }
});

const MEDIA_TYPES = {
  'image/jpeg': { ext: 'jpg', kind: 'image' }, 'image/png': { ext: 'png', kind: 'image' }, 'image/webp': { ext: 'webp', kind: 'image' },
  'video/mp4': { ext: 'mp4', kind: 'video' }, 'video/quicktime': { ext: 'mov', kind: 'video' },
  'audio/mpeg': { ext: 'mp3', kind: 'audio' }, 'audio/mp4': { ext: 'm4a', kind: 'audio' },
  'audio/aac': { ext: 'aac', kind: 'audio' }, 'audio/wav': { ext: 'wav', kind: 'audio' }, 'audio/ogg': { ext: 'ogg', kind: 'audio' }
};
app.post('/api/media', auth, express.raw({ type: Object.keys(MEDIA_TYPES), limit: '64mb' }), async (req, res, next) => {
  if (req.its.role !== 'sender') return res.status(403).json({ success: false, error: 'sender_only' });
  const mime = String(req.headers['content-type'] || '').split(';')[0].toLowerCase();
  const media = MEDIA_TYPES[mime];
  if (!media || !Buffer.isBuffer(req.body) || req.body.length === 0) {
    return res.status(400).json({ success: false, error: 'unsupported_or_empty_media' });
  }
  try {
    const id = crypto.randomUUID();
    const filename = `${id}.${media.ext}`;
    await fs.promises.writeFile(path.join(uploadsDir, filename), req.body, { flag: 'wx', mode: 0o640 });
    res.status(201).json({ success: true, kind: media.kind, url: `${req.protocol}://${req.get('host')}/media/${filename}` });
  } catch (e) { next(e); }
});

// Each role keeps one active slot; a new install replaces the old ID without discarding chat history.
app.post('/api/login', rateLimit({ windowMs: 15 * 60 * 1000, max: 10, standardHeaders: true, legacyHeaders: false }), async (req, res, next) => {
  const { passphrase, role, installationId } = req.body || {};
  if (typeof passphrase !== 'string' || !['sender', 'receiver'].includes(role) || typeof installationId !== 'string' || !/^[a-f0-9]{64}$/.test(installationId)) {
    return res.status(400).json({ success: false, error: 'invalid_request' });
  }
  if (!equalHex(sha256(passphrase), ACCESS_HASH)) return res.status(401).json({ success: false, error: 'wrong_passphrase' });
  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();
    const [slots] = await conn.execute('SELECT slot, installation_id, active FROM authorized_devices WHERE slot = ? FOR UPDATE', [role]);
    const slot = slots[0];
    if (slot) {
      // Allow a new installation to take over this role while preserving the existing chat history.
      const previousInstallationId = slot.installation_id;
      if (previousInstallationId && previousInstallationId !== installationId) {
        const uidColumn = role === 'sender' ? 'sender_uid' : 'receiver_uid';
        await conn.execute(`UPDATE pairs SET ${uidColumn} = ? WHERE ${uidColumn} = ?`, [installationId, previousInstallationId]);
        await conn.execute('UPDATE device_tokens SET firebase_uid = ? WHERE firebase_uid = ?', [installationId, previousInstallationId]);
      }
      await conn.execute('UPDATE authorized_devices SET firebase_uid = NULL, installation_id = ?, active = 1 WHERE slot = ?', [installationId, role]);
    } else {
      await conn.execute('INSERT INTO authorized_devices (slot, firebase_uid, installation_id, active) VALUES (?, NULL, ?, 1)', [role, installationId]);
    }
    const [all] = await conn.execute('SELECT slot, installation_id FROM authorized_devices WHERE active = 1 AND installation_id IS NOT NULL');
    const sender = all.find((r) => r.slot === 'sender');
    const receiver = all.find((r) => r.slot === 'receiver');
    const paired = Boolean(sender && receiver);
    if (paired) await conn.execute('INSERT IGNORE INTO pairs (sender_uid, receiver_uid) VALUES (?, ?)', [sender.installation_id, receiver.installation_id]);
    await conn.commit();
    const token = makeToken({ installationId, role, exp: Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60 });
    res.json({ success: true, token, role, paired });
  } catch (e) {
    if (conn) await conn.rollback().catch(() => {});
    next(e);
  } finally { if (conn) conn.release(); }
});


app.post('/api/device-token', auth, async (req, res, next) => {
  const token = typeof req.body?.token === 'string' ? req.body.token.trim() : '';
  if (token.length < 20 || token.length > 512)
    return res.status(400).json({success:false,error:'invalid_token'});
  try {
    await pool.execute(
      'INSERT INTO device_tokens (firebase_uid, token) VALUES (?, ?) ON DUPLICATE KEY UPDATE firebase_uid = VALUES(firebase_uid)',
      [req.its.installationId, token]
    );
    res.json({success:true});
  } catch(e) { next(e); }
});

app.get('/api/status', auth, async (req, res, next) => {
  try {
    const uid = req.its.installationId;
    const [rows] = await pool.execute('SELECT id FROM pairs WHERE sender_uid = ? OR receiver_uid = ? LIMIT 1', [uid, uid]);
    res.json({ success: true, role: req.its.role, paired: rows.length > 0, server: 'online' });
  } catch (e) { next(e); }
});

app.get('/api/messages', auth, async (req, res, next) => {
  try {
    const after = Math.max(0, Number.parseInt(String(req.query.after || '0'), 10) || 0);
    const uid = req.its.installationId;
    const [pairs] = await pool.execute('SELECT id FROM pairs WHERE sender_uid = ? OR receiver_uid = ? LIMIT 1', [uid, uid]);
    if (!pairs.length) return res.json({ success: true, paired: false, messages: [] });
    const [rows] = await pool.execute(
      'SELECT id, sender_uid, body, created_at FROM messages WHERE pair_id = ? AND id > ? ORDER BY id ASC LIMIT 100',
      [pairs[0].id, after]
    );
    res.json({ success: true, paired: true, messages: rows.map((r) => ({ id: r.id, senderUid: r.sender_uid, body: r.body, createdAt: r.created_at })) });
  } catch (e) { next(e); }
});

app.post('/api/messages', auth, async (req, res, next) => {
  if (req.its.role !== 'sender') return res.status(403).json({ success: false, error: 'sender_only' });
  const body = typeof req.body?.body === 'string' ? req.body.body.trim() : '';
  if (!body || body.length > 2000) return res.status(400).json({ success: false, error: 'message_must_be_1_to_2000_characters' });
  try {
    const [pairs] = await pool.execute('SELECT id FROM pairs WHERE sender_uid = ? LIMIT 1', [req.its.installationId]);
    if (!pairs.length) return res.status(409).json({ success: false, error: 'receiver_not_connected' });
    const [result] = await pool.execute('INSERT INTO messages (pair_id, sender_uid, body) VALUES (?, ?, ?)', [pairs[0].id, req.its.installationId, body]);
    
try {
  const [r] = await pool.execute('SELECT receiver_uid FROM pairs WHERE id = ? LIMIT 1',[pairs[0].id]);
  if (r.length) {
    const [t] = await pool.execute('SELECT token FROM device_tokens WHERE firebase_uid = ?',[r[0].receiver_uid]);
    if (t.length) await admin.messaging().sendEachForMulticast({
      tokens:t.map(x=>x.token),
      notification:{title:'رسالة جديدة',body:'وصلتك رسالة جديدة'},
      data:{type:'message',messageId:String(result.insertId)},
      android:{priority:'high'}
    });
  }
} catch(e) { console.error('FCM:',e.message); }

    res.status(201).json({ success: true, id: result.insertId });
  } catch (e) { next(e); }
});


// Daily greeting scheduler: Iraq time, once per pair per calendar day.
const iraqClock = new Intl.DateTimeFormat('en-GB', {
  timeZone: 'Asia/Baghdad', year: 'numeric', month: '2-digit', day: '2-digit',
  hour: '2-digit', minute: '2-digit', hourCycle: 'h23'
});
let greetingSchedulerReady = false;
async function runDailyGreeting() {
  if (!greetingSchedulerReady) return;
  const parts = Object.fromEntries(iraqClock.formatToParts(new Date())
    .filter((p) => p.type !== 'literal').map((p) => [p.type, p.value]));
  // Retry during the first five minutes after 08:00; the database key prevents duplicates.
  if (parts.hour !== '08' || Number(parts.minute) > 4) return;
  const today = `${parts.year}-${parts.month}-${parts.day}`;
  const config = await readAppConfig();
  const greeting = config.morningGreeting || DEFAULT_APP_CONFIG.morningGreeting;
  const [pairs] = await pool.query('SELECT id, sender_uid, receiver_uid FROM pairs');
  for (const pair of pairs) {
    const conn = await pool.getConnection();
    let inserted = false;
    try {
      await conn.beginTransaction();
      const [claim] = await conn.execute(
        'INSERT IGNORE INTO its_scheduled_runs (pair_id, message_key, scheduled_date) VALUES (?, ?, ?)',
        [pair.id, 'morning_greeting', today]
      );
      if (claim.affectedRows === 1) {
        await conn.execute(
          'INSERT INTO messages (pair_id, sender_uid, body) VALUES (?, ?, ?)',
          [pair.id, pair.sender_uid, greeting]
        );
        inserted = true;
      }
      await conn.commit();
    } catch (e) {
      await conn.rollback().catch(() => {});
      throw e;
    } finally {
      conn.release();
    }
    if (inserted) {
      try {
        const [tokens] = await pool.execute(
          'SELECT token FROM device_tokens WHERE firebase_uid = ?', [pair.receiver_uid]
        );
        if (tokens.length) {
          await admin.messaging().sendEachForMulticast({
            tokens: tokens.map((row) => row.token),
            notification: { title: 'صباح الخير', body: greeting },
            data: { type: 'daily_greeting', date: today },
            android: { priority: 'high' }
          });
        }
      } catch (e) {
        console.error('Daily greeting notification error:', e.message);
      }
    }
  }
}

app.use((err, _req, res, _next) => {
  console.error('API error:', err && err.message ? err.message : 'unknown');
  res.status(500).json({ success: false, error: 'server_error' });
});

(async () => {
  try {
    await pool.query('SELECT 1');
    await pool.query('SELECT slot, installation_id, active FROM authorized_devices LIMIT 0');
    await pool.query('SELECT id, sender_uid, receiver_uid FROM pairs LIMIT 0');
    await pool.query('SELECT id, pair_id, sender_uid, body, created_at FROM messages LIMIT 0');
    try {
      await pool.query(`CREATE TABLE IF NOT EXISTS its_app_settings (
        setting_key VARCHAR(64) NOT NULL PRIMARY KEY,
        setting_value VARCHAR(500) NOT NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`);
      for (const [key, value] of Object.entries({
        sender_name: DEFAULT_APP_CONFIG.senderName,
        receiver_name: DEFAULT_APP_CONFIG.receiverName,
        opening_message: DEFAULT_APP_CONFIG.openingMessage,
        morning_greeting: DEFAULT_APP_CONFIG.morningGreeting,
        music_label: DEFAULT_APP_CONFIG.musicLabel,
        latest_version: DEFAULT_APP_CONFIG.latestVersion,
        download_url: DEFAULT_APP_CONFIG.downloadUrl
      })) {
        await pool.execute('INSERT IGNORE INTO its_app_settings (setting_key, setting_value) VALUES (?, ?)', [key, value]);
      }
      await pool.query(`CREATE TABLE IF NOT EXISTS its_scheduled_runs (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        pair_id BIGINT UNSIGNED NOT NULL,
        message_key VARCHAR(64) NOT NULL,
        scheduled_date DATE NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY uq_its_scheduled_run (pair_id, message_key, scheduled_date)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`);
      greetingSchedulerReady = true;
      await runDailyGreeting().catch((e) => console.error('Daily greeting scheduler:', e.message));
      setInterval(() => runDailyGreeting().catch((e) => console.error('Daily greeting scheduler:', e.message)), 30000);
    } catch (e) {
      console.error('Remote settings or daily greeting scheduler unavailable:', e.message);
    }
    app.listen(3000, '127.0.0.1', () => console.log('ITS API online on 127.0.0.1:3000'));
  } catch (e) {
    console.error('ITS API startup failed:', e.message);
    process.exit(1);
  }
})();
