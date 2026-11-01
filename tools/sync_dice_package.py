"""Copy only dice-related sources; preserve package naming and restricted wallet code."""
from pathlib import Path
import shutil
root=Path(__file__).resolve().parents[1]
backend=Path(r'C:\xampp\htdocs\tomchat\tomchat_api')
package=root/'CodeCanyon_Package/Main_File'
php=package/'backend/php_api'; app=package/'flutter_app'
files=['app/Services/HtmlGames/DiceGame.php','app/Services/HtmlGames/GameApi.php','public/html-games/shared/sdk.js','database/migrations/011_dice_game.sql','docs/dice-game.md','docs/html-games.md','tests/dice_test.php','tests/dice_preview.php','tests/dice_race_worker.php','tests/html_games_http_router.php','tests/html_games_sdk_test.js']
files += [str(p.relative_to(backend)).replace('\\','/') for p in (backend/'public/html-games/dice').iterdir() if p.is_file()]
for name in files:
    source=backend/name
    if not source.exists(): continue
    target=php/name; target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(source,target)
for name in ['html_game_screen.dart','html_game_overlay.dart']:
    target=app/'lib/features/html_games'/name
    target.write_text((root/'lib/features/html_games'/name).read_text(encoding='utf-8').replace('package:tom_chat/','package:app_chat/'),encoding='utf-8')
for name in ['html_game_overlay_test.dart']:
    (app/'test'/name).write_text((root/'test'/name).read_text(encoding='utf-8').replace('package:tom_chat/','package:app_chat/'),encoding='utf-8')
for name in ['dice_translations.json']:
    (app/'tools').mkdir(exist_ok=True);shutil.copyfile(root/'tools'/name,app/'tools'/name)
# Room menus remain edition-specific and read the existing game/list endpoint.
# Never insert a game card into Flutter from this synchronization script.
sql=(backend/'database/migrations/011_dice_game.sql').read_text(encoding='utf-8')
clean=package/'database/appchat_clean_install.sql'
if 'CREATE TABLE IF NOT EXISTS html_dice_rounds' not in clean.read_text(encoding='utf-8'):
    with clean.open('a',encoding='utf-8') as f:f.write('\n\n'+sql)
shutil.copyfile(backend/'database/migrations/011_dice_game.sql',package/'database/migrations/011_dice_game.sql')
for name in ['dice-game.md','html-games.md']:
    shutil.copyfile(backend/'docs'/name,package/'documentation'/name)
print('Dice counterparts synchronized; existing wallet sources untouched.')
