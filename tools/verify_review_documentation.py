"""Read-only checks of shipped documentation links and source coverage; no app tests."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import unquote, urlsplit
from collections import Counter
import json, re, sys
from inspect_doc_contracts import ROOT, PHP, methods

DOC = ROOT / 'CodeCanyon_Package/Main_File/documentation'
class Document(HTMLParser):
    def __init__(self, path):
        super().__init__()
        self.ids, self.links, self.images, self.text = [], [], [], []
        self.feed(path.read_text(encoding='utf-8-sig'))
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if a.get('id'): self.ids.append(a['id'])
        if a.get('href'): self.links.append(a['href'])
        if a.get('src'): self.links.append(a['src'])
        if tag == 'img': self.images.append(a)
    def handle_data(self, data): self.text.append(data)

errors = []
pages = {p.resolve(): Document(p) for p in DOC.glob('*.html')}
link_count = 0
for path, doc in pages.items():
    for ident, count in Counter(doc.ids).items():
        if count > 1: errors.append(f'{path.name}: duplicate id {ident}')
    for link in doc.links:
        url = urlsplit(link)
        if url.scheme or url.netloc: continue
        target = (path.parent / unquote(url.path)).resolve() if url.path else path
        link_count += 1
        if not target.is_file():
            errors.append(f'{path.name}: missing file {link}')
        elif url.fragment and target in pages and unquote(url.fragment) not in pages[target].ids:
            errors.append(f'{path.name}: missing anchor {link}')
    for img in doc.images:
        if not img.get('alt'): errors.append(f'{path.name}: image without alt {img.get("src")}')

entries = json.loads((DOC/'api-catalogue.json').read_text(encoding='utf-8'))
routes = [e['route'] for e in entries]
source_routes = set()
for path in (PHP/'app/Controllers').glob('*AppController.php'):
    if path.name == 'GameAppController.php': continue
    prefix = path.name.removesuffix('AppController.php').lower()
    for name, (visibility, _, _) in methods(path).items():
        if visibility == 'public' and not name.startswith('__'):
            source_routes.add(prefix + '/' + name)
if len(routes) != len(set(routes)): errors.append('Duplicate API catalogue routes')
if set(routes) != source_routes:
    errors.append(f'API coverage missing={sorted(source_routes-set(routes))}; extra={sorted(set(routes)-source_routes)}')
api = pages[(DOC/'api-reference.html').resolve()]
for entry in entries:
    if entry['route'].replace('/', '-') not in api.ids:
        errors.append('Missing endpoint article: '+entry['route'])
    if not all(entry.get(key) for key in ['purpose','fields']): errors.append('Incomplete route '+entry['route'])
    if not isinstance(entry.get('sample'), (dict,list)): errors.append('Invalid sample '+entry['route'])

cfg = (DOC.parent/'flutter_app/lib/config/appchat_config.dart').read_text(encoding='utf-8')
defines = set(re.findall(r"(?:String|int|bool)\.fromEnvironment\(\s*'([^']+)'", cfg))
config_doc = ' '.join(pages[(DOC/'configuration.html').resolve()].text)
for define in defines:
    if define not in config_doc: errors.append('Undocumented config define '+define)

socket_doc = ' '.join(pages[(DOC/'socket-events.html').resolve()].text)
events = set()
for path in (PHP/'app').rglob('*.php'):
    if path.name == 'GameAppController.php': continue
    events.update(re.findall(r"['\"]event['\"]\s*=>\s*['\"]([\w]+)['\"]",path.read_text(encoding='utf-8-sig')))
    events.update(re.findall(r"->publish(?:Socket)?\(\s*['\"](?:user|room|app)['\"]\s*,\s*['\"]([\w]+)['\"]",path.read_text(encoding='utf-8-sig')))
node = DOC.parent/'backend/node_server'
for path in [node/'s1.js',node/'src/handlers/user.js']:
    events.update(re.findall(r"\.emit\(['\"]([\w]+)['\"]",path.read_text(encoding='utf-8-sig')))
for event in events:
    if not re.search(r'\b'+re.escape(event)+r'\b',socket_doc): errors.append('Undocumented literal event '+event)

screens = list((DOC/'assets/screenshots').glob('admin-*.jpg'))
for path in screens:
    if not path.read_bytes().startswith(b'\xff\xd8\xff'): errors.append('Invalid JPEG '+path.name)
report = {
    'scope':'Static offline documentation checks only; not an API, mobile or iOS runtime test',
    'html_pages':len(pages), 'local_links_checked':link_count,
    'canonical_non_game_endpoints':len(routes), 'config_defines':sorted(defines),
    'source_literal_events_checked':sorted(events), 'admin_jpeg_captures':len(screens),
    'errors':errors, 'checks_passed':not errors,
    'submission_complete':False,
    'pending':['Actual mobile gift/recharge/store/VIP screenshots',
               'Populated staging moderation report and action screenshots',
               'macOS/iOS build and device verification',
               'Refresh final distribution archive after completing captures']
}
print(json.dumps(report,indent=2,ensure_ascii=False))
sys.exit(1 if errors else 0)
