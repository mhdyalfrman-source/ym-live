from pathlib import Path
from build_review_documentation import page

sources = Path(__file__).resolve().parent / 'documentation_sources'
socket_source = sources / 'socket-events.html'
text = socket_source.read_text(encoding='utf-8')
if 'room-disconnect.html' not in text:
    text += '\n<section><h2>Disconnect recovery</h2><p>The last socket disconnect schedules room cleanup after 60 seconds. Entering the same room through PHP startLive or enterRoom cancels its Redis job; socket reauthentication or entering another room preserves it. See <a href="room-disconnect.html">shared-secret configuration and callback protection</a>.</p></section>\n'
    socket_source.write_text(text, encoding='utf-8')
page('socket-events.html', 'Socket.IO event catalogue', text)
page('room-disconnect.html', 'Room disconnect grace period', (sources / 'room-disconnect.html').read_text(encoding='utf-8'))
print('Updated disconnect and socket documentation.')
