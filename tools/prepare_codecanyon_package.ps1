param(
  [string]$FlutterRoot = "C:\projects\tom_chat",
  [string]$BackendRoot = "C:\xampp\htdocs\tomchat\tomchat_api",
  [string]$ReferencePackage = "C:\projects\bazaar_app\CodeCanyon_Package",
  [string]$PreviewSource = "D:\All_Projects\Real Projects\TomChat\codecanyon"
)

$ErrorActionPreference = "Stop"
$Version = "1.0.0"
$PackageRoot = Join-Path $FlutterRoot "CodeCanyon_Package"
$MainFile = Join-Path $PackageRoot "Main_File"
$FlutterPackage = Join-Path $MainFile "flutter_app"
$PhpPackage = Join-Path $MainFile "backend\php_api"
$NodePackage = Join-Path $MainFile "backend\node_server"
$DatabaseDir = Join-Path $MainFile "database"
$DocsDir = Join-Path $MainFile "documentation"
$ChangelogDir = Join-Path $MainFile "changelog"
$LicenseDir = Join-Path $MainFile "license_information"
$LivePreview = Join-Path $PackageRoot "LivePreview"
$Submission = Join-Path $PackageRoot "Submission_Metadata"
$Reviewer = Join-Path $PackageRoot "Reviewer_Information"
$Screens = Join-Path $PackageRoot "Preview_Screenshots"
$Inline = Join-Path $PackageRoot "Inline_Preview"
$Thumb = Join-Path $PackageRoot "Thumbnail"
$FinalZip = Join-Path $PackageRoot "Final_Zip"

function Ensure-Dir([string]$Path) {
  if (!(Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
  }
}

function Write-Utf8([string]$Path, [string]$Content) {
  Ensure-Dir (Split-Path -Parent $Path)
  [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Copy-Filtered {
  param(
    [string]$Source,
    [string]$Destination,
    [string[]]$SkipDirs,
    [string[]]$SkipFiles,
    [string[]]$SkipExtensions
  )
  Ensure-Dir $Destination
  Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
    $name = $_.Name
    if ($_.PSIsContainer) {
      if ($SkipDirs -contains $name) { return }
      Copy-Filtered -Source $_.FullName -Destination (Join-Path $Destination $name) -SkipDirs $SkipDirs -SkipFiles $SkipFiles -SkipExtensions $SkipExtensions
    } else {
      if ($SkipFiles -contains $name) { return }
      if ($SkipExtensions -contains $_.Extension.ToLowerInvariant()) { return }
      $destFile = Join-Path $Destination $name
      try {
        Copy-Item -LiteralPath $_.FullName -Destination $destFile -Force -ErrorAction Stop
      } catch {
        if (Test-Path -LiteralPath $destFile) {
          Write-Warning "Could not overwrite locked file $destFile; keeping existing copy."
        } else {
          throw
        }
      }
    }
  }
}

function Replace-InFile([string]$Path, [string]$Pattern, [string]$Replacement) {
  $text = [System.IO.File]::ReadAllText($Path)
  $text = [regex]::Replace($text, $Pattern, $Replacement)
  Write-Utf8 $Path $text
}

function Resize-Image {
  param([string]$Source, [string]$Destination, [int]$Width, [int]$Height, [switch]$Crop, [long]$Quality = 88)
  Add-Type -AssemblyName System.Drawing
  $img = [System.Drawing.Image]::FromFile($Source)
  try {
    if ($Crop) {
      $scale = [Math]::Max($Width / $img.Width, $Height / $img.Height)
    } else {
      $scale = [Math]::Min($Width / $img.Width, $Height / $img.Height)
    }
    $newW = [int][Math]::Ceiling($img.Width * $scale)
    $newH = [int][Math]::Ceiling($img.Height * $scale)
    $bmp = New-Object System.Drawing.Bitmap $Width, $Height
    try {
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      try {
        $g.Clear([System.Drawing.Color]::White)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $x = [int](($Width - $newW) / 2)
        $y = [int](($Height - $newH) / 2)
        $g.DrawImage($img, $x, $y, $newW, $newH)
      } finally { $g.Dispose() }
      Ensure-Dir (Split-Path -Parent $Destination)
      $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" } | Select-Object -First 1
      $params = New-Object System.Drawing.Imaging.EncoderParameters 1
      $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), $Quality
      $bmp.Save($Destination, $codec, $params)
    } finally { $bmp.Dispose() }
  } finally { $img.Dispose() }
}

function Get-PackageFiles([string]$Root) {
  Get-ChildItem -LiteralPath $Root -Recurse -Force -File | ForEach-Object {
    $_.FullName.Substring($Root.Length + 1).Replace('\','/')
  } | Sort-Object
}

if (Test-Path -LiteralPath $PackageRoot) {
  $resolved = (Resolve-Path -LiteralPath $PackageRoot).Path
  if ($resolved -ne (Join-Path (Resolve-Path -LiteralPath $FlutterRoot).Path "CodeCanyon_Package")) {
    throw "Refusing to remove unexpected path: $resolved"
  }
  Get-ChildItem -LiteralPath $PackageRoot -Force -ErrorAction SilentlyContinue | ForEach-Object {
    try {
      Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop
    } catch {
      Write-Warning "Could not remove stale package item $($_.FullName): $($_.Exception.Message)"
    }
  }
}

Ensure-Dir $PackageRoot
@($MainFile,$FlutterPackage,$PhpPackage,$NodePackage,$DatabaseDir,$DocsDir,$ChangelogDir,$LicenseDir,$LivePreview,$Submission,$Reviewer,$Screens,$Inline,$Thumb,$FinalZip) | ForEach-Object { Ensure-Dir $_ }
@("assets","css","js","images","images\screenshots") | ForEach-Object { Ensure-Dir (Join-Path $LivePreview $_) }

# Copy source trees into isolated buyer folders.
Copy-Filtered -Source $FlutterRoot -Destination $FlutterPackage `
  -SkipDirs @(".git",".dart_tool",".idea",".vscode","build","CodeCanyon_Package","ephemeral","tools") `
  -SkipFiles @("flutter_01.log","flutter_02.log","flutter_03.log","android\key.properties","key.properties","devtools_options.yaml") `
  -SkipExtensions @(".jks",".keystore",".apk",".aab",".ipa",".log")

Copy-Filtered -Source $BackendRoot -Destination $PhpPackage `
  -SkipDirs @(".git","vendor","node","node_modules","logs","cache","tmp","temp","uploads") `
  -SkipFiles @(".env","firebase-service-account.json","google-service.json","google-play-service-account.json") `
  -SkipExtensions @(".log",".bak",".tmp",".pyc")

Copy-Filtered -Source (Join-Path $BackendRoot "node") -Destination $NodePackage `
  -SkipDirs @(".git","node_modules","logs","cache","tmp","temp") `
  -SkipFiles @(".env") `
  -SkipExtensions @(".log",".bak",".tmp")

# Remove sensitive Flutter client files from the package copy.
@(
  (Join-Path $FlutterPackage "android\app\google-services.json"),
  (Join-Path $FlutterPackage "android\key.properties"),
  (Join-Path $FlutterPackage "android\app\tomchat.jks"),
  (Join-Path $FlutterPackage "android\local.properties"),
  (Join-Path $FlutterPackage "ios\Runner\GoogleService-Info.plist"),
  (Join-Path $FlutterPackage "tools"),
  (Join-Path $FlutterPackage "test"),
  (Join-Path $FlutterPackage ".dart_tool"),
  (Join-Path $FlutterPackage "build")
) | Where-Object { Test-Path -LiteralPath $_ } | ForEach-Object { Remove-Item -LiteralPath $_ -Recurse -Force }

$localPlugins = Join-Path $FlutterPackage "local_plugins"
if (Test-Path -LiteralPath $localPlugins) {
  Get-ChildItem -LiteralPath $localPlugins -Recurse -Directory -Filter test -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
  }
  Get-ChildItem -LiteralPath $localPlugins -Recurse -Directory -Filter pigeons -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
  }
}
Get-ChildItem -LiteralPath $FlutterPackage -Recurse -Directory -Filter ephemeral -ErrorAction SilentlyContinue | ForEach-Object {
  Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
}

# Keep only curated distributable seed media in public uploads.
$uploads = Join-Path $PhpPackage "public\uploads"
if (Test-Path -LiteralPath $uploads) {
  Get-ChildItem -LiteralPath $uploads -Force | Where-Object { $_.Name -ne "tomchat_seed_assets" } | ForEach-Object {
    Remove-Item -LiteralPath $_.FullName -Recurse -Force
  }
}

# Remove development-only SQL dumps, migration folders, and asset generation tools from the PHP source copy.
@(
  (Join-Path $PhpPackage "database"),
  (Join-Path $PhpPackage "tools"),
  (Join-Path $PhpPackage "tomchat_insert_assets_data.sql"),
  (Join-Path $PhpPackage "tomchat_assets_generation_report.md")
) | Where-Object { Test-Path -LiteralPath $_ } | ForEach-Object {
  Remove-Item -LiteralPath $_ -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Utf8 (Join-Path $PhpPackage ".well-known\assetlinks.json") @'
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "your.package.name",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99"
      ]
    }
  }
]
'@

$configDart = @'
class TomChatConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'TOMCHAT_API_BASE_URL',
    defaultValue: 'https://your-domain.com/',
  );

  static const String apiKey = String.fromEnvironment(
    'TOMCHAT_API_KEY',
    defaultValue: 'CHANGE_ME_TOMCHAT_API_KEY',
  );

  static const String defaultSocketHost = String.fromEnvironment(
    'TOMCHAT_SOCKET_HOST',
    defaultValue: 'socket.your-domain.com',
  );

  static const int defaultSocketPort = int.fromEnvironment(
    'TOMCHAT_SOCKET_PORT',
    defaultValue: 443,
  );

  static const String shareBaseUrl = String.fromEnvironment(
    'TOMCHAT_SHARE_BASE_URL',
    defaultValue: 'https://your-domain.com/share',
  );

  static String normalizedApiBaseUrl() {
    return apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/';
  }
}
'@
Write-Utf8 (Join-Path $FlutterPackage "lib\config\appchat_config.dart") $configDart

$callApi = Join-Path $FlutterPackage "lib\core\db\call_server_api.dart"
Replace-InFile $callApi "import 'package:tom_chat/statics_values.dart';" "import 'package:tom_chat/statics_values.dart';`r`nimport 'package:tom_chat/config/appchat_config.dart';"
Replace-InFile $callApi "static final String com = 'https://yoursoft\.pro/appchat/public/';" "static final String com = TomChatConfig.normalizedApiBaseUrl();"
Replace-InFile $callApi "static final String apiKey = `"no09-adbz-pat0-ndbe`";" "static final String apiKey = TomChatConfig.apiKey;"

$statics = Join-Path $FlutterPackage "lib\statics_values.dart"
Replace-InFile $statics "import 'package:in_app_purchase/in_app_purchase.dart';" "import 'package:in_app_purchase/in_app_purchase.dart';`r`nimport 'package:tom_chat/config/appchat_config.dart';"
Replace-InFile $statics "static String serverPath= 'http://10\.0\.2\.2:801/exam/';" "static String serverPath = TomChatConfig.normalizedApiBaseUrl();"
Replace-InFile $statics "static String socketPath= 'ws://10\.0\.2\.2:6001';" "static String socketPath = TomChatConfig.defaultSocketHost;"
Replace-InFile $statics "\s*// static String serverPath= 'http://10\.0\.2\.2:801/tom_chat/';\r?\n" "`r`n"
Replace-InFile $statics 'name: "Ahmed Alasmet"' 'name: "Guest User"'

$share = Join-Path $FlutterPackage "lib\core\helpers\app_share_helper.dart"
Replace-InFile $share "import 'package:tom_chat/features/rooms/room_screen.dart';" "import 'package:tom_chat/features/rooms/room_screen.dart';`r`nimport 'package:tom_chat/config/appchat_config.dart';"
Replace-InFile $share "return `"https://tomchat\.live/share/\$\{type\.name\}\$\{mapToQueryString\(\)\}`";" "return `"`${TomChatConfig.shareBaseUrl}/`${type.name}`${mapToQueryString()}`";"

$mainDart = Join-Path $FlutterPackage "lib\main.dart"
Replace-InFile $mainDart 'res\["socket_ip"\] \?\? "145\.223\.118\.169"' 'res["socket_ip"] ?? TomChatConfig.defaultSocketHost'
Replace-InFile $mainDart 'MyMath\.toInt\(res\["socket_port"\], defaultVal: 65530\)' 'MyMath.toInt(res["socket_port"], defaultVal: TomChatConfig.defaultSocketPort)'
if (([System.IO.File]::ReadAllText($mainDart)) -notmatch "tom_chat/config/appchat_config.dart") {
  Replace-InFile $mainDart "import 'package:tom_chat/controllers/socket_manager.dart';" "import 'package:tom_chat/controllers/socket_manager.dart';`r`nimport 'package:tom_chat/config/appchat_config.dart';"
}

$entryScreen = Join-Path $FlutterPackage "lib\features\entry\entry_screen.dart"
if (Test-Path $entryScreen) { Replace-InFile $entryScreen "https://yoursoft\.pro/appchat/privacy_policy\.html" "https://your-domain.com/privacy-policy" }
$settingScreen = Join-Path $FlutterPackage "lib\features\settings\setting_screen.dart"
if (Test-Path $settingScreen) { Replace-InFile $settingScreen "https://yoursoft\.pro/appchat/privacy_policy\.html" "https://your-domain.com/privacy-policy" }
$manifest = Join-Path $FlutterPackage "android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifest) { Replace-InFile $manifest 'android:host="tomchat\.live"' 'android:host="your-domain.com"' }
$linuxCMake = Join-Path $FlutterPackage "linux\CMakeLists.txt"
if (Test-Path $linuxCMake) { Replace-InFile $linuxCMake 'set\(APPLICATION_ID "com\.tomchat\.live"\)' 'set(APPLICATION_ID "com.example.tomchat")' }
$mainActivity = Join-Path $FlutterPackage "android\app\src\main\kotlin\com\example\tom_chat\MainActivity.kt"
if (Test-Path $mainActivity) { Replace-InFile $mainActivity '^package com\.tomchat\.live' 'package com.example.tomchat' }
$pubspec = Join-Path $FlutterPackage "pubspec.yaml"
if (Test-Path $pubspec) { Replace-InFile $pubspec 'com\.yoursoft\.quizme' 'com.example.tomchat' }

$firebaseOptions = @'
// Placeholder Firebase options for the marketplace package.
// Replace this file by running FlutterFire CLI for your own Firebase project.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Configure Firebase for this platform before building.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_FIREBASE_API_KEY',
    appId: 'YOUR_ANDROID_FIREBASE_APP_ID',
    messagingSenderId: 'YOUR_FIREBASE_MESSAGING_SENDER_ID',
    projectId: 'YOUR_FIREBASE_PROJECT_ID',
    storageBucket: 'YOUR_FIREBASE_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_FIREBASE_API_KEY',
    appId: 'YOUR_IOS_FIREBASE_APP_ID',
    messagingSenderId: 'YOUR_FIREBASE_MESSAGING_SENDER_ID',
    projectId: 'YOUR_FIREBASE_PROJECT_ID',
    storageBucket: 'YOUR_FIREBASE_STORAGE_BUCKET',
    iosBundleId: 'com.example.tomchat',
  );
}
'@
Write-Utf8 (Join-Path $FlutterPackage "lib\firebase_options.dart") $firebaseOptions

$androidBuild = Join-Path $FlutterPackage "android\app\build.gradle.kts"
$androidBuildText = [System.IO.File]::ReadAllText($androidBuild)
$androidBuildText = $androidBuildText -replace 'namespace = "com\.tomchat\.live"', 'namespace = "com.example.tomchat"'
$androidBuildText = $androidBuildText -replace 'applicationId = "com\.tomchat\.live"', 'applicationId = "com.example.tomchat"'
$androidBuildText = $androidBuildText -replace 'signingConfigs \{[\s\S]*?\n    \}\r?\n\r?\n    buildTypes \{[\s\S]*?\n    \}', @'
signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
'@
Write-Utf8 $androidBuild $androidBuildText

Write-Utf8 (Join-Path $FlutterPackage "android\key.properties.example") @'
# Copy this file to android/key.properties after creating your own upload keystore.
storePassword=CHANGE_ME_KEYSTORE_PASSWORD
keyPassword=CHANGE_ME_KEY_PASSWORD
keyAlias=upload
storeFile=../app/upload-keystore.jks
'@

$phpConfig = @'
<?php

function tomchat_load_env(string $path): void
{
    if (!is_file($path)) {
        return;
    }
    foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) {
            continue;
        }
        [$key, $value] = explode('=', $line, 2);
        $key = trim($key);
        $value = trim($value, " \t\n\r\0\x0B\"'");
        if ($key !== '' && getenv($key) === false) {
            putenv($key . '=' . $value);
            $_ENV[$key] = $value;
        }
    }
}

tomchat_load_env(dirname(__DIR__) . '/.env');

function tomchat_env(string $key, mixed $default = null): mixed
{
    $value = getenv($key);
    return $value === false || $value === '' ? $default : $value;
}

return [
    'base_url' => tomchat_env('APP_URL', 'https://your-domain.com'),
    'base_path' => tomchat_env('APP_BASE_PATH', ''),
    'default_controller' => 'helper',
    'default_method' => 'index',
    'SQL_HOST' => tomchat_env('DB_HOST', '127.0.0.1'),
    'SQL_USER' => tomchat_env('DB_USERNAME', 'tomchat_user'),
    'SQL_PASS' => tomchat_env('DB_PASSWORD', 'CHANGE_ME_DB_PASSWORD'),
    'SQL_CHARSET' => tomchat_env('DB_CHARSET', 'utf8mb4'),
    'SQL_PORT' => tomchat_env('DB_PORT', '3306'),
    'SQL_DB' => tomchat_env('DB_DATABASE', 'tomchat_db'),
    'API_KEY' => tomchat_env('API_KEY', 'CHANGE_ME_TOMCHAT_API_KEY'),
    'ROOM_DISCONNECT_SECRET' => tomchat_env('ROOM_DISCONNECT_SECRET', ''),
    'LEGACY_SQL_HOST' => tomchat_env('DB_HOST', '127.0.0.1'),
    'LEGACY_SQL_USER' => tomchat_env('DB_USERNAME', 'tomchat_user'),
    'LEGACY_SQL_PASS' => tomchat_env('DB_PASSWORD', 'CHANGE_ME_DB_PASSWORD'),
    'LEGACY_SQL_CHARSET' => tomchat_env('DB_CHARSET', 'utf8mb4'),
    'LEGACY_SQL_PORT' => tomchat_env('DB_PORT', '3306'),
    'LEGACY_SQL_DB' => tomchat_env('DB_DATABASE', 'tomchat_db'),
    'REDIS_HOST' => tomchat_env('REDIS_HOST', '127.0.0.1'),
    'REDIS_PORT' => (int) tomchat_env('REDIS_PORT', 6379),
    'REDIS_PASSWORD' => tomchat_env('REDIS_PASSWORD', ''),
    'SOCKET_IP' => tomchat_env('SOCKET_PUBLIC_HOST', 'socket.your-domain.com'),
    'SOCKET_PORT' => (int) tomchat_env('SOCKET_PUBLIC_PORT', 443),
    'AGORA_APP_ID' => tomchat_env('AGORA_APP_ID', 'CHANGE_ME_AGORA_APP_ID'),
    'AGORA_APP_CERTIFICATE' => tomchat_env('AGORA_APP_CERTIFICATE', 'CHANGE_ME_AGORA_APP_CERTIFICATE'),
    'AGORA_TOKEN_TTL' => (int) tomchat_env('AGORA_TOKEN_TTL', 3600),
    'BUNNY_STORAGE_ZONE' => tomchat_env('BUNNY_STORAGE_ZONE', ''),
    'BUNNY_STORAGE_REGION' => tomchat_env('BUNNY_STORAGE_REGION', 'de'),
    'BUNNY_STORAGE_API_KEY' => tomchat_env('BUNNY_STORAGE_API_KEY', ''),
    'BUNNY_CDN_URL' => tomchat_env('BUNNY_CDN_URL', ''),
    'APP_TIMEZONE' => tomchat_env('APP_TIMEZONE', 'UTC'),
    'APP_DEBUG' => tomchat_env('APP_DEBUG', 'false') === 'true',
    'FIREBASE_PROJECT_ID' => tomchat_env('FIREBASE_PROJECT_ID', ''),
    'FIREBASE_SERVICE_ACCOUNT_JSON' => tomchat_env('FIREBASE_SERVICE_ACCOUNT_JSON', dirname(__DIR__) . '/secure/firebase-service-account.json'),
    'GOOGLE_PLAY_PACKAGE_NAME' => tomchat_env('GOOGLE_PLAY_PACKAGE_NAME', 'com.example.tomchat'),
    'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON' => tomchat_env('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON', dirname(__DIR__) . '/secure/google-play-service-account.json'),
    'WITHDRAWAL_ACCOUNT_TYPES' => [
        '1' => ['id' => 1, 'name' => tomchat_env('WITHDRAWAL_TYPE_1_NAME', 'PayPal'), 'icon' => tomchat_env('WITHDRAWAL_TYPE_1_ICON', '')],
        '2' => ['id' => 2, 'name' => tomchat_env('WITHDRAWAL_TYPE_2_NAME', 'USDT'), 'icon' => tomchat_env('WITHDRAWAL_TYPE_2_ICON', '')],
        '3' => ['id' => 3, 'name' => tomchat_env('WITHDRAWAL_TYPE_3_NAME', 'Bank Transfer'), 'icon' => tomchat_env('WITHDRAWAL_TYPE_3_ICON', '')],
    ],
    'BUSINESS' => [
        'coins_per_100_usd' => (int) tomchat_env('COINS_PER_100_USD', 1500000),
        'agency_coins_per_100_usd' => (int) tomchat_env('AGENCY_COINS_PER_100_USD', 1500000),
        'diamond_coin_multiplier' => (int) tomchat_env('DIAMOND_COIN_MULTIPLIER', 6),
        'gift_owner_percent' => (int) tomchat_env('GIFT_OWNER_PERCENT', 50),
        'gift_app_percent' => (int) tomchat_env('GIFT_APP_PERCENT', 50),
        'cash_min' => (float) tomchat_env('CASH_MIN', 1),
        'cash_start' => (int) tomchat_env('CASH_START_DAY', 1),
        'cash_end' => (int) tomchat_env('CASH_END_DAY', 31),
        'cash_max_times' => (int) tomchat_env('CASH_MAX_TIMES', 10),
        'lucky_cashback_min_percent' => 0,
        'lucky_cashback_max_percent' => 200,
        'lucky_cashback_common_cap_percent' => 50,
        'lucky_cashback_high_roll_rate' => 3,
        'default_room_seats' => 9,
        'default_seat_state' => 0,
    ],
];
'@
Write-Utf8 (Join-Path $PhpPackage "core\Config.php") $phpConfig

$router = Join-Path $PhpPackage "core\Router.php"
$routerText = [System.IO.File]::ReadAllText($router)
$basePathReplacement = @'
$requestPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
        $scriptDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
        $configuredBasePath = rtrim((string) ($this->config['base_path'] ?? ''), '/');
        $basePath = $configuredBasePath !== '' ? $configuredBasePath : ($scriptDir === '/' ? '' : $scriptDir);
        $requestUri = $basePath !== '' && str_starts_with($requestPath, $basePath)
            ? substr($requestPath, strlen($basePath))
            : $requestPath;
'@
$routerText = [regex]::Replace($routerText, '\$basePath = .*?\r?\n\s*\$requestUri = str_replace\(\$basePath, '''', \$_SERVER\[''REQUEST_URI''\]\);', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $basePathReplacement })
$routerText = [regex]::Replace($routerText, '\$rawBasePath = ''/delivery/new_api/public'';\r?\n\s*\$rawRequestUri = str_replace\(\$rawBasePath, '''', \$_SERVER\[''REQUEST_URI''\]\);\r?\n\s*\$rawFirstPart = explode\(''/'', trim\(explode\("\?", \$rawRequestUri\)\[0\], ''/''\)\)\[0\] \?\? '''';\r?\n\s*\$isApi = strtolower\(\$rawFirstPart\) === ''api'';', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) '$isApi = strtolower($this->urlParts[0] ?? "") === "api";' })
$normalizeReplacement = '$isApi = strtolower($this->urlParts[0] ?? "") === "api";' + "`r`n        " + '$this->urlParts = $apiSecurity->normalizeApiUrlParts($this->urlParts);'
$routerText = [regex]::Replace($routerText, '\$this->urlParts = \$apiSecurity->normalizeApiUrlParts\(\$this->urlParts\);', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $normalizeReplacement })
$safeTryCatch = @'
try {
                    $controllerInstance = new $controllerClass($appLanguageCls);
                    $rs = $this->callControllerMethod($controllerInstance, $methodName, $isPost, $rs, $user);
                } catch (\Exception $e) {
                    $exceptionCode = (int) $e->getCode();
                    $rs['code'] = $exceptionCode >= 400 && $exceptionCode < 600 ? $exceptionCode : 500;
                    $rs['err'] = [$e->getMessage()];
                    if (!empty($this->config['APP_DEBUG'])) {
                        $rs['notifications'] = [[
                            'type' => 'danger',
                            'content' => [
                                'title' => 'Error',
                                'message' => $e->getMessage() . ' (File: ' . $e->getFile() . ':' . $e->getLine() . ')'
                            ]
                        ]];
                    }
                    error_log("Controller Error: " . $e->getMessage());
                    error_log("File: " . $e->getFile() . ":" . $e->getLine());
                    error_log("Trace: " . $e->getTraceAsString());
                } catch (\Error $e) {
                    $rs['code'] = 500;
                    $rs['err'] = [$e->getMessage()];
                    if (!empty($this->config['APP_DEBUG'])) {
                        $rs['notifications'] = [[
                            'type' => 'danger',
                            'content' => [
                                'title' => 'Fatal Error',
                                'message' => $e->getMessage() . ' (File: ' . $e->getFile() . ':' . $e->getLine() . ')'
                            ]
                        ]];
                    }
                    error_log("Fatal Error: " . $e->getMessage());
                    error_log("File: " . $e->getFile() . ":" . $e->getLine());
                    error_log("Trace: " . $e->getTraceAsString());
                }
            } else {
'@
$tryCatchRegex = [regex]::new('try \{\s*\$controllerInstance = new \$controllerClass\(\$appLanguageCls\);[\s\S]*?\r?\n\s*\}\s*else\s*\{')
$routerText = $tryCatchRegex.Replace($routerText, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $safeTryCatch }, 1)
Write-Utf8 $router $routerText

$cash = Join-Path $PhpPackage "app\Controllers\CashAppController.php"
$cashText = [System.IO.File]::ReadAllText($cash)
$cashText = $cashText -replace "'types' => \[\s*'1' => \['id' => 1, 'name' => 'PayPal', 'icon' => ''\],\s*'2' => \['id' => 2, 'name' => 'USDT', 'icon' => ''\],\s*\],", "'types' => `$this->withdrawalAccountTypes(),"
$cashText = $cashText -replace "private function cashAccountPayload", @'
private function withdrawalAccountTypes(): array
    {
        $setting = (string) $this->appSetting('withdrawal_account_types', '');
        if ($setting !== '') {
            $decoded = json_decode($setting, true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }
        return $this->config['WITHDRAWAL_ACCOUNT_TYPES'] ?? [];
    }

    private function cashAccountPayload
'@
Write-Utf8 $cash $cashText

$nodeConfig = @'
import './env.js';

const toInt = (value, fallback) => {
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
};

const allowedOrigins = (process.env.SOCKET_ALLOWED_ORIGINS || '*')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

export default {
  PORT: toInt(process.env.PORT || process.env.SOCKET_PORT, 65535),
  IP: process.env.SOCKET_BIND_IP || '127.0.0.1',
  HOST: process.env.REDIS_HOST || '127.0.0.1',
  URI: process.env.PHP_API_URL || 'https://your-domain.com',
  TOKEN: process.env.SOCKET_SHARED_TOKEN || 'CHANGE_ME_SOCKET_SHARED_TOKEN',
  API_KEY: process.env.API_KEY || 'CHANGE_ME_TOMCHAT_API_KEY',
  ROOM_DISCONNECT_SECRET: process.env.ROOM_DISCONNECT_SECRET || '',
  REDIS_PORT: toInt(process.env.REDIS_PORT, 6379),
  REDIS_PW: process.env.REDIS_PASSWORD || '',
  ALLOWED_ORIGINS: allowedOrigins,
};
'@
Write-Utf8 (Join-Path $NodePackage "src\data\config.js") $nodeConfig
$s1 = Join-Path $NodePackage "s1.js"
Replace-InFile $s1 "cors: \{ origin: '\*', methods: \['GET', 'POST'\] \}" "cors: { origin: config.ALLOWED_ORIGINS.includes('*') ? '*' : config.ALLOWED_ORIGINS, methods: ['GET', 'POST'] }"

$phpEnv = @'
# TomChat PHP API environment example
APP_URL=https://your-domain.com
APP_BASE_PATH=
APP_TIMEZONE=UTC
APP_DEBUG=false

DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=tomchat_db
DB_USERNAME=tomchat_user
DB_PASSWORD=CHANGE_ME_DB_PASSWORD
DB_CHARSET=utf8mb4

API_KEY=CHANGE_ME_TOMCHAT_API_KEY
ROOM_DISCONNECT_SECRET=CHANGE_ME_GENERATE_64_HEX_CHARACTERS

REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=

SOCKET_PUBLIC_HOST=socket.your-domain.com
SOCKET_PUBLIC_PORT=443

AGORA_APP_ID=CHANGE_ME_AGORA_APP_ID
AGORA_APP_CERTIFICATE=CHANGE_ME_AGORA_APP_CERTIFICATE
AGORA_TOKEN_TTL=3600

BUNNY_STORAGE_ZONE=
BUNNY_STORAGE_REGION=de
BUNNY_STORAGE_API_KEY=
BUNNY_CDN_URL=

FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_SERVICE_ACCOUNT_JSON=/secure/path/firebase-service-account.json

GOOGLE_PLAY_PACKAGE_NAME=com.example.tomchat
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=/secure/path/google-play-service-account.json

COINS_PER_100_USD=1500000
AGENCY_COINS_PER_100_USD=1500000
DIAMOND_COIN_MULTIPLIER=6
GIFT_OWNER_PERCENT=50
GIFT_APP_PERCENT=50
CASH_MIN=1
CASH_START_DAY=1
CASH_END_DAY=31
CASH_MAX_TIMES=10

WITHDRAWAL_TYPE_1_NAME=PayPal
WITHDRAWAL_TYPE_1_ICON=
WITHDRAWAL_TYPE_2_NAME=USDT
WITHDRAWAL_TYPE_2_ICON=
WITHDRAWAL_TYPE_3_NAME=Bank Transfer
WITHDRAWAL_TYPE_3_ICON=
'@
Write-Utf8 (Join-Path $PhpPackage ".env.example") $phpEnv

$nodeEnv = @'
# TomChat Socket.IO server environment example
PORT=65535
SOCKET_PORT=65535
SOCKET_BIND_IP=127.0.0.1
SOCKET_ALLOWED_ORIGINS=https://your-domain.com

PHP_API_URL=https://your-domain.com
API_KEY=CHANGE_ME_TOMCHAT_API_KEY
SOCKET_SHARED_TOKEN=CHANGE_ME_SOCKET_SHARED_TOKEN
ROOM_DISCONNECT_SECRET=CHANGE_ME_GENERATE_64_HEX_CHARACTERS

REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=
'@
Write-Utf8 (Join-Path $NodePackage ".env.example") $nodeEnv

Write-Utf8 (Join-Path $NodePackage "ecosystem.config.cjs") @'
module.exports = {
  apps: [{
    name: 'tomchat-socket',
    script: 's1.js',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: '65535'
    }
  }]
};
'@

# Build the single clean-install SQL file.
$schema = [System.IO.File]::ReadAllText((Join-Path $BackendRoot "database\tomchat_db.sql"))
$adminSchema = [System.IO.File]::ReadAllText((Join-Path $BackendRoot "database\migrations\004_admin_dashboard.sql"))
$assetSeed = Get-Content -LiteralPath (Join-Path $BackendRoot "tomchat_insert_assets_data.sql")
$selectedSeed = $assetSeed | Where-Object {
  ($_ -match "INSERT INTO ``emojis``" -and $_ -match "VALUES \((16|17|18|19|20|21|22|23|24|25),") -or
  ($_ -match "INSERT INTO ``gifts``" -and $_ -match "VALUES \((3|9|11|19|20|25|31|47|52|54),") -or
  ($_ -match "INSERT INTO ``store_items``" -and $_ -match "VALUES \((1|2|3|4|5|6|7|8|72|78),") -or
  ($_ -match "INSERT INTO ``vip_packages``" -and $_ -match "VALUES \((1|2|3),") -or
  ($_ -match "INSERT INTO ``vip_privileges``" -and $_ -match "VALUES \([0-9]+, (1|2|3),") -or
  ($_ -match "INSERT INTO ``rocket_levels``" -and $_ -match "VALUES \((1|2|3),")
} | ForEach-Object { $_ -replace "https://yoursoft\.pro/appchat/public", "https://your-domain.com" }

$demoHash = '$2y$10$9DRAtde/UoMlJn0oJfmUJuT0tqT2UB7vPZ.2qtK7j40iS2.hqtq3a'
$demoSql = @"

-- TomChat curated marketplace seed data.
-- Default temporary password for all demo accounts: TomChat@123
SET FOREIGN_KEY_CHECKS=0;

DELETE FROM user_tokens;
DELETE FROM room_seats;
DELETE FROM room_members;
DELETE FROM rooms;
DELETE FROM cash_accounts;
DELETE FROM wallet_transactions;
DELETE FROM payment_logs;
DELETE FROM recharge_requests;
DELETE FROM user_relations;
DELETE FROM users;

INSERT INTO users (id, username, name, email, password_hash, pos, role, type, state, avatar, country, coins, diamond, dollar_earnings, total_points, gifter_points_total, anchor_points_total, recharge_points_total, followers_count, following_count, language, created_at, updated_at) VALUES
(1, 'demo_admin_user', 'Demo Admin User', 'admin.user@example.com', '$demoHash', 1, 9, 1, 9, 'https://your-domain.com/uploads/demo/avatar-admin.png', 'US', 50000, 2500, 100.00000000, 12000, 5000, 3000, 4000, 2, 1, 'en', UTC_TIMESTAMP(), UTC_TIMESTAMP()),
(2, 'demo_alex', 'Alex Demo', 'alex.demo@example.com', '$demoHash', 3, 5, 1, 9, 'https://your-domain.com/uploads/demo/avatar-alex.png', 'US', 35000, 1200, 50.00000000, 8000, 3200, 2200, 2600, 1, 2, 'en', UTC_TIMESTAMP(), UTC_TIMESTAMP()),
(3, 'demo_sophia', 'Sophia Demo', 'sophia.demo@example.com', '$demoHash', 3, 5, 2, 9, 'https://your-domain.com/uploads/demo/avatar-sophia.png', 'GB', 25000, 900, 25.00000000, 6000, 2400, 1800, 1800, 1, 1, 'en', UTC_TIMESTAMP(), UTC_TIMESTAMP());

INSERT INTO user_relations (uid, target_uid, type, created_at) VALUES
(2, 3, 'follow', UTC_TIMESTAMP()),
(3, 2, 'follow', UTC_TIMESTAMP());

INSERT INTO rooms (id, uid, title, type, state, icon, bg, seat_count, is_live, coin_number, total_points, created_at, updated_at) VALUES
(1, 2, 'Demo Lounge', 0, 9, 'https://your-domain.com/uploads/demo/room-demo.png', '', 9, 0, 0, 1200, UTC_TIMESTAMP(), UTC_TIMESTAMP()),
(2, 3, 'Music Demo Room', 0, 9, 'https://your-domain.com/uploads/demo/room-music.png', '', 9, 0, 0, 900, UTC_TIMESTAMP(), UTC_TIMESTAMP());

INSERT INTO room_seats (rid, seat_index, uid, state, mic_state, created_at, updated_at)
SELECT 1, n, NULL, 0, 0, UTC_TIMESTAMP(), UTC_TIMESTAMP()
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) seats;

INSERT INTO room_seats (rid, seat_index, uid, state, mic_state, created_at, updated_at)
SELECT 2, n, NULL, 0, 0, UTC_TIMESTAMP(), UTC_TIMESTAMP()
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) seats;

INSERT INTO cash_accounts (id, uid, type, name, account, created_at) VALUES
(1, 2, '1', 'Demo PayPal', 'demo-paypal@example.com', UTC_TIMESTAMP()),
(2, 3, '2', 'Demo USDT Wallet', 'TRON_DEMO_WALLET_ADDRESS', UTC_TIMESTAMP());

INSERT INTO recharge_packages (id, product_id, android_product_id, ios_product_id, name, coins, diamonds, usd_price, state, sort_order) VALUES
(1, 'tomchat_coins_1000', 'tomchat_coins_1000', 'tomchat_coins_1000_ios', '1,000 Coins', 1000, 0, 0.99, 9, 1),
(2, 'tomchat_coins_5000', 'tomchat_coins_5000', 'tomchat_coins_5000_ios', '5,000 Coins', 5000, 0, 4.99, 9, 2),
(3, 'tomchat_coins_12000', 'tomchat_coins_12000', 'tomchat_coins_12000_ios', '12,000 Coins', 12000, 0, 9.99, 9, 3)
ON DUPLICATE KEY UPDATE android_product_id=VALUES(android_product_id), ios_product_id=VALUES(ios_product_id), name=VALUES(name), coins=VALUES(coins), diamonds=VALUES(diamonds), usd_price=VALUES(usd_price), state=VALUES(state), sort_order=VALUES(sort_order);

INSERT INTO levels (type, lvl, points, icon, created_at) VALUES
('gifter', 1, 0, '', UTC_TIMESTAMP()), ('gifter', 2, 1000, '', UTC_TIMESTAMP()), ('gifter', 3, 5000, '', UTC_TIMESTAMP()),
('anchor', 1, 0, '', UTC_TIMESTAMP()), ('anchor', 2, 1000, '', UTC_TIMESTAMP()), ('anchor', 3, 5000, '', UTC_TIMESTAMP()),
('charge', 1, 0, '', UTC_TIMESTAMP()), ('charge', 2, 1000, '', UTC_TIMESTAMP()), ('charge', 3, 5000, '', UTC_TIMESTAMP())
ON DUPLICATE KEY UPDATE points=VALUES(points), icon=VALUES(icon);

INSERT INTO app_settings (setting_key, group_key, setting_value, is_secret, updated_at) VALUES
('withdrawal_account_types', 'payments', '{\"1\":{\"id\":1,\"name\":\"PayPal\",\"icon\":\"\"},\"2\":{\"id\":2,\"name\":\"USDT\",\"icon\":\"\"},\"3\":{\"id\":3,\"name\":\"Bank Transfer\",\"icon\":\"\"}}', 0, UTC_TIMESTAMP()),
('firebase_project_id', 'notifications', 'your-firebase-project-id', 0, UTC_TIMESTAMP()),
('firebase_service_account_json', 'notifications', '/secure/path/firebase-service-account.json', 1, UTC_TIMESTAMP()),
('google_play_package_name', 'payments', 'com.example.tomchat', 0, UTC_TIMESTAMP()),
('google_play_service_account_json', 'payments', '/secure/path/google-play-service-account.json', 1, UTC_TIMESTAMP()),
('image_storage_driver', 'uploads', 'local', 0, UTC_TIMESTAMP())
ON DUPLICATE KEY UPDATE setting_value=VALUES(setting_value), is_secret=VALUES(is_secret), updated_at=VALUES(updated_at);

SET FOREIGN_KEY_CHECKS=1;
"@

$sqlOut = @"
-- TomChat clean-install database
-- Version: $Version
-- Import this single file into a new empty MySQL/MariaDB database.

$schema

$adminSchema

-- Curated included digital assets: 10 emojis, 5 user frames, 5 room entry animations, 3 VIP levels, 3 Rocket levels.
$($selectedSeed -join "`r`n")

$demoSql
"@
$sqlOut = $sqlOut -replace "https://yoursoft\.pro/appchat/public", "https://your-domain.com"
Write-Utf8 (Join-Path $DatabaseDir "appchat_clean_install.sql") $sqlOut

function New-DemoImage([string]$Path, [string]$Text, [int]$Width = 512, [int]$Height = 512) {
  Add-Type -AssemblyName System.Drawing
  Ensure-Dir (Split-Path -Parent $Path)
  $bmp = New-Object System.Drawing.Bitmap $Width, $Height
  try {
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
      $g.Clear([System.Drawing.Color]::FromArgb(255, 245, 246, 248))
      $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 239, 91, 0))
      $font = New-Object System.Drawing.Font("Arial", 44, [System.Drawing.FontStyle]::Bold)
      $format = New-Object System.Drawing.StringFormat
      $format.Alignment = [System.Drawing.StringAlignment]::Center
      $format.LineAlignment = [System.Drawing.StringAlignment]::Center
      $rect = New-Object System.Drawing.RectangleF 0, 0, $Width, $Height
      $g.DrawString($Text, $font, $brush, $rect, $format)
      $font.Dispose()
      $brush.Dispose()
      $format.Dispose()
    } finally { $g.Dispose() }
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally { $bmp.Dispose() }
}

$uploadSourceRoot = Join-Path $BackendRoot "public\uploads"
$uploadDestRoot = Join-Path $PhpPackage "public\uploads"
Ensure-Dir $uploadDestRoot
$referencedUploads = [regex]::Matches($sqlOut, "https://your-domain\.com/uploads/([^'`"]+)") | ForEach-Object {
  $_.Groups[1].Value -replace '/', '\'
} | Sort-Object -Unique

foreach ($relativeUpload in $referencedUploads) {
  $destUpload = Join-Path $uploadDestRoot $relativeUpload
  $sourceUpload = Join-Path $uploadSourceRoot $relativeUpload
  if (Test-Path -LiteralPath $sourceUpload) {
    Ensure-Dir (Split-Path -Parent $destUpload)
    try {
      Copy-Item -LiteralPath $sourceUpload -Destination $destUpload -Force -ErrorAction Stop
    } catch {
      if (Test-Path -LiteralPath $destUpload) {
        Write-Warning "Could not overwrite locked referenced upload $destUpload; keeping existing copy."
      } else {
        throw
      }
    }
  } elseif ($relativeUpload -like "demo\*.png") {
    $label = [System.IO.Path]::GetFileNameWithoutExtension($relativeUpload).Replace("avatar-","").Replace("room-","")
    New-DemoImage -Path $destUpload -Text $label.ToUpperInvariant()
  } else {
    Write-Warning "Referenced upload asset was not found: $relativeUpload"
  }
}

# Buyer-facing documentation.
$readme = @"
TomChat v$Version - CodeCanyon Main File

Start here:
1. Import database/appchat_clean_install.sql into a new MySQL database.
2. Upload backend/php_api to your PHP hosting and copy backend/php_api/.env.example to .env.
3. Upload backend/node_server to a Node.js-capable server and copy backend/node_server/.env.example to .env.
4. Run composer install inside backend/php_api.
5. Run npm install inside backend/node_server.
6. Configure Flutter in flutter_app/lib/config/appchat_config.dart or use --dart-define values.
7. Replace Firebase client files and private server JSON credentials with your own files.

Documentation: documentation/index.html
Changelog: changelog/changelog.html
Temporary demo password: TomChat@123
"@
Write-Utf8 (Join-Path $MainFile "README.txt") $readme
Write-Utf8 (Join-Path $DocsDir "README.md") $readme

$docsHtml = @"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>TomChat Documentation</title>
  <link rel="stylesheet" href="assets/documentation.css">
</head>
<body>
  <aside>
    <strong>TomChat $Version</strong>
    <input id="search" placeholder="Search documentation">
    <nav id="toc"></nav>
  </aside>
  <main>
    <section><h1>TomChat Installation Documentation</h1><p>TomChat is a Flutter social voice-room application with PHP API, admin dashboard, MySQL database, Redis, Socket.IO real-time server, Firebase notifications, Agora audio, wallet, withdrawals, gifts, store assets, VIP levels, and Rocket levels.</p><p>The package includes Flutter source, PHP API source, Node.js Socket.IO source, one clean SQL installer, documentation, changelog, license notes, reviewer information, and CodeCanyon metadata.</p></section>
    <section><h2>Included Files</h2><ul><li><code>flutter_app</code>: Flutter source.</li><li><code>backend/php_api</code>: PHP API, admin panel, upload service, Agora token code, Firebase push code, Google Play verification.</li><li><code>backend/node_server</code>: Socket.IO server.</li><li><code>database/appchat_clean_install.sql</code>: complete clean-install database.</li><li><code>documentation</code>, <code>changelog</code>, <code>license_information</code>.</li></ul></section>
    <section><h2>Product Features</h2><p>Verified source features include public/private voice rooms, multi-seat rooms, text messages, user profiles, follows, profile visits, wallet balances, Google Play consumable purchase verification, withdrawals, agencies, gifts, store items, emojis, VIP packages, Rocket ranking levels, Firebase Cloud Messaging, Agora RTC, Redis presence/cache/pub-sub, and an admin dashboard for users, rooms, content, store, VIP, settings, transactions, reports, roles, and audit logs.</p><p>The standard included digital asset pack contains exactly 10 emojis, 5 user frames, 5 room entry animations, 3 VIP levels, and 3 Rocket levels. Additional emojis, frames, entry animations, VIP levels, Rocket levels, custom assets, and customization services can be purchased separately by contacting the seller. The default package remains complete and usable with the included base assets.</p></section>
    <section><h2>Package Structure</h2><pre><code>Main_File/
  flutter_app/
  backend/php_api/
  backend/node_server/
  database/appchat_clean_install.sql
  documentation/
  changelog/
  license_information/
LivePreview/
Preview_Screenshots/
Inline_Preview/
Thumbnail/
Reviewer_Information/
Submission_Metadata/
Final_Zip/</code></pre></section>
    <section><h2>Server Requirements</h2><ul><li>PHP 8.0 or newer with PDO MySQL, mbstring, json, openssl, curl, fileinfo, gd or imagick, and session support.</li><li>Composer 2.x.</li><li>MySQL 8+ or MariaDB 10.6+ using utf8mb4.</li><li>Node.js 18+ and npm 9+ for the Socket.IO server.</li><li>Redis 6+ for presence, room state, user cache, token lookup, and pub/sub.</li><li>HTTPS domain for API and WSS reverse proxy for sockets.</li><li>Agora project, Firebase project, Google Play Console app, and optional Bunny.net storage credentials.</li></ul></section>
    <section><h2>Database Installation</h2><ol><li>Create an empty database named <code>tomchat_db</code> or edit the database name at the top of the SQL file.</li><li>Import <code>Main_File/database/appchat_clean_install.sql</code> using phpMyAdmin, Adminer, or MySQL CLI.</li><li>Before production, change all demo passwords and replace <code>https://your-domain.com</code> asset URLs with your real HTTPS domain if you imported the placeholder unchanged.</li></ol><pre><code>mysql -u tomchat_user -p tomchat_db &lt; database/appchat_clean_install.sql</code></pre></section>
    <section><h2>PHP Installation</h2><ol><li>Upload <code>backend/php_api</code> to the server.</li><li>Point the web server document root to <code>backend/php_api/public</code>.</li><li>Copy <code>.env.example</code> to <code>.env</code> and fill all required values.</li><li>Run <code>composer install --no-dev --optimize-autoloader</code>.</li><li>Ensure <code>public/uploads</code> is writable if using local storage.</li><li>Test <code>https://your-domain.com/api/helper/config</code> with header <code>API-KEY: CHANGE_ME_TOMCHAT_API_KEY</code>.</li></ol><h3>Apache</h3><pre><code>DocumentRoot /var/www/tomchat/backend/php_api/public
AllowOverride All</code></pre><h3>Nginx</h3><pre><code>root /var/www/tomchat/backend/php_api/public;
location / { try_files `$uri `$uri/ /index.php?`$query_string; }</code></pre><p>Shared hosting is suitable only when it supports PHP 8+, Composer, MySQL, Redis access, writable uploads, SSL, and a separately hosted Node.js Socket.IO server.</p></section>
    <section><h2>Node.js Installation</h2><ol><li>Upload <code>backend/node_server</code>.</li><li>Copy <code>.env.example</code> to <code>.env</code>.</li><li>Run <code>npm install</code>.</li><li>Start with PM2.</li></ol><pre><code>cd /var/www/tomchat/backend/node_server
npm install
pm2 start s1.js --name tomchat-socket
pm2 save
pm2 startup</code></pre><p>The actual entry file is <code>s1.js</code>. The server uses Socket.IO 4.8 and Redis 4.7. Configure <code>SOCKET_ALLOWED_ORIGINS</code> with your app/API origins in production.</p><h3>Nginx WSS Proxy</h3><pre><code>location /socket.io/ {
  proxy_pass http://127.0.0.1:65535;
  proxy_http_version 1.1;
  proxy_set_header Upgrade `$http_upgrade;
  proxy_set_header Connection "upgrade";
  proxy_set_header Host `$host;
}</code></pre></section>
    <section><h2>Redis Installation</h2><p>Redis is required. It stores auth token lookups, online users, room online counts, user cache entries, room membership state, and pub/sub events between PHP and Node.js. If Redis is unavailable, sockets, presence, room join notifications, cache invalidation, and force logout events will fail.</p><pre><code>redis-cli -h 127.0.0.1 -p 6379 ping</code></pre><p>Use a password on public servers, keep Redis bound to localhost or a private network, enable persistence appropriate for your operations, and restart Node/PHP workers after credential changes.</p></section>
    <section><h2>Environment Variables</h2><p>PHP variables are in <code>backend/php_api/.env.example</code>. Node variables are in <code>backend/node_server/.env.example</code>. Required groups are application URL, database, Redis, API security, Socket.IO, Agora, Firebase, Google Play, Bunny storage, business rules, withdrawal methods, and logging/debug.</p><p>Never upload real <code>.env</code>, Firebase private keys, Google Play service account JSON files, keystores, or payment credentials to public repositories or CodeCanyon preview assets.</p></section>
    <section><h2>Domain and SSL</h2><p>Use HTTPS for the PHP API and WSS through a reverse proxy for Socket.IO. Configure the buyer domain in PHP <code>APP_URL</code>, Flutter <code>TOMCHAT_API_BASE_URL</code>, Flutter <code>TOMCHAT_SHARE_BASE_URL</code>, Android deep link host in <code>android/app/src/main/AndroidManifest.xml</code>, Firebase authorized domains, Google OAuth settings, and any stored asset URLs in SQL/admin settings.</p></section>
    <section><h2>Flutter Configuration</h2><p>Primary buyer configuration lives in <code>flutter_app/lib/config/appchat_config.dart</code> or via build-time defines:</p><pre><code>flutter build apk --release `
  --dart-define=TOMCHAT_API_BASE_URL=https://your-domain.com/ `
  --dart-define=TOMCHAT_API_KEY=CHANGE_ME_TOMCHAT_API_KEY `
  --dart-define=TOMCHAT_SOCKET_HOST=socket.your-domain.com `
  --dart-define=TOMCHAT_SOCKET_PORT=443 `
  --dart-define=TOMCHAT_SHARE_BASE_URL=https://your-domain.com/share</code></pre><p>Also configure Android application ID in <code>android/app/build.gradle.kts</code>, deep links in <code>AndroidManifest.xml</code>, app display name, app icon assets, splash assets, theme colors in <code>lib/core/theme</code>, Firebase files, Google Sign-In fingerprints, Agora backend settings, product IDs from the backend recharge packages, privacy and terms URLs, and Android release signing.</p></section>
    <section><h2>Firebase Client Configuration</h2><h3>Android</h3><ol><li>Create a Firebase project.</li><li>Add Android app using your final package name, for example <code>com.example.tomchat</code>.</li><li>Add SHA-1 and SHA-256 fingerprints for Google Sign-In.</li><li>Download <code>google-services.json</code>.</li><li>Place it at <code>flutter_app/android/app/google-services.json</code>.</li><li>Enable Firebase Authentication, Google provider, Cloud Messaging, and Crashlytics if used.</li><li>Run FlutterFire CLI to regenerate <code>lib/firebase_options.dart</code>.</li></ol><h3>iOS</h3><ol><li>Add iOS app with the selected bundle identifier.</li><li>Download <code>GoogleService-Info.plist</code> and add it to the Xcode Runner target.</li><li>Enable Push Notifications and Background Modes, configure APNs, and verify the bundle identifier.</li></ol></section>
    <section><h2>Firebase Server Credentials</h2><p>The PHP backend sends FCM HTTP v1 notifications through <code>core/FirebasePush.php</code> using <code>google/auth</code> and Guzzle. Configure <code>FIREBASE_PROJECT_ID</code> and <code>FIREBASE_SERVICE_ACCOUNT_JSON</code> in PHP <code>.env</code> or corresponding <code>app_settings</code>. Generate the JSON from Firebase Console, Project Settings, Service Accounts, Firebase Admin SDK, Generate new private key. Store it outside the public web root, restrict permissions, never commit it, never include it in the ZIP, then restart PHP workers or queues if used.</p></section>
    <section><h2>Agora Configuration</h2><p>Agora App ID and certificate are read by the PHP backend from <code>AGORA_APP_ID</code>, <code>AGORA_APP_CERTIFICATE</code>, and <code>AGORA_TOKEN_TTL</code>. Flutter fetches the App ID and token-related data through <code>helper/config</code> and room endpoints. Buyers must create their own Agora project and credentials.</p></section>
    <section><h2>Google Play Purchases</h2><p>Flutter uses the <code>in_app_purchase</code> package and loads product IDs dynamically from <code>payment</code>. PHP verifies consumable Android purchases in <code>PaymentAppController::pay</code> using the Google Play Developer API. Configure product IDs in <code>recharge_packages</code>, package name in <code>GOOGLE_PLAY_PACKAGE_NAME</code>, and private server credential path in <code>GOOGLE_PLAY_SERVICE_ACCOUNT_JSON</code>.</p><p><code>google-services.json</code> is Firebase client configuration. The Google Play service account JSON is a private server credential for purchase verification; never put it in Flutter or public web folders.</p><ol><li>Link Google Play Console to a Google Cloud project.</li><li>Enable Google Play Android Developer API.</li><li>Create a dedicated service account.</li><li>Grant only purchase/order permissions needed for verification.</li><li>Generate JSON key and upload it to a protected server path.</li><li>Add the service account email in Play Console if required.</li><li>Configure exact package name and product IDs, activate products, set license testers, upload an internal test build, and test purchase verification.</li></ol><p>The code rejects duplicate successful token hashes and duplicate successful order IDs, returns errors for missing auth libraries, missing package config, missing service account file, invalid Google response, repeated charges, and invalid purchase states. Subscriptions are not implemented in the inspected backend.</p></section>
    <section><h2>Cron Jobs and Queue Workers</h2><table><tr><th>Command</th><th>Purpose</th><th>Frequency</th><th>Notes</th></tr><tr><td><code>pm2 start s1.js --name tomchat-socket</code></td><td>Socket.IO runtime</td><td>Always running</td><td>Required for rooms, presence, chat events, Redis pub/sub.</td></tr><tr><td><code>php public/index.php</code></td><td>No active cron command was found in source.</td><td>Manual diagnostics only</td><td>The inspected backend has expiration logic handled during requests, not a dedicated scheduled script.</td></tr></table></section>
    <section><h2>Media and Storage</h2><p><code>ImageStorageService</code> supports Bunny.net storage when configured and local upload handling. Required variables are <code>BUNNY_STORAGE_ZONE</code>, <code>BUNNY_STORAGE_REGION</code>, <code>BUNNY_STORAGE_API_KEY</code>, and <code>BUNNY_CDN_URL</code>. If using local storage, make <code>public/uploads</code> writable and serve it over HTTPS.</p></section>
    <section><h2>Bank and Withdrawal Methods</h2><p>User withdrawal accounts are stored in <code>cash_accounts</code>. Withdrawal requests are stored in <code>recharge_requests</code>. The Flutter Add Account screen loads account types from the <code>cash</code> API response, so new types appear without Flutter code changes when configured in PHP. In the packaged backend, edit <code>WITHDRAWAL_TYPE_1_NAME</code> through <code>WITHDRAWAL_TYPE_3_NAME</code> or update the <code>withdrawal_account_types</code> JSON row in <code>app_settings</code>. Required account fields are <code>uid</code>, <code>type</code>, <code>name</code>, <code>account</code>, and <code>created_at</code>. Add validation in <code>CashAppController::add_cash_account</code> if a payment method requires a specific account format.</p></section>
    <section><h2>Asset Customization</h2><p>Emojis use the <code>emojis</code> table and are returned by <code>LiveAppController::emojiList</code>. Store frames and entry animations use <code>store_items</code>; frame type is <code>0</code>, entry type is <code>2</code>. VIP levels use <code>vip_packages</code> and <code>vip_privileges</code>. Rocket levels use <code>rocket_levels</code> and optional <code>rocket_rewards</code>. Upload new files through the admin panel where available or place files under <code>public/uploads/tomchat_seed_assets</code>, create database rows, clear Flutter image cache if needed, and restart Node only when socket behavior changes.</p></section>
    <section><h2>Admin Login and Security</h2><p>Admin dashboard URL: <code>https://your-domain.com/admin</code>. Temporary admin login: <code>admin@tomchat.local</code> / <code>TomChat@123</code>. Change it immediately after installation. Keep <code>APP_DEBUG=false</code> in production, protect private JSON files, restrict upload types, use HTTPS, set strong Redis and database passwords, restrict admin access, and review audit logs.</p></section>
    <section><h2>Branding and Release Build</h2><p>Change app name, logo, launcher icon, splash, package name, bundle identifier, privacy policy, terms URL, support URL, and signing key before publishing. Use <code>android/key.properties.example</code> as the template for your own keystore.</p><pre><code>flutter clean
flutter pub get
flutter build appbundle --release --dart-define=TOMCHAT_API_BASE_URL=https://your-domain.com/ --dart-define=TOMCHAT_API_KEY=CHANGE_ME_TOMCHAT_API_KEY</code></pre></section>
    <section><h2>Testing Checklist</h2><p>Test registration, login, profile editing, room creation, room join/leave, microphone controls, Socket.IO connection, Redis connection, text messages, gifts, wallet balances, recharge flow, withdrawals, emojis, frames, entry animations, VIP, Rocket levels, Firebase token registration, push notification after adding credentials, Google Play verification with license tester, bank account methods, media upload, logout, and admin moderation.</p></section>
    <section><h2>Third-Party Services</h2><table><tr><th>Service</th><th>Usage</th><th>Required</th><th>Configured in</th></tr><tr><td>Agora</td><td>Audio rooms and RTC tokens</td><td>Required for voice</td><td>PHP .env/app_settings</td></tr><tr><td>Firebase</td><td>Auth, messaging, Crashlytics</td><td>Required for push and Google Sign-In</td><td>Flutter files and PHP .env</td></tr><tr><td>Google Play</td><td>Consumable purchase verification</td><td>Required for Android IAP</td><td>PHP .env and recharge_packages</td></tr><tr><td>Redis</td><td>Presence/cache/pub-sub</td><td>Required</td><td>PHP and Node .env</td></tr><tr><td>Bunny.net</td><td>Optional media CDN/storage</td><td>Optional</td><td>PHP .env</td></tr></table><p>Third-party service charges are not included in the CodeCanyon purchase.</p></section>
    <section><h2>Troubleshooting</h2><ul><li><strong>Invalid API key</strong>: Match Flutter <code>TOMCHAT_API_KEY</code>, PHP <code>API_KEY</code>, and Node <code>API_KEY</code>.</li><li><strong>Socket fails</strong>: Check PM2 logs, Redis ping, Nginx Upgrade headers, SSL, and port firewall.</li><li><strong>Images fail</strong>: Replace placeholder asset domain and verify <code>public/uploads</code> permissions or Bunny CDN settings.</li><li><strong>ITEM_UNAVAILABLE</strong>: Product ID, package name, tester account, or internal test build is mismatched.</li><li><strong>Firebase push fails</strong>: Check service account path, project ID, file permissions, and PHP error log for <code>Firebase push failed</code>.</li></ul></section>
    <section><h2>FAQ</h2><p><strong>Can I add more bank methods?</strong> Yes, use <code>withdrawal_account_types</code> in <code>app_settings</code> or PHP environment defaults.</p><p><strong>Are migrations required?</strong> No. Use the single SQL file.</p><p><strong>Are third-party credentials included?</strong> No. Buyers must supply their own Firebase, Agora, Google Play, server, domain, SSL, payment, and storage credentials.</p><p><strong>Is shared hosting supported?</strong> Only if PHP requirements are met and Node.js/Redis are hosted separately or supported by the hosting provider.</p></section>
    <section><h2>Changelog and Support</h2><p>Initial release: <a href="../changelog/changelog.html">changelog</a>. Support covers installation guidance and verified package issues. Custom assets, extra levels, deployment, branding, and custom features may require paid customization.</p></section>
  </main>
  <script src="assets/documentation.js"></script>
</body>
</html>
"@
Write-Utf8 (Join-Path $DocsDir "index.html") $docsHtml
Write-Utf8 (Join-Path $DocsDir "assets\documentation.css") @'
:root{--bg:#f7f8fb;--ink:#1d2433;--muted:#667085;--brand:#f26122;--line:#d9dee8;--panel:#fff}*{box-sizing:border-box}body{margin:0;font-family:Inter,Arial,sans-serif;background:var(--bg);color:var(--ink);line-height:1.6}aside{position:fixed;inset:0 auto 0 0;width:280px;background:#111827;color:#fff;padding:24px;overflow:auto}aside strong{display:block;font-size:20px;margin-bottom:18px}aside input{width:100%;padding:10px 12px;border:1px solid #334155;background:#0f172a;color:#fff;border-radius:6px;margin-bottom:14px}aside a{display:block;color:#dbeafe;text-decoration:none;padding:7px 0;border-bottom:1px solid rgba(255,255,255,.06);font-size:14px}main{margin-left:280px;padding:34px;max-width:1180px}section{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:26px;margin-bottom:18px}h1,h2,h3{line-height:1.2;margin:0 0 12px}h1{font-size:34px}h2{font-size:24px;border-bottom:2px solid var(--brand);padding-bottom:8px}code{background:#eef2f7;padding:2px 5px;border-radius:4px}pre{background:#0f172a;color:#e5e7eb;padding:16px;border-radius:8px;overflow:auto}pre code{background:transparent;padding:0}table{width:100%;border-collapse:collapse}th,td{border:1px solid var(--line);padding:10px;text-align:left;vertical-align:top}th{background:#f1f5f9}@media print{aside{display:none}main{margin:0;padding:0}section{break-inside:avoid}}@media(max-width:860px){aside{position:static;width:auto}main{margin:0;padding:18px}section{padding:18px}}
'@
Write-Utf8 (Join-Path $DocsDir "assets\documentation.js") @'
const toc=document.getElementById('toc');const search=document.getElementById('search');const sections=[...document.querySelectorAll('main section')];sections.forEach((section,i)=>{const h=section.querySelector('h1,h2');if(!h)return;section.id='section-'+i;const a=document.createElement('a');a.href='#'+section.id;a.textContent=h.textContent;toc.appendChild(a)});search.addEventListener('input',()=>{const q=search.value.toLowerCase();sections.forEach(s=>{s.style.display=s.textContent.toLowerCase().includes(q)?'block':'none'})});
'@

Write-Utf8 (Join-Path $ChangelogDir "changelog.html") @"
<!doctype html><html lang='en'><head><meta charset='utf-8'><title>TomChat Changelog</title><style>body{font-family:Arial,sans-serif;max-width:860px;margin:40px auto;line-height:1.6;color:#1f2937}h1{color:#f26122}</style></head><body><h1>TomChat Changelog</h1><h2>Version $Version</h2><ul><li>Initial CodeCanyon release.</li><li>Flutter audio chat application included.</li><li>PHP API and admin panel included.</li><li>Node.js Socket.IO real-time server included.</li><li>Clean-install SQL database included.</li><li>Installation documentation included.</li><li>Packaged configuration files were sanitized for marketplace distribution.</li></ul></body></html>
"@

Write-Utf8 (Join-Path $LicenseDir "license-report.md") @'
# TomChat Licensing Report

This report is based on local package inspection only. No external license registry lookup was performed.

| Asset or dependency | Source | License | Redistribution | Attribution | Package location | Action required |
| --- | --- | --- | --- | --- | --- | --- |
| Flutter packages from pubspec.lock | pub.dev dependencies | See each package license | Usually allowed by package license | Varies | flutter_app/pubspec.* | Review generated dependency licenses before upload |
| local_plugins/webview_flutter_android | Bundled local Flutter plugin | BSD-style Flutter plugin license if unchanged | Usually allowed | Keep LICENSE file | flutter_app/local_plugins | Keep included LICENSE |
| Composer packages | Composer dependencies | See Composer package licenses | Usually allowed | Varies | backend/php_api/composer.* | Run Composer license review before upload |
| Node packages | npm dependencies | See npm package licenses | Usually allowed | Varies | backend/node_server/package*.json | Run npm license review before upload |
| TomChat seed images, GIF, WebP, SVGA | Seller-provided TomChat assets | Not proven in repository | Pending seller confirmation | Pending | backend/php_api/public/uploads/tomchat_seed_assets | Confirm redistribution rights before submission |
| Preview images supplied by seller | User-provided preview images | Not proven in repository | Pending seller confirmation | Pending | LivePreview/images, Preview_Screenshots | Confirm rights before submission |
| Cairo font | Bundled app font | License file not found in project | Pending review | Pending | flutter_app/assets/fonts/cairo.ttf | Confirm font redistribution license or replace |

Do not upload the item until every pending license item is confirmed or replaced.
'@

Write-Utf8 (Join-Path $MainFile "license_information\third-party-services.md") @'
# Third-Party Service Notes

Buyers must provide their own Firebase, Agora, Google Play Console, Redis/server, domain, SSL, optional Bunny.net, email/SMS/payment provider, and any other third-party credentials. Third-party service fees are not included in the CodeCanyon purchase.
'@

# Live Preview with provided preview images.
$previewImages = @()
if (Test-Path -LiteralPath $PreviewSource) {
  $previewImages = Get-ChildItem -LiteralPath $PreviewSource -File -Include *.png,*.jpg,*.jpeg | Sort-Object Name
}
$i = 1
foreach ($img in $previewImages | Select-Object -First 9) {
  $name = "screen-{0:D2}.jpg" -f $i
  Resize-Image -Source $img.FullName -Destination (Join-Path $LivePreview "images\screenshots\$name") -Width 1200 -Height 628 -Crop -Quality 86
  Resize-Image -Source $img.FullName -Destination (Join-Path $Screens ("{0:D2}-tomchat-preview.jpg" -f $i)) -Width 1200 -Height 628 -Crop -Quality 90
  $i++
}
$heroImage = Join-Path $LivePreview "images\screenshots\screen-01.jpg"
if (!(Test-Path -LiteralPath $heroImage) -and $previewImages.Count -gt 0) {
  Resize-Image -Source $previewImages[0].FullName -Destination $heroImage -Width 1200 -Height 628 -Crop -Quality 86
}
if ($previewImages.Count -gt 0) {
  Resize-Image -Source $previewImages[0].FullName -Destination (Join-Path $Inline "inline-preview-590x300.jpg") -Width 590 -Height 300 -Crop -Quality 90
}
$logo = Join-Path $FlutterRoot "assets\app_logo.png"
if (Test-Path -LiteralPath $logo) {
  Resize-Image -Source $logo -Destination (Join-Path $Thumb "thumbnail-80x80.jpg") -Width 80 -Height 80 -Crop -Quality 90
}

Write-Utf8 (Join-Path $LivePreview "index.html") @'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>TomChat - Flutter Audio Chat Rooms App</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <header class="hero">
    <nav><strong>TomChat</strong><span>Flutter + PHP + Node.js</span></nav>
    <div class="hero-grid">
      <div><p class="eyebrow">CodeCanyon-ready social voice platform</p><h1>Flutter Audio Chat Rooms App with PHP API and Node.js Socket.IO Backend</h1><p>Build a real-time social voice application with public and private rooms, text chat, gifts, wallet, withdrawals, VIP levels, Rocket levels, Firebase notifications, and admin management.</p><div class="actions"><a href="#screens">View Screens</a><a href="#requirements">Requirements</a></div></div>
      <img src="images/screenshots/screen-01.jpg" alt="TomChat app preview">
    </div>
  </header>
  <main>
    <section class="features">
      <article><h2>Audio Rooms</h2><p>Multi-seat public and private voice rooms powered by Agora RTC and real-time room state.</p></article>
      <article><h2>Real-Time Chat</h2><p>Socket.IO events for room joins, text messages, gifts, presence, and user updates.</p></article>
      <article><h2>User Profiles</h2><p>Profiles include levels, badges, followers, visitors, wallet shortcuts, and store items.</p></article>
      <article><h2>Gifts and Emojis</h2><p>Gift animations, chat reactions, 10 included emojis, and customizable digital assets.</p></article>
      <article><h2>Frames and Entry Animations</h2><p>5 included user frames and 5 included entry animations with store configuration.</p></article>
      <article><h2>VIP and Rocket Levels</h2><p>3 VIP levels and 3 Rocket levels included, with backend-managed settings.</p></article>
      <article><h2>Wallet and Recharge</h2><p>Wallet balances, recharge packages, Google Play purchase verification, and transaction logs.</p></article>
      <article><h2>Withdrawal Methods</h2><p>Configurable withdrawal account types and admin-managed withdrawal requests.</p></article>
      <article><h2>Firebase Notifications</h2><p>Firebase Messaging integration with PHP server-side FCM HTTP v1 sender.</p></article>
      <article><h2>Flutter Application</h2><p>Complete Flutter source with Android and iOS configuration guidance.</p></article>
      <article><h2>PHP API</h2><p>PHP API, admin dashboard, database access, uploads, Agora tokens, and payment verification.</p></article>
      <article><h2>Node.js Socket Server</h2><p>Socket.IO gateway backed by Redis pub/sub and presence keys.</p></article>
    </section>
    <section id="screens" class="screens"><h2>Mobile Screenshots</h2><div class="screen-grid">
      <img src="images/screenshots/screen-02.jpg" alt="Voice room browsing">
      <img src="images/screenshots/screen-03.jpg" alt="Discovery">
      <img src="images/screenshots/screen-04.jpg" alt="Wallet and withdrawal">
      <img src="images/screenshots/screen-05.jpg" alt="Login">
      <img src="images/screenshots/screen-06.jpg" alt="Rankings">
      <img src="images/screenshots/screen-07.jpg" alt="Store frames">
      <img src="images/screenshots/screen-08.jpg" alt="Live room">
      <img src="images/screenshots/screen-09.jpg" alt="Complete app">
    </div></section>
    <section id="requirements" class="requirements"><h2>Server Requirements</h2><ul><li>PHP 8.0+, Composer 2, MySQL 8 or MariaDB 10.6+</li><li>Node.js 18+, npm 9+, PM2 recommended</li><li>Redis 6+, HTTPS domain, WSS reverse proxy</li><li>Buyer-owned Firebase, Agora, Google Play, server, domain, SSL, payment, and optional storage credentials</li></ul></section>
    <section class="support"><h2>Installation Documentation</h2><p>The main download includes full local HTML documentation, environment examples, SQL installer, changelog, licensing notes, and troubleshooting.</p><div class="actions"><a href="#">Purchase link placeholder</a><a href="#">Demo link placeholder</a></div></section>
  </main>
  <script src="js/main.js"></script>
</body>
</html>
'@
Write-Utf8 (Join-Path $LivePreview "css\style.css") @'
:root{--ink:#161922;--muted:#667085;--brand:#f45b16;--gold:#f7b31c;--panel:#fff;--bg:#fff8ee;--dark:#070707}*{box-sizing:border-box}body{margin:0;font-family:Inter,Arial,sans-serif;background:var(--bg);color:var(--ink)}.hero{min-height:92vh;background:#080808;color:#fff;padding:28px 6vw 72px;overflow:hidden}nav{display:flex;justify-content:space-between;align-items:center;margin-bottom:42px;color:#f8fafc}nav strong{font-size:28px}nav span{color:#fbbf24}.hero-grid{display:grid;grid-template-columns:1fr minmax(320px,620px);gap:48px;align-items:center}.eyebrow{color:#fbbf24;text-transform:uppercase;font-weight:700;letter-spacing:.08em}.hero h1{font-size:clamp(42px,7vw,86px);line-height:1.02;margin:0 0 18px;letter-spacing:0}.hero p{font-size:20px;color:#e5e7eb;max-width:760px}.hero img{width:100%;border-radius:8px;box-shadow:0 28px 80px rgba(244,91,22,.35)}.actions{display:flex;gap:14px;flex-wrap:wrap;margin-top:28px}.actions a{background:linear-gradient(135deg,var(--brand),var(--gold));color:#111;text-decoration:none;font-weight:800;padding:13px 20px;border-radius:6px}.actions a+ a{background:#fff;color:#111}.features{display:grid;grid-template-columns:repeat(3,1fr);gap:18px;padding:48px 6vw}.features article,.requirements,.support,.screens{background:#fff;border:1px solid #eadfd2;border-radius:8px;padding:24px}.features h2,.screens h2,.requirements h2,.support h2{margin:0 0 10px}.features p,.requirements li,.support p{color:var(--muted)}.screens,.requirements,.support{margin:0 6vw 32px}.screen-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}.screen-grid img{width:100%;border-radius:8px;border:1px solid #eadfd2}@media(max-width:900px){.hero-grid,.features,.screen-grid{grid-template-columns:1fr}.hero{min-height:auto}.hero h1{font-size:42px}nav{align-items:flex-start;gap:8px;flex-direction:column}}
'@
Write-Utf8 (Join-Path $LivePreview "js\main.js") "document.documentElement.classList.add('ready');"
Write-Utf8 (Join-Path $LivePreview "README.txt") @'
TomChat Live Preview

Open index.html directly in a browser. No build system is required.

Screenshot files used by this preview:
- images/screenshots/screen-01.jpg: hero and complete app overview
- images/screenshots/screen-02.jpg: room browsing
- images/screenshots/screen-03.jpg: discovery
- images/screenshots/screen-04.jpg: wallet and withdrawals
- images/screenshots/screen-05.jpg: login
- images/screenshots/screen-06.jpg: rankings
- images/screenshots/screen-07.jpg: store and frames
- images/screenshots/screen-08.jpg: live room
- images/screenshots/screen-09.jpg: full app and admin panel

Recommended replacement dimensions: 1200x628 or wider at the same aspect ratio. Keep filenames unchanged or update index.html.
Do not add real credentials or fake live demo URLs.
'@

Write-Utf8 (Join-Path $Screens "README.txt") @'
Preview screenshots folder

Use numbered JPG files in this order:
01 complete app overview
02 browse voice rooms
03 discover rooms and users
04 wallet and withdrawal
05 login and Google Sign-In
06 rankings and top users
07 store and profile frames
08 live room experience
09 app plus admin panel

Screenshots should be high quality, truthful, and match the included product.
'@
Write-Utf8 (Join-Path $Screens "screenshot-manifest.csv") @'
file,caption,recommended_size
01-tomchat-preview.jpg,Complete app overview,1200x628
02-tomchat-preview.jpg,Browse voice rooms,1200x628
03-tomchat-preview.jpg,Discover rooms and users,1200x628
04-tomchat-preview.jpg,Wallet and withdrawal system,1200x628
05-tomchat-preview.jpg,Secure login and Google Sign-In,1200x628
06-tomchat-preview.jpg,Rankings and top users,1200x628
07-tomchat-preview.jpg,Store and profile frames,1200x628
08-tomchat-preview.jpg,Live room experience,1200x628
09-tomchat-preview.jpg,Flutter app and admin panel,1200x628
'@
Write-Utf8 (Join-Path $Inline "README.txt") "Inline preview must be exactly 590x300 JPEG. Current template: inline-preview-590x300.jpg."
Write-Utf8 (Join-Path $Thumb "README.txt") "Thumbnail must be exactly 80x80 JPEG or PNG. Current template: thumbnail-80x80.jpg."

$title = "TomChat - Flutter Audio Chat Rooms App with PHP and Node.js Backend"
$tags = "flutter,audio chat,voice room,social app,live chat,node.js,php,firebase,agora,in app purchase,socket.io,redis,wallet,admin panel,chat app"
$description = @"
<h2>TomChat - Flutter Audio Chat Rooms App</h2>
<p>TomChat is a complete Flutter social audio chat room application with PHP API, MySQL database, Redis, Node.js Socket.IO real-time server, Firebase push notifications, Agora audio rooms, wallet, withdrawals, gifts, store assets, VIP levels, Rocket levels, and admin management.</p>
<h3>Main Features</h3>
<ul>
<li>Public and private multi-seat voice rooms</li>
<li>Real-time Socket.IO room events and text chat</li>
<li>User profiles, followers, visitors, levels, badges, and profile decoration</li>
<li>Virtual gifts and room gift animations</li>
<li>10 included emojis, 5 user frames, 5 room entry animations</li>
<li>3 included VIP levels and 3 included Rocket levels</li>
<li>Wallet, recharge packages, withdrawal accounts, and transaction logs</li>
<li>Google Play consumable in-app purchase verification in PHP</li>
<li>Firebase Cloud Messaging client and server notification support</li>
<li>PHP admin dashboard for users, rooms, content, store, VIP, transactions, reports, settings, roles, and audit logs</li>
<li>Node.js Socket.IO server with Redis pub/sub and presence tracking</li>
</ul>
<h3>Included Source Code</h3>
<ul><li>Flutter application source</li><li>PHP API and admin panel source</li><li>Node.js Socket.IO source</li><li>Clean-install SQL database with demo data</li><li>Full local HTML documentation</li></ul>
<h3>Important Buyer Notes</h3>
<p>Buyers must provide their own Firebase, Agora, Google Play, server, domain, SSL, payment, storage/CDN, and other third-party credentials. Third-party provider fees are not included. The package includes placeholders and setup instructions instead of private credentials.</p>
<p>Additional emojis, frames, entry animations, VIP levels, Rocket levels, custom digital assets, and customization services can be purchased separately by contacting the seller. The default package remains complete and usable with the included base assets.</p>
<h3>Server Requirements</h3>
<p>PHP 8.0+, Composer 2, MySQL 8 or MariaDB 10.6+, Node.js 18+, npm 9+, Redis 6+, HTTPS domain, and WSS reverse proxy for Socket.IO.</p>
<h3>Support</h3>
<p>Support covers installation guidance and verified package issues. Custom deployment, branding, new features, and extra digital asset packs may require paid customization.</p>
"@
$reviewerMsg = @"
Hello CodeCanyon Reviewer,

TomChat is prepared as a first-time marketplace package.

Package locations:
- Flutter app: Main_File/flutter_app
- PHP backend and admin panel: Main_File/backend/php_api
- Node.js Socket.IO server: Main_File/backend/node_server
- SQL installer: Main_File/database/appchat_clean_install.sql
- Documentation: Main_File/documentation/index.html
- Changelog: Main_File/changelog/changelog.html

Temporary demo credentials:
- Admin dashboard: admin@tomchat.local / TomChat@123
- Demo user: alex.demo@example.com / TomChat@123
- Demo user: sophia.demo@example.com / TomChat@123

The reviewer can inspect the Flutter source, import the SQL file into MySQL, configure backend/php_api/.env from .env.example, run composer install, configure backend/node_server/.env from .env.example, run npm install, and start s1.js with PM2 or npm start.

Third-party services requiring reviewer or buyer credentials: Firebase client configuration, Firebase Admin service account JSON, Agora App ID/certificate, Google Play Developer API service account JSON, Google Play in-app products, Redis server, hosting/domain/SSL, and optional Bunny.net media storage.

Private service account JSON files, real .env files, Android keystores, Firebase google-services.json, and GoogleService-Info.plist are intentionally excluded.

Licensing note requiring seller confirmation before final upload: Any images, sounds, videos, code, or other assets that are not our original work have been appropriately licensed for use in the preview or main download. Other than these items, the work is original and we have the required rights to sell it.
"@

Write-Utf8 (Join-Path $Submission "item-title.txt") @"
Recommended title:
$title

Other suitable title options:
TomChat - Flutter Voice Room Social App with PHP API and Node.js Socket Server
TomChat - Audio Chat Rooms Flutter App with PHP Backend and Socket.IO
TomChat - Live Voice Chat Flutter Social App with PHP and Node.js Backend
"@
Write-Utf8 (Join-Path $Submission "html-description.html") $description
Write-Utf8 (Join-Path $Submission "tags.txt") $tags
Write-Utf8 (Join-Path $Submission "reviewer-message.txt") $reviewerMsg
Write-Utf8 (Join-Path $Submission "requirements.txt") @'
PHP 8.0+, Composer 2, MySQL 8 or MariaDB 10.6+, Redis 6+, Node.js 18+, npm 9+, HTTPS domain, WSS reverse proxy, Flutter SDK, Android Studio/Xcode for builds, Firebase project, Agora project, Google Play Console app.
'@
Write-Utf8 (Join-Path $Submission "feature-list.txt") @'
Audio rooms, private rooms, text chat, profiles, follows, gifts, emojis, entry animations, user frames, VIP levels, Rocket levels, wallet, withdrawals, Firebase push, Google Play purchases, PHP API, Node.js Socket.IO, Redis, admin panel.
'@
Write-Utf8 (Join-Path $Submission "asset-list.txt") @'
Included base pack: 10 emojis, 5 user frames, 5 room entry animations, 3 VIP levels, 3 Rocket levels. Preview images supplied by seller are stored outside the main buyer ZIP.
'@
Write-Utf8 (Join-Path $Submission "demo-credentials.txt") @'
Temporary password for all demo accounts: TomChat@123
Admin: admin@tomchat.local
Demo user 1: alex.demo@example.com
Demo user 2: sophia.demo@example.com
Change or remove all demo credentials before production.
'@
Write-Utf8 (Join-Path $Submission "upload-checklist.txt") @'
[ ] Item name is under 100 characters.
[ ] Description contains no prohibited emoji.
[ ] Tags are lowercase and no more than 15.
[ ] Thumbnail is 80x80.
[ ] Inline preview is 590x300.
[ ] Screenshots ZIP is prepared.
[ ] Live Preview ZIP contains lowercase/case-sensitive index.html.
[ ] Main buyer ZIP excludes preview images.
[ ] Main ZIP size is checked.
[ ] No credentials are included.
[ ] No real .env file is included.
[ ] No Firebase private key is included.
[ ] No Google Play private key is included.
[ ] SQL file imports successfully.
[ ] Documentation opens locally.
[ ] Demo credentials work.
[ ] Licensing declaration is accurate and seller-confirmed.
[ ] Reviewer message is complete.
'@
Write-Utf8 (Join-Path $Reviewer "reviewer-message.txt") $reviewerMsg

Write-Utf8 (Join-Path $PackageRoot "README.txt") @"
TomChat CodeCanyon Package v$Version

Main buyer ZIP files are in Final_Zip.
Buyer source is in Main_File.
Live preview is in LivePreview/index.html.
Preview assets are outside the buyer ZIP.
"@

$securityReport = @'
# Security Review Summary

Focused review performed during packaging:
- Hardcoded Flutter API URL, socket defaults, share URL, API key, Firebase options, Android keystore, and google-services.json were sanitized in the packaged copy.
- PHP Config.php was converted to read .env placeholders in the packaged copy.
- Node Socket.IO config was converted to environment variables in the packaged copy.
- PHP Router base path was made install-path aware in the packaged copy.
- Production API exception details are gated by APP_DEBUG in the packaged copy.
- Withdrawal account types are backend-configurable in the packaged copy.
- Google Play purchase flow has duplicate token hash and order ID checks.
- Firebase private service account and Google Play private JSON files are excluded.

Residual items requiring production review:
- Add rate limiting at web server/API gateway.
- Review all admin roles before production.
- Confirm upload MIME/extension rules against the buyer's allowed media list.
- Confirm seller rights for all app and preview assets.
'@
Write-Utf8 (Join-Path $Reviewer "security-review.md") $securityReport

$testReport = @'
# Functional Test Report

| Item | Result | Relevant file | Limitation/manual step |
| --- | --- | --- | --- |
| SQL file generated | Prepared | Main_File/database/appchat_clean_install.sql | Import validation must run against local MySQL if available |
| Admin credentials | Prepared | SQL admin_users | Requires DB import and PHP server |
| Demo users | Prepared | SQL users | Requires DB import and API server |
| PHP configuration | Prepared | backend/php_api/.env.example | Buyer must fill credentials |
| Node configuration | Prepared | backend/node_server/.env.example | Buyer must fill Redis/API values |
| Flutter configuration | Prepared | flutter_app/lib/config/appchat_config.dart | Buyer must set dart-define values |
| Firebase client files | Excluded intentionally | Flutter android/ios | Buyer must add own files |
| Firebase server credential | Excluded intentionally | PHP .env | Buyer must add own JSON path |
| Google Play credential | Excluded intentionally | PHP .env | Buyer must add own JSON path |
| Preview screenshots | Prepared from provided images | Preview_Screenshots | Seller should confirm final screenshots and rights |
| Full runtime flows | Not executed | App/API/Node | Require configured MySQL, Redis, Agora, Firebase, Google Play, and mobile device |
'@
Write-Utf8 (Join-Path $Reviewer "test-report.md") $testReport

# Create ZIPs.
$mainZip = Join-Path $FinalZip "TomChat_Main_File_v$Version.zip"
$liveZip = Join-Path $FinalZip "TomChat_LivePreview_v$Version.zip"
$screenZip = Join-Path $FinalZip "TomChat_Preview_Screenshots_v$Version.zip"
if (Test-Path $mainZip) { Remove-Item $mainZip -Force }
if (Test-Path $liveZip) { Remove-Item $liveZip -Force }
if (Test-Path $screenZip) { Remove-Item $screenZip -Force }
$zipStage = Join-Path $PackageRoot "_zip_staging_main"
if (Test-Path -LiteralPath $zipStage) {
  Remove-Item -LiteralPath $zipStage -Recurse -Force -ErrorAction SilentlyContinue
}
Ensure-Dir $zipStage
Copy-Filtered -Source $MainFile -Destination $zipStage `
  -SkipDirs @("uploads","ephemeral",".dart_tool","build","test") `
  -SkipFiles @() `
  -SkipExtensions @()
$stageUploadRoot = Join-Path $zipStage "backend\php_api\public\uploads"
Ensure-Dir $stageUploadRoot
foreach ($relativeUpload in $referencedUploads) {
  $originalUpload = Join-Path $uploadSourceRoot $relativeUpload
  $packagedUpload = Join-Path $uploadDestRoot $relativeUpload
  $sourceUpload = if (Test-Path -LiteralPath $originalUpload) { $originalUpload } else { $packagedUpload }
  if (Test-Path -LiteralPath $sourceUpload) {
    $destUpload = Join-Path $stageUploadRoot $relativeUpload
    Ensure-Dir (Split-Path -Parent $destUpload)
    Copy-Item -LiteralPath $sourceUpload -Destination $destUpload -Force
  }
}
$mainItems = Get-ChildItem -LiteralPath $zipStage -Force
$liveItems = Get-ChildItem -LiteralPath $LivePreview -Force
$screenItems = Get-ChildItem -LiteralPath $Screens -Force
Push-Location $zipStage
try { & tar -a -cf $mainZip . } finally { Pop-Location }
Push-Location $LivePreview
try { & tar -a -cf $liveZip . } finally { Pop-Location }
Push-Location $Screens
try { & tar -a -cf $screenZip . } finally { Pop-Location }
Remove-Item -LiteralPath $zipStage -Recurse -Force -ErrorAction SilentlyContinue

$createdFiles = Get-PackageFiles $PackageRoot
Write-Utf8 (Join-Path $Reviewer "generated-file-tree.txt") ($createdFiles -join "`r`n")

$summary = [ordered]@{
  package_root = $PackageRoot
  version = $Version
  recommended_title = $title
  tags = $tags
  main_zip = $mainZip
  main_zip_bytes = (Get-Item $mainZip).Length
  live_preview_zip = $liveZip
  live_preview_zip_bytes = (Get-Item $liveZip).Length
  preview_screenshots_zip = $screenZip
  preview_screenshots_zip_bytes = (Get-Item $screenZip).Length
  sql_file = (Join-Path $DatabaseDir "appchat_clean_install.sql")
  files_created_count = $createdFiles.Count
}
Write-Utf8 (Join-Path $Reviewer "package-summary.json") ($summary | ConvertTo-Json -Depth 4)
$summary | ConvertTo-Json -Depth 4
