"""Apply the September reviewer documentation refresh; never modify app code or ZIPs."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
doc = root / 'CodeCanyon_Package/Main_File/documentation'
src = root / 'tools/documentation_sources'

def edit(path, pairs):
    text = path.read_text(encoding='utf-8')
    for old, new in pairs:
        text = text.replace(old, new)
    path.write_text(text, encoding='utf-8')

p = doc / 'index.html'
s = p.read_text(encoding='utf-8')
if 'href="customization.html"' not in s:
    s = s.replace('      <ul>\n        <li><a href="api-reference.html">', '''      <ul>
        <li><a href="customization.html">Customization: name, identifiers, colors, logo, icon and splash</a></li>
        <li><a href="backend-deployment.html">Production deployment: Nginx, PHP-FPM, HTTPS/WSS and PM2</a></li>
        <li><a href="gamepix.html">GamePix games: publisher SID, categories, blocking and device checks</a></li>
        <li><a href="third-party-services.html">Third-party services and buyer cost responsibility</a></li>
        <li><a href="api-reference.html">''', 1)
s = s.replace('The removed game system is outside the current product scope. These guides do not require restoring it.', 'GamePix online games are included in the current buyer source; follow the dedicated GamePix guide for account configuration and testing.')
s = s.replace('Google Sign-In, non-redeemable', 'Google Sign-In, GamePix online HTML5 games, non-redeemable', 1)
if '<li>GamePix HTML5' not in s:
    s = s.replace('        <li>Firebase Cloud Messaging and Google Sign-In support.</li>', '        <li>GamePix HTML5 game catalogue inside voice rooms, with categories, pagination and an embedded player. Games require internet and an authorized publisher SID.</li>\n        <li>Firebase Cloud Messaging and Google Sign-In support.</li>')
s = s.replace('Node.js 18+ and npm 9+.', 'A maintained Node.js LTS release and npm. This production guide requires Node 22+ for explicit --env-file loading.')
if '      <h3>Apache Example</h3>' in s:
    a = s.index('      <h3>Apache Example</h3>'); b = s.index('    </section>', a)
    s = s[:a] + '      <p>Follow the complete <a href="backend-deployment.html#nginx">Nginx/PHP-FPM configuration</a> for HTTPS, API routing, admin, signed uploads and WSS proxying. Keep public/ as the web root.</p>\n' + s[b:]
a = s.index('      <h2>Node.js Installation</h2>'); b = s.index('    </section>', a)
s = s[:a] + '''      <h2>Node.js Installation</h2>
      <p>Follow <a href="backend-deployment.html#process-management">PM2 and Node production setup</a>. Configure the separate Node .env and start s1.js with the documented --env-file argument: the supplied server does not automatically read .env.</p>
      <p>The production guide covers dependencies, Redis/API values, HTTPS/WSS proxying, firewall restrictions, automatic reboot recovery and logs.</p>
''' + s[b:]
if '      <h2>App Branding</h2>' in s:
    a = s.index('      <h2>App Branding</h2>'); b = s.index('    </section>', a)
    s = s[:a] + '''      <h2>App Customization</h2>
      <p>Follow the dedicated <a href="customization.html">step-by-step customization guide</a>:</p>
      <ol>
        <li><a href="customization.html#app-name">App name on Android, iOS and Flutter</a></li>
        <li><a href="customization.html#bundle-id">Android application ID and iOS bundle identifier</a></li>
        <li><a href="customization.html#colors">Colors and light/dark themes</a></li>
        <li><a href="customization.html#logo">In-app logo</a></li>
        <li><a href="customization.html#icon">Android and iOS launcher icons</a></li>
        <li><a href="customization.html#splash">Native and Flutter splash screens, including Android 12+</a></li>
      </ol>
''' + s[b:]
s = s.replace('app display name in Android resources', 'app display name in AndroidManifest.xml')
if 'See <a href="third-party-services.html">the account' not in s:
    s = s.replace('      <h2>Third-Party Services and Costs</h2>', '      <h2>Third-Party Services and Costs</h2>\n      <p><strong>The buyer is responsible for all third-party costs, including Agora and Firebase. These costs are not included in the CodeCanyon purchase price.</strong> See <a href="third-party-services.html">the account and cost guide</a>.</p>')
if '<tr><td>GamePix</td>' not in s:
    s = s.replace('        <tr><td>Redis</td>', '        <tr><td>GamePix</td><td>Online catalogue and hosted games.</td><td>Required for games.</td><td>Flutter publisher SID and PHP category/block configuration; <a href="gamepix.html">setup</a>.</td></tr>\n        <tr><td>Redis</td>')
s = s.replace('such as Agora, Firebase, Bunny.net', 'such as Agora, Firebase, GamePix (where applicable), Bunny.net')
if 'Complete the <a href="gamepix.html#gamepix-test">' not in s:
    s = s.replace('      <h2>Testing Checklist</h2>', '      <h2>Testing Checklist</h2>\n      <p>Complete the <a href="gamepix.html#gamepix-test">GamePix device checklist</a> and <a href="backend-deployment.html#deployment-verification">production verification</a> before distribution.</p>')
p.write_text(s, encoding='utf-8')

p = src / 'operations.html'; s = p.read_text(encoding='utf-8')
a = s.index('<h3>Keep the real-time relay alive</h3>'); b = s.index('</section>', a)
s = s[:a] + '<h3>Keep the real-time relay alive</h3><p>Use the <a href="backend-deployment.html#process-management">production process-management guide</a> for PM2 startup, explicit Node .env loading, logs, restarts and reboot recovery. PHP and Node must share Redis connection settings and API_KEY. Node does not read .env automatically, and SOCKET_BIND_IP does not bind its listener; follow the environment and firewall steps.</p>' + s[b:]
s = s.replace('Verify LEGACY_SQL_HOST, PORT, DB, USER and PASS', 'Verify DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME and DB_PASSWORD in PHP .env (mapped internally to LEGACY_SQL_* keys)')
p.write_text(s, encoding='utf-8')
edit(src / 'webview-maintenance.html', [
    ("The game system has been removed from the product scope. Do not copy the development checkout's local plugin or re-enable game screens to follow this documentation.", 'The buyer source includes <a href="gamepix.html">GamePix games</a> using the hosted WebView plugin. GamePix does not require the historical custom bridge or development fork.'),
    ('Test actual remaining URL-launch/web content paths:', 'Test the GamePix catalogue/player using <a href="gamepix.html#gamepix-test">its device checklist</a>, and the separate URL-launch paths:'),
    ("Such an extension is outside the current package's removed-feature scope.", 'Such a custom bridge is outside the delivered GamePix integration.'),
    ('Android release builds, retained web links work on physical devices', 'Android release builds, GamePix and retained web links work on physical devices')])
edit(src / 'visual-walkthroughs.html', [('Use the current buyer build with the removed game feature kept absent.', 'Use the current buyer build and include the <a href="gamepix.html#gamepix-test">GamePix catalogue and game screen</a> in the capture checklist.')])
edit(doc / 'README.md', [
    ('Open `index.html` in a browser for the complete local documentation.\n\n##', '''Open `index.html` in a browser for the complete local documentation.

- [Customization](customization.html): name, identifiers, colors, logo, icon and splash screens.
- [Production deployment](backend-deployment.html): Nginx, PHP-FPM, HTTPS/WSS, explicit Node environment loading and PM2.
- [GamePix games](gamepix.html): publisher SID, categories, blocking, API and device checks.
- [Third-party costs](third-party-services.html): the buyer pays all applicable charges, including Agora and Firebase; these are not included in the item price.

##'''),
    ('The removed game feature is not restored or required.', 'GamePix is included and documented separately from the non-game API catalogue. Online services and external links require internet access.'),
    ('Do not copy the development fork or removed game integration back into this package.', 'GamePix uses the hosted WebView plugin and does not require the historical custom bridge.'),
    ('Agora, Firebase, Bunny.net, Google Play', 'Agora, Firebase, GamePix (where applicable), Bunny.net, Google Play')])
edit(src / 'README.md', [('seven supplemental guides', 'eleven supplemental guides'), ('eight offline HTML guides', 'twelve offline HTML guides'), ('This documentation builder does not restore games, modify application code, deploy, or replace the distribution ZIP.', 'This builder documents the delivered GamePix integration without modifying application code, deploying, or replacing the distribution ZIP.')])
(root / 'CodeCanyon_Package/Main_File/license_information/third-party-services.md').write_text('''# Third-Party Service Notes

**The buyer is responsible for all costs associated with third-party services, including Agora and Firebase. These costs are not included in the AppChat CodeCanyon purchase price.**

Buyers provide their own Firebase/Google Cloud, Agora, Google Play, Apple, GamePix publisher, hosting, Redis, domain/TLS and optional Bunny.net or other provider accounts. Applicable subscriptions, usage, overages, account/store charges and infrastructure bills are paid by the buyer. Free tiers/trials follow provider terms; no prepaid usage, permanent allowance or provider account is included.

GamePix games are hosted third-party content accessed through the included AppChat integration. Game source files, artwork ownership, a publisher account, guaranteed revenue and ad-free play are not included. Obtain your own authorized SID and confirm intended mobile WebView use and applicable attribution/advertising arrangements with GamePix. Replace the sample SID in Flutter before release.

See [Third-party services and costs](../documentation/third-party-services.html) and [GamePix setup](../documentation/gamepix.html).
''', encoding='utf-8')
p = root / 'CodeCanyon_Package/Main_File/changelog/changelog.html'
if 'Documentation update - 22 September 2026' not in p.read_text(encoding='utf-8'):
    edit(p, [('  <h2>Version 1.0.0</h2>', '''  <h2>Documentation update - 22 September 2026</h2>
  <ul>
    <li>Added customization for name, identifiers, colors, logo, icon and splash.</li>
    <li>Added production Nginx/PHP-FPM, HTTPS/WSS and PM2 deployment with explicit Node environment loading.</li>
    <li>Clarified buyer responsibility for third-party costs including Agora and Firebase.</li>
    <li>Documented GamePix setup, publisher SID, categories, blocking, limitations and device checks.</li>
  </ul>
  <h2>Version 1.0.0</h2>''')])
for rel in ['CodeCanyon_Package/Main_File/README.txt', 'CodeCanyon_Package/README.txt']:
    p = root / rel
    if 'Documentation update (22 September 2026)' not in p.read_text(encoding='utf-8'):
        with p.open('a', encoding='utf-8') as f:
            f.write('\nDocumentation update (22 September 2026): open documentation/index.html inside Main_File. Dedicated customization, backend-deployment, gamepix and third-party-services guides are included. The buyer pays all applicable third-party costs, including Agora and Firebase; these are not included in the item price.\n')
edit(src / 'socket-events.html', [('The removed game system has no integration steps in this catalogue.', 'GamePix uses HTTP catalogue/configuration requests and an embedded WebView, with no dedicated game socket events; see <a href="gamepix.html">GamePix setup</a>.')])
p = root / 'CodeCanyon_Package/Reviewer_Information/resubmission-response-draft.txt'
edit(p, [('The API guide documents the delivered non-game source; removed games are not required or restored.', 'The API guide documents the delivered non-game source; the included GamePix integration has a separate setup guide. For the latest customization, deployment and cost response, use resubmission-response.md.')])
print('Updated navigation, documentation sources, notices and changelog.')
