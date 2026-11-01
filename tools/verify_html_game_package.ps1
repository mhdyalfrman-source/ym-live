param([string]$Backend = 'C:\xampp\htdocs\tomchat\tomchat_api')
$ErrorActionPreference = 'Stop'
$app = Split-Path $PSScriptRoot -Parent
$package = Join-Path $app 'CodeCanyon_Package\Main_File'
$php = Join-Path $package 'backend\php_api'
$checked = 0
function Same([string]$source,[string]$target,[string]$from = '',[string]$to = '') {
  $left = [IO.File]::ReadAllText($source).Replace("`r`n","`n")
  if ($from) { $left=$left.Replace($from,$to) }
  $right = [IO.File]::ReadAllText($target).Replace("`r`n","`n")
  if ($left -cne $right) { throw "Foundation mismatch: $target" }
  $script:checked++
}
$files = @('public/html_games.php','public/html-games/.htaccess','public/html-games/shared/sdk.js','public/html-games/dev/index.php','public/html-games/dev/demo.js','database/migrations/009_html_games.sql','database/migrations/011_dice_game.sql','docs/html-games.md','docs/dice-game.md','docs/html-games.env.example','tests/html_games_test.php','tests/html_games_sdk_test.js','tests/html_games_http_router.php','tests/html_games_http_test.php','tests/dice_test.php','tests/dice_race_worker.php','tests/dice_preview.php')
$files += Get-ChildItem "$Backend/public/html-games/dice" -File | ForEach-Object { 'public/html-games/dice/' + $_.Name }
$files += Get-ChildItem "$Backend\app\Services\HtmlGames" -File | ForEach-Object { 'app/Services/HtmlGames/' + $_.Name }
foreach ($file in $files) { Same "$Backend/$file" "$php/$file" 'Core\TomChatDatabase' 'Core\AppChatDatabase' }
foreach ($file in @('lib/features/html_games/html_game_client.dart','lib/features/html_games/html_game_screen.dart','lib/features/html_games/html_game_overlay.dart','test/html_game_client_test.dart','test/html_game_overlay_test.dart','tools/dice_translations.json')) { Same "$app/$file" "$package/flutter_app/$file" 'package:tom_chat/' 'package:app_chat/' }
Same "$Backend/database/migrations/011_dice_game.sql" "$package/database/migrations/011_dice_game.sql"
Same "$Backend/docs/dice-game.md" "$package/documentation/dice-game.md"
foreach ($locale in @('ar','de','en','es','fr','hi','id','it','ku','tr','ur')) {
  $mainArb = Get-Content "$app/lib/l10n/arb/app_$locale.arb" -Raw | ConvertFrom-Json -AsHashtable
  $packageArb = Get-Content "$package/flutter_app/lib/l10n/arb/app_$locale.arb" -Raw | ConvertFrom-Json -AsHashtable
  foreach ($key in @('diceTitle','diceExit','diceLeave','diceStay','diceRetry','diceNetwork','diceAuth','diceLoading','diceClose')) {
    if (!$mainArb.$key -or $mainArb.$key -cne $packageArb.$key) { throw "Dice translation mismatch: $locale/$key" }
  }
}
if (![IO.File]::ReadAllText("$package/flutter_app/lib/features/rooms/bottom_sheets/basic_tool_bottom_sheet.dart").Contains('GamesBottomSheet.show')) { throw 'Missing packaged catalog entry' }
if (![IO.File]::ReadAllText("$app/lib/features/rooms/bottom_sheets/games_bottom_sheet.dart").Contains('openHtmlGame(game)')) { throw 'Missing catalog-based launcher' }
Same "$Backend/database/migrations/009_html_games.sql" "$package/database/migrations/009_html_games.sql"
Same "$Backend/docs/html-games.md" "$package/documentation/html-games.md"
$guards = @{
  'core/ApiSecurity.php' = 'WHERE ut.token = :token'
  'app/Controllers/AuthAppController.php' = 'INSERT INTO user_tokens (uid, token, web_token, device_id'
  'app/Admin/AdminPanel.php' = 'GameSettings::authorize($this->auth, $value)'
  'app/Controllers/AdminAppController.php' = 'GameSettings::authorize($auth,'
  'app/Controllers/LiveAppController.php' = '->legacyDebit($uid, $total, $cashback)'
  'app/Controllers/LiveboxAppController.php' = '->legacyDebit($uid, $coins)'
  'app/Controllers/ShopAppController.php' = 'if (!$purchase) return $this->fail($rs, ''not_enough_coins'')'
}
foreach ($file in $guards.Keys) {
  foreach ($root in @($Backend,$php)) {
    if (![IO.File]::ReadAllText("$root/$file").Contains($guards[$file])) { throw "Missing integration guard in $root/$file" }
  }
}
if (![IO.File]::ReadAllText("$php/app/Controllers/AppChatController.php").Contains('$cached[''coins''] = (int) $wallet[''coins''];')) { throw 'Missing packaged wallet cache overlay' }
if (![IO.File]::ReadAllText("$package/database/appchat_clean_install.sql").Contains('uq_user_web_token')) { throw 'Migration absent from clean install' }
Write-Output "PASS: $checked source counterparts match with intentional class/import renames; integration guards and clean-install migration present."
