$ErrorActionPreference='Stop'
$app=Split-Path $PSScriptRoot -Parent
$backend='C:\xampp\htdocs\tomchat\tomchat_api'
$package=Join-Path $app 'CodeCanyon_Package/Main_File'
$count=0
function Same($source,$target) {
  $a=[IO.File]::ReadAllText($source).Replace("`r`n","`n").Replace('package:tom_chat/','package:app_chat/').Replace('extends TomChatController','extends AppChatController')
  $b=[IO.File]::ReadAllText($target).Replace("`r`n","`n")
  if($a -cne $b){throw "Catalog source mismatch: $target"};$script:count++
}
foreach($relative in @('app/Controllers/GameAppController.php','app/Services/HtmlGames/GameAuth.php','database/migrations/012_register_dice_game.sql','database/migrations/013_use_games_gid.php','tests/game_gid_migration_test.php','tests/game_catalog_test.php','tests/game_catalog_preview.php','tests/html_games_http_router.php','public/html-games/dice/emblem.svg')) {
 Same "$backend/$relative" "$package/backend/php_api/$relative"
}
foreach($relative in @('lib/features/rooms/models/game_model.dart','lib/features/rooms/controllers/room_game_controller.dart','test/game_catalog_test.dart')) {
 Same "$app/$relative" "$package/flutter_app/$relative"
}
Same "$backend/database/migrations/012_register_dice_game.sql" "$package/database/migrations/012_register_dice_game.sql"
Same "$backend/database/migrations/013_use_games_gid.php" "$package/database/migrations/013_use_games_gid.php"
foreach($root in @($app,"$package/flutter_app")) {
 $menu=[IO.File]::ReadAllText("$root/lib/features/rooms/bottom_sheets/games_bottom_sheet.dart")
 if(!$menu.Contains('itemCount: widget.controller.games.length,') -or !$menu.Contains('openHtmlGame(game)') -or $menu.Contains("openHtmlGame('dice')")){throw "Catalog routing missing or hardcoded: $root"}
}
if(![IO.File]::ReadAllText("$package/flutter_app/lib/features/rooms/bottom_sheets/basic_tool_bottom_sheet.dart").Contains('GamesBottomSheet.show')){throw 'Package tools must open catalog'}
$install=[IO.File]::ReadAllText("$package/database/appchat_clean_install.sql")
if(([regex]::Matches($install,'-- 012_register_dice_game.sql')).Count -ne 1){throw 'Clean-install catalog seed missing or duplicated'}
if($install.Contains('html_game_id') -or !$install.Contains('REFERENCES games(id)')){throw 'Clean installation must reference existing games IDs'}
foreach($root in @($backend,"$package/backend/php_api")) {
 if(Test-Path "$root/core/HtmlGamesConfig.php"){throw 'Removed registry still exists'}
 foreach($file in Get-ChildItem "$root/app/Services/HtmlGames","$root/public/html-games/shared" -File) {
  if([IO.File]::ReadAllText($file.FullName).Contains('html_game_id')){throw "Old runtime identifier: $($file.FullName)"}
 }
}
Write-Output "PASS: $count catalog counterparts match; both menus use API data; clean-install seed included once."
