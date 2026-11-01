"""Build the offline buyer reference without copying or modifying application code."""
from pathlib import Path
import html, json, re
from inspect_doc_contracts import ROOT, PHP, methods

DOC = ROOT / 'CodeCanyon_Package/Main_File/documentation'
E = html.escape
def code(value): return '<code>' + E(str(value)) + '</code>'
def pre(value): return '<pre><code>' + E(value if isinstance(value, str) else json.dumps(value, ensure_ascii=False, indent=2)) + '</code></pre>'
def table(headers, rows):
    return '<div class="table-scroll"><table><thead><tr>' + ''.join('<th>'+E(x)+'</th>' for x in headers) + '</tr></thead><tbody>' + ''.join('<tr>'+''.join('<td>'+str(x)+'</td>' for x in row)+'</tr>' for row in rows) + '</tbody></table></div>'
def section(title, body, anchor=None): return '<section'+(' id="'+anchor+'"' if anchor else '')+'><h2>'+E(title)+'</h2>'+body+'</section>'
def page(name, title, content):
    out = '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>'+E(title)+' — AppChat</title><link rel="stylesheet" href="assets/documentation.css"></head><body><aside><strong>AppChat reference</strong><a href="index.html">Installation guide</a><a href="customization.html">Customization</a><a href="backend-deployment.html">Production deployment</a><a href="gamepix.html">GamePix games</a><a href="third-party-services.html">Third-party costs</a><a href="api-reference.html">PHP API</a><a href="socket-events.html">Socket.IO events</a><a href="operations.html">Operations & troubleshooting</a><a href="configuration.html">Flutter configuration</a><a href="ios-release.html">iOS release</a><a href="admin-permissions.html">Admin permissions</a><a href="webview-maintenance.html">WebView maintenance</a><a href="visual-walkthroughs.html">Visual walkthroughs</a><input id="search" aria-label="Search this reference" placeholder="Search this reference"><nav id="toc"></nav></aside><main><section><h1>'+E(title)+'</h1><p>Reference for the files delivered in Main_File. Documentation updated 22 September 2026. Examples use fictional IDs and balances; replace them with values from your installation.</p></section>'+content+'</main><script src="assets/documentation.js"></script></body></html>'
    out = out.replace('<a href="socket-events.html">', '<a href="room-disconnect.html">Room disconnect recovery</a><a href="socket-events.html">')
    out = out.replace('assets/documentation.css"', 'assets/documentation.css?v=20260919"').replace('assets/documentation.js"', 'assets/documentation.js?v=20260919"')
    out = out.replace('assets/documentation.css"', 'assets/documentation.css?v=20260919"').replace('assets/documentation.js"', 'assets/documentation.js?v=20260919"')
    (DOC / name).write_text(out, encoding='utf-8')

# Each row is route | purpose | request fields with types/defaults and constraints | example data.
# Nested examples are projections; the resource dictionary documents their other fields.
RAW = r'''
auth/index|Google account sign-in/registration|provider:string! = google; googleid:string or email:string! (at least one); name:string?=''; auth_token:string?=''; device_id:string?=''; platform:string?=''|{"token":"SESSION_TOKEN","web_token":"WEB_TOKEN","appPrefix":"tomchat","socket_ip":"socket.example.com","socket_port":443,"coins":0,"diamond":0,"user":{"uid":42,"name":"Demo"}}
auth/loginById|Sign in with user ID or username and password|id:string!; password:string!; device_id:string?=''; platform:string?=''|{"token":"SESSION_TOKEN","web_token":"WEB_TOKEN","appPrefix":"tomchat","socket_ip":"socket.example.com","socket_port":443,"coins":0,"diamond":0,"user":{"uid":42,"name":"Demo"}}
auth/tokenLogin|Refresh the authenticated session and Redis token mapping|device_id:string? (must match login device when supplied)|{"token":"SESSION_TOKEN","web_token":"WEB_TOKEN","appPrefix":"tomchat","socket_ip":"socket.example.com","socket_port":443,"coins":0,"diamond":0,"user":{"uid":42}}
auth/update|Update the current profile and optionally password|name,avatar,bg,country,comment,birthday,username,profile_frame,entry,theme:string? (omitted fields unchanged; birthday YYYY-MM-DD); type:int?; new_password:string? (alias password, minimum 6 characters); old_password:string? (alias current_password, verified when supplied); confirm_password:string? (alias password_confirmation, must match when supplied)|{"user":{"uid":42,"name":"Demo"},"coins":1000,"diamond":0}
auth/updateFcmToken|Set or clear push notification token|fcm_token:string?='' (alias fcmToken)|{"updated":true}
auth/logout|Revoke current mobile token|No endpoint-specific fields|{"logout":true}
auth/deleteAccount|Soft-delete current account and revoke tokens|No endpoint-specific fields|{"deleted":true}
auth/changlanguage|Save language; spelling retained for compatibility|language:string?=en (alias lang)|{"updated":true}
helper/index|Alias of helper/config|No endpoint-specific fields|{"agora":"AGORA_APP_ID","agora_token_ttl":3600,"socket_ip":"socket.example.com","socket_port":443,"business":{}}
helper/config|Fetch public client configuration|No endpoint-specific fields|{"agora":"AGORA_APP_ID","agora_token_ttl":3600,"socket_ip":"socket.example.com","socket_port":443,"business":{}}
helper/getBanners|Read active banners|No endpoint-specific fields|{"list":[],"banners":[]}
helper/levels|Read level definitions|type:string?='' (empty all; consumption/gifter/charge/anchor); p:int?=1 (alias page); limit:int?=30 (1–100)|{"list":[]}
helper/globalUploadFile|Request an upload plan; does not upload bytes|extension:string?=jpg; filename:string? (default file_<timestamp>.<extension>); folder:string?=uploads|{"provider":"server","path":"uploads/photo.jpg","url":"https://example.com/server_upload.php/uploads/photo.jpg?expires=123&token=SIGNED","upload_url":"https://example.com/server_upload.php/uploads/photo.jpg?expires=123&token=SIGNED","headers":[]}
user/index|Fetch a profile; may record a profile visit|id:int?=current user (aliases user_id,touid)|{"user":{"uid":42,"name":"Demo"},"profile":{"uid":42,"name":"Demo"}}
user/search|Search users|search:string?=''; p:int?=1 (alias page); limit:int?=30 (1–100)|{"list":[]}
user/attention|Toggle following another user|id:int! (aliases touid,user_id); cannot be current user|{"button":"follow","following":false,"user":{"uid":43}}
user/myMedals|List current user's medals|No endpoint-specific fields|{"medals":[]}
user/useMedals|Equip one owned medal, clearing previous selection|id:int?=0 (alias medal_id; 0 clears selection)|{"updated":true,"user":{"uid":42}}
user/getProfileVisit|List profile visitors|No endpoint-specific fields|{"list":[]}
user/getUsersAttention|List followers or following|state:string?=following (followers selects incoming follows)|{"list":[]}
room/index|List/search rooms|p:int?=1 (alias page); limit:int?=50 (1–100); search:string?=''; followOnly:int?=0 (1 followed hosts)|{"rooms":[],"list":[]}
room/createRoom|Create or return current user's room|title:string? (empty becomes Room <uid>); micLngs:int?=business.default_room_seats (fallback 9); type:int?=0; icon,bg:string?=''|{"room":{"id":7,"uid":42,"title":"Demo room","seats":[]}}
room/updateRoom|Update a managed room|rid:int! (alias id); title,bg,icon,password:string?; type,allow_messages,allow_mic,carizma:int?; omitted fields unchanged; password=delete removes password|{"room":{"id":7,"title":"Demo room","seats":[]}}
room/backgroundList|List room backgrounds|p:int?=1 (alias page); limit:int?=30 (1–100)|{"list":[]}
room/changeRoomSeatsLng|Set seat count for a managed room|rid:int! (alias id); micLngs:int?=9 (aliases lng,count; clamped 1–20)|{"seats":[]}
live/startLive|Start current user's room; creates it on first call|No endpoint-specific fields; if no room exists first call returns createRoom response, then call again|{"room":{"id":7,"agora_channel":"room_7","agora_uid":42,"user_sw_token":"AGORA_TOKEN"},"owner":{"uid":42},"seats":[],"usersCount":1,"coin_number":0,"state":"ok"}
live/enterRoom|Enter room and obtain Agora credentials|rid:int!; password:string?='' (required for password room unless manager)|{"room":{"id":7,"agora_channel":"room_7","agora_uid":42,"user_sw_token":"AGORA_TOKEN"},"owner":{"uid":43},"seats":[],"usersCount":2,"coin_number":0,"state":"ok"}
live/leaveRoom|Leave room and release seat|rid:int!|{"left":true,"users_count":1}
live/giftList|Read gift groups and combo counts|No endpoint-specific fields|{"gifts":[],"combo":[1,7,77,777,7777]}
live/giftBackpack|Read owned gifts|No endpoint-specific fields|{"gifts":[]}
live/sendGift|Send a gift and debit balance/inventory|rid:int!; gift:int! (catalog gift ID); count:int?=1 (positive); toUsers:string! (comma-separated recipient IDs, e.g. 43,44); is_backpack:int?=0 (alias isBackpack, 1 uses inventory)|{"coins":990,"diamond":0,"coinsBack":0,"rocket":null}
live/seatTake|Take, request or leave a seat|rid:int!; seat:int?=0 (alias pos, zero-based); isUp:int?=0 (1 take; 0 leave); touid:int?=current user (alias uid; managing another user requires room manager)|{"seats":[]}
live/seatRequestAccept|Accept/reject the pending request on a seat|rid:int!; seat:int?=0 (alias pos); accept:int?=9 (alias state; 0 rejects, nonzero accepts); manager required|{"updated":true,"target":43}
live/seatState|Change seat availability|rid:int!; seat:int?=0 (alias pos); state:int?=0 (alias mute, clamped 0–2); seat occupant or manager authorization applies|{"seats":[]}
live/seatMic|Change microphone state|rid:int!; seat:int?=0 (alias pos); state:int?=0 (alias mute, clamped 0–2); 2 is manager-locked and only manager can unlock|{"seats":[]}
live/onlineUsers|List Redis room presence|rid:int!|{"users":[],"list":[]}
live/getMembersList|List room members by role or online users|rid:int!; rule:int? (alias role; absent delegates onlineUsers); p:int?=1 (alias page); limit:int?=50 (1–100)|{"list":[]}
live/sendMessage|Send room text through PHP then broadcast|rid:int!; msg:string?='' (display text); message:string?='' (alias content, separate legacy msg output). Send msg for the Flutter room UI|{"message":{"type":"normal","text":"Hello","msg":"","person":{"uid":42,"name":"Demo"}}}
live/emojiList|List seat emojis|No endpoint-specific fields|{"list":[]}
live/sendEmoji|Broadcast a seat emoji|rid:int!; seat:int?=0; name:string?='' (catalog emoji name)|{"sent":true}
live/clearChat|Clear displayed room chat for listeners|rid:int!; manager required|{"cleared":true}
live/clearRoomGifts|Reset room gift counters and notify listeners|rid:int!|{"cleared":true}
live/userAction|Change target's room role|rid:int!; touid:int! (alias user_id); rule:int?=5 (alias role); hours:int?=0 (expiry stored only for roles 0,1,2); manager required|{"uid":43,"rule":5,"expires_at":null}
live/ranking|Compute ranking from transaction records|time:string?=daily (week/month supported); type:string?=gifter (anchor/rooms supported); rid:int?=0 (all rooms); limit:int?=50 (1–50); p:int?=1 (alias page)|{"list":[]}
livebox/send|Create a timed room coin box|liveuid:int! (alias rid, room ID); coins:int!>0; people:int?=1; minutes:int?=10 (minimum 1); type:int?=1 (2 broadcasts across rooms)|{"done":1,"box":{"id":5,"rid":7,"coins":100},"red":{"id":5,"rid":7,"coins":100},"coins":900}
livebox/use|Claim a box once eligible; coins in this response means remaining box coins|box_id:int! (alias id)|{"done":1,"reward":10,"coins":90,"rid":7,"people":1}
chat/index|List private conversations|p:int?=1 (alias page); limit:int?=20 (1–50)|{"chats":[],"list":[],"page":1,"limit":20}
chat/getMessages|Read a conversation and update read states|chat_id:int (alias id) or touid:int (aliases uid2,user_id), one required; p:int?=1 (alias page); limit:int?=20 (1–50)|{"messages":[],"list":[],"chat_id":8,"page":1,"limit":20}
chat/sendMessage|Create a private message|chat_id:int or touid:int (aliases target_uid,user_id), one required; content:string?='' (alias message); image_url,video_url,voice_url:string?=''; provide text or uploaded media URL|{"isReadNow":false,"message":{"id":10,"chat_id":8,"uid":42,"content":"Hello"},"chat_id":8}
chat/delete|Delete own message and update conversation preview|id:int! (aliases msgID,messageID)|{"deleted":true,"messageID":10,"chat_id":8,"last_message":{"id":9,"chat_id":8}}
chat/addReaction|Add/remove reaction|id:int! (alias message_id); emoji:string?=''; isDelete:int?=0 (alias delete, 1 removes)|{"updated":true,"reactions":[],"chat":{"id":10,"chat_id":8}}
chat/openOnlineChat|Mark active conversation and acknowledge unread messages|chat_id:int (alias id) or touid:int (aliases uid2,user_id), one required|{"opened":true,"chat_id":8,"message_ids":[],"unread_count":0}
chat/closeOnlineChat|Clear active private conversation presence|chat_id:int?=0 (alias id)|{"closed":true,"chat_id":8}
post/index|Read recent posts|touid:int?=0 (all users)|{"posts":[],"list":[]}
post/add|Create a post|title,description,url:string?='' (provide meaningful content and an uploaded URL for media)|{"post":{"id":5,"uid":42,"title":"Hello"}}
post/like|Toggle a post like|id:int! (alias post_id)|{"like":1}
post/getComments|Read comments|id:int! (alias post_id)|{"comments":[],"list":[]}
post/comment|Add a comment|id:int! (alias post_id); comment:string?='' (alias content)|{"comment":{"id":6,"post_id":5,"uid":42,"content":"Hello"}}
post/commentLike|Toggle a comment like|id:int! (alias comment_id)|{"like":1}
post/deleteComment|Soft-delete own comment|id:int!|{"deleted":true}
gift/index|Compatibility gift/sticker listing|type:string?=''|{"gifts":[],"coins":1000}
shop/index|Read available store items|type:int? (absent all types)|{"list":[]}
shop/backpack|Read owned store inventory|type:int? (absent all types)|{"list":[]}
shop/buying|Buy store item with coins|id:int! (alias item_id); touid:int?=current user (alias to_uid, gift recipient)|{"coins":900,"item":{"id":2,"name":"Frame"},"user":{"uid":42}}
shop/activeItem|Equip or unequip inventory|id:int! (alias inventory_id; use owned inventory ID, not catalog ID); active:int?=0 (1 equip)|{"updated":true,"user":{"uid":42}}
shop/sendFromBackpack|Compatibility stub: returns success without transferring an item|No fields consumed; no inventory mutation implemented|{"sent":true}
shop/vipList|Read packages and ownership|No endpoint-specific fields|{"list":[],"vip":[]}
shop/vipBuying|Buy VIP for self or another user|id:int (alias vip_id) or num:int, one required; touid:int?=current user (alias to_uid)|{"coins":500,"vip":{"id":1,"num":1,"active":1},"user":{"uid":42}}
shop/vipChangeActive|Activate/deactivate an owned unexpired VIP|id:int (alias vip_id) or num:int, one required; active:int?=1 (0 deactivate)|{"updated":true,"user":{"uid":42},"vip":null,"list":[]}
cash/index|Read wallet balances and exchange settings|No endpoint-specific fields|{"coins":1000,"diamond":0,"votes":0,"total":0,"dollar":0,"dollar_earnings":0,"cash_min":1,"cash_rate":15000,"exchange_rate":15000,"diamond_rate":6,"cash_start":1,"cash_end":31,"cash_max_times":10,"you_cash_count":0,"types":[],"business":{}}
cash/sendCoins|Convert earnings balance into coins for another user|to_uid:int! (aliases touid,uid; cannot be self); coins:int!>0 (alias amount)|{"coins":1000,"diamond":0,"total":0,"dollar":0,"dollar_earnings":0}
cash/exchangeDiamond|Exchange diamonds to coins|diamond:int!>0 (alias amount)|{"coins":1006,"diamond":0,"votes":0,"total":0,"dollar":0,"dollar_earnings":0}
cash/add_request|Legacy withdrawal request handler; not a recharge purchase|amount:number!>0 (alias money); accountId:int?=0 (alias account_id); agency_id:int?=0 (alias agencyId); currency:string?=coins; note:string? (defaults account:<id> when account supplied)|{"id":12,"created":true,"coins":1000,"diamond":0,"dollar_earnings":0}
cash/my_cash_accounts|List legacy payout accounts|No endpoint-specific fields|{"list":[]}
cash/charge_agency|List active agencies|No endpoint-specific fields|{"list":[]}
cash/cash_request_list|Read current user's legacy withdrawal requests|No endpoint-specific fields|{"list":[]}
cash/add_cash_account|Create a legacy payout account|type,name,account:string?='' (provide all three for usable record)|{"id":1,"account":{"id":1,"name":"Demo"}}
cash/delete_cash_account|Delete own legacy payout account|id:int!|{"deleted":true}
payment/index|Read recharge products for the platform billing UI|No endpoint-specific fields|{"packages":[],"plans":[],"recharge_open":1}
payment/pay|Verify platform purchase and credit once|provider:string?=google (alias type; apple for iOS); product_id:string! (alias android_product_id); token:string! (alias purchaseToken; Play purchase token or Apple receipt base64)|{"id":12,"order_id":"EXAMPLE_ORDER","coins":1100,"diamond":0,"user":{"uid":42}}
payment/userLog|Read current user's payment history|No endpoint-specific fields|{"list":[]}
guild/index|List agencies or read one agency and its statistics|id:int?=0 (alias guild_id, 0 lists agencies); uid:int?=current user (membership lookup for single agency)|{"list":[],"guilds":[]}
guild/usersList|Read agency members|id:int! (alias guild_id); p:int?=1 (alias page); limit:int?=50 (1–100)|{"list":[]}
guild/requestUsersList|Read agency join requests|id:int! (alias guild_id); p:int?=1 (alias page); limit:int?=50 (1–100)|{"list":[]}
guild/rooms|Read agency rooms|id:int! (alias guild_id); p:int?=1 (alias page); limit:int?=50 (1–100)|{"rooms":[],"list":[]}
guild/search|Search agencies|search:string?='' (alias name)|{"list":[]}
guild/addRequest|Request agency membership|id:int! (alias guild_id)|{"requested":true,"user":{"uid":42}}
guild/requestState|Update membership request|request_id:int (alias id) or touid:int (aliases uid,user_id) with guild_id:int (alias agency_id; absent resolves owned agency); state:int?=9 (9 accepts a request, 0 removes membership; other states recorded on the request)|{"updated":true}
guild/update|Update an agency owned by current user|id:int? (alias agency_id, absent resolves owned agency); name,notice,description,icon:string? (omitted unchanged)|{"agency":{"id":3,"name":"Demo agency"}}
rocket/index|Read Rocket tiers, current progress and reset countdown|rid:int?=0 (alias liveuid; room ID, fallback owner UID lookup)|{"levels":[],"list":[],"myLevel":null,"rocket_level":null,"live":null,"sec":3600}
rocket/ranking|Read current day's Rocket contributors|rid:int?=0 (alias liveuid; 0 all rooms)|{"list":[],"sec":3600}
notification/index|Read notifications and mark returned personal records read|p:int?=1 (alias page); limit:int?=20 (1–50); type:string or array? (alias types; comma-separated string or actual array of supported notification types, not a JSON-encoded string)|{"list":[],"page":1,"limit":20,"unread_count":0}
notification/settings|Read push preferences|No endpoint-specific fields|{"settings":{"live_started":true,"new_follower":true,"post_interaction":true,"store_item_or_vip":true,"private_message":true}}
notification/unreadCount|Read notification badge count|No endpoint-specific fields|{"unread_count":0}
notification/updateSettings|Update push preferences|settings:object? (or JSON string or top-level fields); keys live_started,new_follower,post_interaction,store_item_or_vip,private_message; values 0/1 or boolean; omitted unchanged|{"settings":{"live_started":true,"new_follower":true,"post_interaction":true,"store_item_or_vip":true,"private_message":false}}
media/videoCreate|Register an already uploaded video|description:string?=''; url:string?='' (alias video); thum,gif:string?=''; multi_url:string?='[]' (JSON-encoded array); duration:number?=0; width,height:int?=0|{"video":{"id":5,"uid":42,"url":"https://example.com/video.mp4","state":1}}
media/videoUploadPlan|Get upload locations for video variants and thumbnail|No endpoint-specific fields; this does not transcode video|{"provider":"server","qualities":[{"quality":"360p","path":"videos/42/123/360p.mp4","url":"https://example.com/server_upload.php/videos/42/123/360p.mp4?expires=123&token=SIGNED"}],"thumbnail_path":"videos/42/123/thumb.jpg","thumbnail_url":"https://example.com/server_upload.php/videos/42/123/thumb.jpg?expires=123&token=SIGNED","headers":[]}
cp/ranking|Compatibility stub: empty result|No fields consumed|{"list":[]}
cp/changeCpState|Compatibility stub: no relationship state changes|No fields consumed|{"updated":true}
cp/useCard|Compatibility stub: no card use implemented|No fields consumed|{"used":true}
admin/login|Create separate admin session|email:string!; password:string!|{"admin":{"id":2,"name":"Moderator","email":"moderator@example.com","roles":[],"permissions":["dashboard.view"]},"admin_token":"ADMIN_SESSION_TOKEN"}
admin/logout|Revoke the cookie-backed admin session|No endpoint-specific fields; preserve session cookie from login|{"logout":true}
admin/me|Read admin identity and permissions|No endpoint-specific fields; dashboard.view required|{"admin":{"id":2,"name":"Moderator","permissions":["dashboard.view"]}}
admin/index|Dashboard counters|No endpoint-specific fields; dashboard.view required|{"users":0,"rooms":0,"active_rooms":0,"vip_users":0,"store_items":0,"recent_transactions":[],"recent_reports":[]}
admin/table|Read an allowed management table|table:string!; p:int?=1 (alias page); limit:int? (table-specific default, max 200); see table catalogue for permission|{"list":[],"rows":[],"page":1,"limit":50}
admin/saveTable|Create/update an allowed management record|table:string!; id:int?=0 (0 inserts); permitted table fields only, listed below; table permission required|{"id":5,"saved":true}
admin/deleteTable|Delete or disable an allowed record|table:string!; id:int!; table-specific permission required; agencies requires agencies.delete|{"deleted":true}
admin/settings|Read application settings|No endpoint-specific fields; settings.view required|{"list":[]}
admin/saveSetting|Save application setting|setting_key:string!; setting_value:string?=''; group_key:string?=app; is_secret:int?=0; settings.manage required|{"saved":true}
admin/rechargeState|Legacy withdrawal review despite the route name|id:int!; status:int?=9 (valid 0,1,2,3,9); transactions.manage required|{"updated":true,"request":{"id":12}}
'''

def build_api():
    entries = []
    for row in RAW.strip().splitlines():
        route, purpose, fields, sample = row.split('|', 3)
        entries.append(dict(route=route, purpose=purpose, fields=fields, sample=json.loads(sample)))
    defined = {e['route'] for e in entries}
    detected = set()
    for p in (PHP/'app/Controllers').glob('*AppController.php'):
        c = p.name.removesuffix('AppController.php').lower()
        if c == 'game': continue  # Removed product feature; do not restore/document its integration.
        for name,(vis,body,line) in methods(p).items():
            if vis == 'public': detected.add(c+'/'+name)
    assert detected == defined, (sorted(detected-defined), sorted(defined-detected))
    intro = '''<p>Base URL is your configured public PHP origin/path, followed by <code>/api/{controller}/{method}</code>. For example <code>https://api.example.com/api/room/index</code>. Omit <code>/index</code> to call a controller's index method. Names below retain the case used by Flutter; the router normalizes routes to lowercase.</p><p><strong>Use POST for every JSON API route below.</strong> Read operations also use POST. Send JSON with <code>Content-Type: application/json</code> or form data. Fields are body parameters, not query parameters. There is no REST PUT/PATCH/DELETE contract for these controllers. Some handlers do not reject other verbs, but that is not a supported integration contract.</p><p>Inspect the JSON <code>code</code>, not just HTTP status: the router returns HTTP 200 even when the body reports 400, 401, 403, 404 or 500. Success is <code>code:200</code>, <code>err:null</code>, <code>msg:null</code>, and endpoint-specific <code>data</code>. Empty data can become null. Error text may be localized by <code>lang</code> or Accept-Language. The room entry route also returns code 200 with data.state=bad_password or banned; check that state.</p>'''
    intro += table(['Header','When','Value'], [[code('API-KEY'),'Send on every API request','Same value as backend API_KEY'],[code('Auth-Token'),'Mobile protected calls','Token from auth/index or auth/loginById; X-Auth-Token or Authorization: Bearer also accepted'],[code('Admin-Token'),'Admin protected calls','admin_token from admin/login; X-Admin-Token or admin cookie also accepted'],[code('Content-Type'),'JSON requests',code('application/json')],[code('Accept-Language'),'Optional','en or another supported language']])
    intro += '<p>Public client routes are auth/index, auth/loginById, helper/index and helper/config. admin/login needs admin credentials but no existing session. All other mobile calls should use a valid mobile token. An API key is an app identifier and is embedded in mobile builds; it is not an administrator credential. <strong>Implementation caveat:</strong> this router removes the api prefix before rechecking it, so its generic prefix-based authentication checks are not a reliable enforcement boundary. Individual controllers perform differing checks. These documented authentication requirements describe correct client use, not a security guarantee.</p><p>All calls can include optional <code>lang:string</code> and <code>device_id:string</code>. A device ID supplied with a mobile token must match its stored device. Do not pass the mobile token as body <code>token</code> to payment/pay: that field is the purchase receipt. Use Auth-Token there.</p><p>Field notation: <strong>!</strong> means required for the intended operation; <strong>?</strong> means optional with the stated default. An alternate identifier satisfies a required identifier. This is a client contract: legacy handlers do not validate every field. IDs in examples must be obtained from your own list responses. Nested objects in example responses are deliberately abbreviated projections; see the resource dictionary. These are source-derived examples, not recorded production responses.</p>'
    intro += pre('curl -X POST "https://api.example.com/api/live/sendGift" \\\n  -H "API-KEY: YOUR_API_KEY" \\\n  -H "Auth-Token: YOUR_SESSION_TOKEN" \\\n  -H "Content-Type: application/json" \\\n  --data \'{"rid":7,"gift":1,"count":1,"toUsers":"43"}\'')
    content = section('Protocol, authentication and errors',intro,'protocol')
    content += section('Resource dictionary', '''<p>All timestamps stored as SQL date strings use UTC unless stated otherwise. SQL numeric values from uncast list rows can be strings; Flutter models accept them. Image resources are null or <code>{"network":"https://…"}</code>; avatars can also contain a frame.</p>'''+table(['Resource','Fields / interpretation'],[
        ['User','uid:int; name:string; pos,type,state,rule:int; avatar,bg,theme,entry,profile_frame:image|null; comment,country:string; birthday,username,email,deviceId,fmcToken,created_at:string|null; coins,diamond:int; dollar_earnings:number; total_points,gifter_points_total,anchor_points_total,recharge_points_total:int; followers_count,following_count,posts_count,gift_sent_count,gift_received_count,visiters_count,view_count,is_online,online_rid,banned:int; vip:VIP|null; levels:map; medals:list; button:string; equipment fields and guild/room summaries. Retain original key spellings.'],
        ['Room','id,uid,type,state,start,ts,usersCount,coin_number,total_points,isPassword,carizma,my_rule:int; title,created_at:string; bg,icon:image|null; owner:User|null; seats:Seat[]; red_box:Box[]; rocket_level:object|null. Enter/start adds agora_channel:string, agora_uid:int, user_sw_token:string inside room.'],
        ['Seat','pos:int (zero-based); score:int; isHost:bool; percentageSize:1; user:User|null; mute,cam_state,state:int.'],
        ['VIP','id,num,state,price,renewal_price,days,expire_at,active:int; expire_at is Unix seconds; icon,profile_frame,bg,entry_effect,name_entry_effect,frame,bubble,color:string; privileges:array of id/shop_item/icon/state/type/name. Package listing additionally includes ownership/remaining-time fields.'],
        ['Level','lvl,nextLevelUp,progress,total:int; icon:string; user levels map contains consumption,gifter,charge,anchor.'],
        ['Box','id,type,rid,liveuid,uid,coins,coins_remaining,people,people_claimed_count,usersCount,is_claimed,seconds,remaining_seconds:int; expired_at,created_at:string; user:User|null; reward:int when claimed.'],
        ['Message','id,chat_id,uid:int; content and uploaded media URL fields; state/target_state indicate local and recipient status; reactions:array; user:User. Read events identify messages with message_ids and state=2.'],
        ['Store item','Catalog ID identifies what to buy; backpack inventory ID identifies what to equip. Item type follows store_items.type, with 0 frame and 2 entrance effect. Price, currency, duration and image/animation values come from the catalogue, not client input.'],
        ['Raw management rows','admin/table returns database columns for the selected allowed table. Fields and edit permissions are listed in the management catalogue below. Do not expose admin responses or secret settings in a mobile UI.']]),'resources')
    for group in dict.fromkeys(e['route'].split('/')[0] for e in entries):
        body = ''
        for e in [x for x in entries if x['route'].startswith(group+'/')]:
            c,m = e['route'].split('/')
            path = PHP/'app/Controllers'/(c.capitalize()+'AppController.php')
            method_body = methods(path)[m][1]
            errors = sorted(set(re.findall(r"\$this->fail\(\$rs,\s*'([^']+)'",method_body)))
            auth = 'API-KEY; '+ ('no prior session' if e['route'] in ['auth/index','auth/loginById','helper/index','helper/config','admin/login'] else 'admin session / Admin-Token' if c=='admin' else 'Auth-Token')
            body += '<article class="endpoint" id="'+c+'-'+m+'"><h3>POST '+E('/api/'+e['route'])+'</h3><p>'+E(e['purpose'])+'</p><p><strong>Headers:</strong> '+E(auth)+'; Content-Type: application/json.</p><p><strong>Request:</strong> '+E(e['fields'])+'</p><details><summary>Example success response</summary>'+pre(dict(code=200,msg=None,err=None,data=e['sample']))+'</details>'
            if errors: body += '<p><strong>Handler errors:</strong> '+', '.join(code(x) for x in errors)+'. See protocol for the error envelope; downstream/database errors can also occur.</p>'
            if c=='cash' and m in ['add_request','my_cash_accounts','add_cash_account','delete_cash_account','cash_request_list'] or e['route']=='admin/rechargeState':
                body += '<p class="notice">Legacy route present in the delivered source. This documents its existence, not a supported cash-redemption product flow. Do not describe this handler as a wallet recharge integration or assume it is disabled without checking the deployed code.</p>'
            body += '</article>'
        content += section(group.capitalize()+' endpoints', body, 'api-'+group)
    admin = (PHP/'app/Controllers/AdminAppController.php').read_text(encoding='utf-8-sig')
    configs = re.findall(r"'([^']+)'\s*=>\s*\['permission'\s*=>\s*'([^']+)'(?:,\s*'table'\s*=>\s*'([^']+)')?,\s*'fields'\s*=>\s*\[([^\]]+)\]",admin)
    content += section('Admin management field catalogue', '<p>For saveTable, fields omitted on update remain unchanged; insert records must satisfy database required columns and foreign keys. State accepts 0,1,2,3,9. Level type accepts consumption,gifter,charge,anchor; Rocket reward type accepts coins,gift,equipment,vip,diamonds; inventory item_type is store or gift. rooms_background maps to media_assets with type=room_bg. This table catalogue excludes legacy database-game configuration. GamePix categories and blocks are documented in <a href="gamepix.html">the GamePix guide</a>.</p>'+table(['table','Write permission','Writable fields'],[[code(t),code(p),E(', '.join(re.findall(r"'([^']+)'",fields)))] for t,p,actual,fields in configs if t!='games'])+'<p>admin/table read permissions: users → users.view; rooms/room_members/room_seats → rooms.view; vip_packages/vip_privileges/user_vips → vip.view; store_items/user_inventory/gifts → store.view; agencies → agencies.view; agency_members/agency_requests → agencies.members.view; posts/comments → posts.view; reports/conversations/messages → reports.view; recharge_requests/wallet_transactions/payment_logs/gift_transactions → transactions.view; medals/levels/recharge_packages/rocket_levels/rocket_rewards/rooms_background → content.view; app_settings → settings.view; admin_roles/admin_permissions/admin_users → roles.view; admin_activity_logs → audit.view. A table writable by saveTable is not necessarily available via table.</p>','admin-tables')
    content += section('Uploads and inherited compatibility routes','''<p><code>helper/globalUploadFile</code> returns an upload plan. For server storage, PUT raw bytes to the exact signed upload_url; preserve its query string. Success is HTTP 200 with plain-text <code>OK</code>. Expired/invalid signatures return HTTP 403 with <code>Invalid upload token</code>. GET on the saved URL serves the file. Maximum upload size is 26,214,400 bytes (25 MiB); extensions: jpg,jpeg,png,gif,webp,svg,svga,mp4. For Bunny storage, the plan contains a relative upload path and AccessKey header; use the configured Bunny storage endpoint and display the CDN URL, never the storage key. This binary upload is separate from JSON controller POST requests.</p><p>Live, Livebox, Guild and Rocket inherit public Room methods. Gift inherits Live methods and its inherited Room methods. Their inherited createRoom/updateRoom/backgroundList/changeRoomSeatsLng (and index where not overridden) use the same contracts; Gift's inherited live actions follow the corresponding /api/live entries. Integrations should use the canonical /api/room and /api/live routes above. Constructors and internal helper methods are not API endpoints. GamePix configuration is documented separately in <a href="gamepix.html#gamepix-config">the GamePix API and setup guide</a>; these 110 entries cover non-game controllers.</p><p>Reconciliation: after reconnect, re-read room, wallet, messages and inventory through PHP. Socket broadcasts are transient notifications, not transaction receipts. Never retry purchases or gifts blindly after an ambiguous timeout; inspect payment/userLog or transaction records first.</p>''','compatibility')
    page('api-reference.html','PHP API endpoint reference',content)
    (DOC/'api-catalogue.json').write_text(json.dumps(entries,indent=2,ensure_ascii=False),encoding='utf-8')
    return len(entries)

if __name__ == '__main__':
    # Browser capture bytes are JPEG; preserve the original bytes and fix extensions.
    for capture in (DOC/'assets/screenshots').glob('admin-*.png'):
        if capture.read_bytes().startswith(b'\xff\xd8\xff'):
            capture.rename(capture.with_suffix('.jpg'))
    for source in (ROOT/'tools/documentation_sources').glob('*.html'):
        original = source.read_text(encoding='utf-8')
        corrected = re.sub(r'(admin-[a-z-]+)\.png', r'\1.jpg', original)
        if corrected != original:
            source.write_text(corrected, encoding='utf-8')
    print('API endpoint entries:',build_api())
    for name,title in {
        'customization':'App customization guide',
        'backend-deployment':'Backend production deployment',
        'gamepix':'GamePix games: setup and operation',
        'third-party-services':'Third-party services and buyer costs',
        'socket-events':'Socket.IO event catalogue',
        'room-disconnect':'Room disconnect grace period',
        'operations':'Background tasks and troubleshooting',
        'configuration':'Flutter configuration reference',
        'ios-release':'iOS configuration, signing and release',
        'admin-permissions':'Admin roles and permissions walkthrough',
        'webview-maintenance':'WebView dependency and upgrade notes',
        'visual-walkthroughs':'Visual feature walkthroughs',
    }.items():
        page(name+'.html',title,(ROOT/'tools/documentation_sources'/(name+'.html')).read_text(encoding='utf-8'))
    print('Built 12 offline reference pages and api-catalogue.json')
    summary_text = '''# AppChat Backend API Reference

The complete buyer reference is [PHP API endpoint reference](../../../documentation/api-reference.html).
It documents 110 canonical non-game controller endpoints, HTTP methods, headers, typed request fields,
defaults, source-derived success examples, error envelopes, upload requests and inherited aliases.
Examples are illustrative projections, not recorded production responses.

- [Socket.IO events and directions](../../../documentation/socket-events.html)
- [Background tasks and troubleshooting](../../../documentation/operations.html)
- [Admin roles and permission example](../../../documentation/admin-permissions.html)
- [Flutter configuration keys](../../../documentation/configuration.html)

Open documentation/index.html for installation. The documentation works offline.
GamePix is included; see [GamePix setup and configuration API](../../../documentation/gamepix.html).
For production see [backend deployment](../../../documentation/backend-deployment.html).
'''
    summary_path = PHP/'docs/API_SUMMARY.md'
    if summary_path.read_text(encoding='utf-8') != summary_text:
        summary_path.write_text(summary_text, encoding='utf-8')
    import subprocess, sys
    result = subprocess.run([sys.executable, str(ROOT/'tools/verify_review_documentation.py')], capture_output=True, text=True, encoding='utf-8')
    report = json.loads(result.stdout)
    (ROOT/'CodeCanyon_Package/Reviewer_Information/documentation-validation.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
    print(result.stdout)
    sys.exit(result.returncode)
