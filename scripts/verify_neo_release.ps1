# Run manually. Repository policy prohibits Codex from running Dart/Flutter.
param([switch]$BuildOnly)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not (Test-Path -LiteralPath 'android/key.properties')) {
    throw 'Configure the existing release signing key in android/key.properties first. Do not paste its contents into chat.'
}

if (-not $BuildOnly) {
$changedDart = @(
    'lib/theme/app_theme_capabilities.dart'
    'lib/theme/app_theme_family.dart'
    'test/theme/app_theme_capabilities_test.dart'
    'test/theme/app_theme_compile_time_test.dart'
    'test/theme/theme_family_selector_test.dart'
)
dart format @changedDart
if ($LASTEXITCODE -ne 0) { throw 'Formatting failed.' }
dart analyze @changedDart
if ($LASTEXITCODE -ne 0) { throw 'Analysis failed.' }

$focusedTests = @(
    'test/theme/app_theme_capabilities_test.dart'
    'test/theme/app_theme_compile_time_test.dart'
    'test/theme/app_theme_family_test.dart'
    'test/theme/app_theme_preferences_test.dart'
    'test/theme/theme_family_selector_test.dart'
    'test/theme/debug_theme_family_control_test.dart'
    'test/theme/neo_brutalism_theme_test.dart'
    'test/theme/b6_route_evidence_test.dart'
    'test/github_workflow_contract_test.dart'
    'test/content_environment_release_contract_test.dart'
)
flutter test @focusedTests
if ($LASTEXITCODE -ne 0) { throw 'Focused theme tests failed.' }

flutter test test/theme/app_theme_compile_time_test.dart --dart-define=TONOS_ENABLE_NEO_RELEASE=true --dart-define=TONOS_EXPECT_NEO_RELEASE=true --dart-define=TONOS_ENABLE_EXPERIMENTAL_THEMES=false
if ($LASTEXITCODE -ne 0) { throw 'Enabled release theme policy failed.' }
flutter test test/theme/app_theme_compile_time_test.dart --dart-define=TONOS_ENABLE_NEO_RELEASE=false --dart-define=TONOS_ENABLE_EXPERIMENTAL_THEMES=true
if ($LASTEXITCODE -ne 0) { throw 'Disabled release theme policy failed.' }
flutter test test/theme/app_theme_compile_time_test.dart --dart-define=TONOS_ENABLE_NEO_RELEASE=invalid --dart-define=TONOS_EXPECT_INVALID_NEO_RELEASE=true
if ($LASTEXITCODE -ne 0) { throw 'Malformed release theme flag was not rejected.' }
flutter test test/services/content_environment_compile_time_test.dart --dart-define=TONOS_CONTENT_ENVIRONMENT=development --dart-define=TONOS_CONTENT_ALLOW_OVERRIDES=false --dart-define=TONOS_EXPECTED_CONTENT_ENVIRONMENT=development --dart-define=TONOS_EXPECTED_CONTENT_OVERRIDES=false
if ($LASTEXITCODE -ne 0) { throw 'Locked development content policy failed.' }
}

$buildFlags = @(
    '--dart-define=TONOS_ENABLE_NEO_RELEASE=true'
    '--dart-define=TONOS_ENABLE_EXPERIMENTAL_THEMES=false'
    '--dart-define=TONOS_ENABLE_EXPERIMENTAL_TABS=false'
    '--dart-define=TONOS_CONTENT_ENVIRONMENT=development'
    '--dart-define=TONOS_CONTENT_ALLOW_OVERRIDES=false'
)
$versionLine = Get-Content -LiteralPath 'pubspec.yaml' |
    Where-Object { $_ -match '^version:' } | Select-Object -First 1
if ($versionLine -notmatch '^version:\s*([^\s+]+)\+(\d+)\s*$') {
    throw 'Expected pubspec.yaml version in versionName+versionCode format.'
}
$candidateVersionName = $Matches[1]
$candidateVersionCode = $Matches[2]

# The internal package ID is selected from the Gradle process environment.
Push-Location android
try {
    & .\gradlew.bat --stop
    if ($LASTEXITCODE -ne 0) { throw 'Could not restart Gradle with the internal build setting.' }
} finally {
    Pop-Location
}

$env:TONOS_ANDROID_INTERNAL_BUILD = 'true'
try {
    flutter build apk --release @buildFlags
    if ($LASTEXITCODE -ne 0) { throw 'Signed Android internal release build failed.' }
} finally {
    Remove-Item Env:TONOS_ANDROID_INTERNAL_BUILD -ErrorAction SilentlyContinue
}

$apk = 'build/app/outputs/flutter-apk/app-release.apk'
$sdkLine = Get-Content -LiteralPath 'android/local.properties' |
    Where-Object { $_ -match '^sdk\.dir=' } | Select-Object -First 1
if (-not $sdkLine) { throw 'Cannot inspect APK: sdk.dir is missing from android/local.properties.' }
$sdkRoot = $sdkLine.Substring('sdk.dir='.Length).Replace('\\', '\').Replace('\:', ':')
$signer = Get-ChildItem -Path (Join-Path $sdkRoot 'build-tools/*/apksigner.bat') -File |
    Sort-Object FullName -Descending | Select-Object -First 1
if (-not $signer) { throw 'Cannot inspect APK: apksigner.bat was not found in Android build-tools.' }
& $signer.FullName verify --verbose --print-certs $apk
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
$aapt = Join-Path $signer.DirectoryName 'aapt.exe'
$badging = & $aapt dump badging $apk
if ($LASTEXITCODE -ne 0) { throw 'APK metadata inspection failed.' }
$badging | Select-String '^package:|^sdkVersion:|^targetSdkVersion:'
$candidateApplicationId = 'com.tonos.internal'
$expectedPackage = "name='$candidateApplicationId' versionCode='$candidateVersionCode' versionName='$candidateVersionName'"
if (-not ($badging | Where-Object { $_.StartsWith('package: ') -and $_.Contains($expectedPackage) })) {
    throw "APK version does not match pubspec.yaml: $candidateVersionName+$candidateVersionCode."
}
if (-not ($badging | Where-Object { $_.Contains("application-label:'Tonos (Internal)'") })) {
    throw 'APK does not have the distinct Tonos (Internal) launcher label.'
}
if ($badging -match '^application-debuggable') {
    throw 'Expected a non-debuggable release APK.'
}
if (-not ($badging -match "uses-permission: name='android.permission.INTERNET'")) {
    throw 'Release APK is missing the Internet permission required for media sync.'
}

git diff --check
if ($LASTEXITCODE -ne 0) { throw 'Whitespace check failed.' }
$candidateHash = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash
$candidateBase = git rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot determine candidate source base.' }
$candidateStatus = @(git status --short --untracked-files=normal)
if ($LASTEXITCODE -ne 0) { throw 'Cannot determine candidate source status.' }
$evidence = [ordered]@{
    builtAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    sourceBase = $candidateBase
    workingTree = $candidateStatus
    apk = $apk
    applicationId = $candidateApplicationId
    sha256 = $candidateHash
    version = "$candidateVersionName+$candidateVersionCode"
    buildFlags = $buildFlags
    qualification = 'Automated checks passed; release-device acceptance pending.'
}
$evidencePath = 'build/content/neo_internal_release_candidate.json'
New-Item -ItemType Directory -Path (Split-Path -Parent $evidencePath) -Force | Out-Null
$evidence | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $evidencePath -Encoding UTF8
Write-Output "APK SHA-256: $candidateHash"
Write-Output "Source base: $candidateBase"
Write-Output "Candidate evidence: $evidencePath"
Write-Output 'Neo internal release checks passed. Install and complete the focused device checklist in docs/testing.md.'
