from pathlib import Path
import re, json
ROOT = Path(__file__).resolve().parents[1]
PHP = ROOT / 'CodeCanyon_Package/Main_File/backend/php_api'

def methods(path):
    text = path.read_text(encoding='utf-8-sig')
    matches = list(re.finditer(r'(public|protected|private)\s+function\s+(\w+)\s*\(', text))
    result = {}
    for i, m in enumerate(matches):
        result[m[2]] = (m[1], text[m.start():matches[i+1].start() if i+1 < len(matches) else len(text)].rstrip(), text[:m.start()].count('\n')+1)
    return result

if __name__ == '__main__':
    import sys
    selected = set(sys.argv[1:])
    for path in sorted((PHP / 'app/Controllers').glob('*AppController.php')):
        controller = path.name.removesuffix('AppController.php').lower()
        if selected and controller not in selected: continue
        for name, (visibility, body, line) in methods(path).items():
            if visibility != 'public': continue
            print(f'\n{controller}/{name}')
            for s in body.splitlines():
                if any(x in s for x in ['$_POST', '$_FILES', 'return $this->ok', 'return $this->fail', '$allowed =', 'requireAdmin', 'return $this->', "'event' =>"]):
                    print(s.strip())
