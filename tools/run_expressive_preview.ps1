[CmdletBinding()]
param(
    [ValidateSet('debug', 'profile')]
    [string]$BuildMode = 'debug'
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$flutterRoot = 'E:\tools\flutter_sdks\3.47.5\flutter'
$flutterBin = Join-Path $flutterRoot 'bin'
$dartBin = Join-Path $flutterRoot 'bin\cache\dart-sdk\bin'
$flutterExecutable = Join-Path $flutterBin 'flutter.bat'
$dartExecutable = Join-Path $dartBin 'dart.exe'
$applicationId = 'com.tonos.expressivepreview'
$databaseName = 'tonos_expressive_preview.db'

if (-not (Test-Path -LiteralPath $flutterExecutable -PathType Leaf)) {
    throw "Pinned Flutter executable was not found: $flutterExecutable"
}
if (-not (Test-Path -LiteralPath $dartExecutable -PathType Leaf)) {
    throw "Bundled Dart executable was not found: $dartExecutable"
}

$originalPath = [Environment]::GetEnvironmentVariable('PATH', 'Process')
$originalInternalSetting = [Environment]::GetEnvironmentVariable(
    'TONOS_ANDROID_INTERNAL_BUILD',
    'Process'
)
$originalPreviewSetting = [Environment]::GetEnvironmentVariable(
    'TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD',
    'Process'
)
try {
$env:PATH = "$flutterBin;$dartBin;$env:PATH"
$flutterVersion = & $flutterExecutable --version --machine | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or $flutterVersion.frameworkVersion -ne '3.47.5') {
    throw 'The preview runner requires Flutter 3.47.5.'
}
$dartVersionOutput = (& $dartExecutable --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $dartVersionOutput -notmatch 'Dart SDK version: 3\.13\.4\b') {
    throw 'The preview runner requires the bundled Dart 3.13.4.'
}

$pubspec = Get-Content -LiteralPath (Join-Path $repoRoot 'pubspec.yaml') -Raw
$lockfile = Get-Content -LiteralPath (Join-Path $repoRoot 'pubspec.lock') -Raw
if ($pubspec -notmatch '(?m)^  material_ui:\s*\^1\.5\.0\s*$') {
    throw 'The expected material_ui constraint is missing; do not resolve packages in the preview runner.'
}
$materialUiLock = [regex]::Match(
    $lockfile,
    '(?ms)^  material_ui:\r?\n(.*?)(?=^  \S|\z)'
).Groups[1].Value
if ([string]::IsNullOrWhiteSpace($materialUiLock) -or
    $materialUiLock -notmatch '(?m)^    version: "1\.5\.0"\s*$') {
    throw 'material_ui 1.5.0 is not locked; the runner does not fetch or upgrade packages.'
}

$internalSetting = [Environment]::GetEnvironmentVariable('TONOS_ANDROID_INTERNAL_BUILD')
if ($internalSetting -and $internalSetting -notmatch '^(?i:false)$') {
    throw 'Clear TONOS_ANDROID_INTERNAL_BUILD or set it to false before building the preview.'
}
$env:TONOS_ANDROID_INTERNAL_BUILD = 'false'
$env:TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD = 'true'

Push-Location $repoRoot
try {
    $buildArguments = @(
        'build', 'apk', "--$BuildMode", '--no-pub',
        '--target', 'lib/expressive_preview_main.dart',
        '--dart-define=TONOS_EXPRESSIVE_PREVIEW=true',
        '--dart-define=TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true',
        '--dart-define=TONOS_ANDROID_INTERNAL_BUILD=false',
        "--dart-define=TONOS_DATABASE_NAME=$databaseName",
        '--dart-define=TONOS_PREVIEW_SHOW_CONTROLS=true'
    )
    & $flutterExecutable @buildArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter preview build failed with exit code $LASTEXITCODE."
    }

    $apkPath = Join-Path $repoRoot "build\app\outputs\flutter-apk\app-$BuildMode.apk"
    if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) {
        throw "Flutter completed without producing the expected APK: $apkPath"
    }

    $sdkRoot = $null
    $localPropertiesPath = Join-Path $repoRoot 'android\local.properties'
    if (Test-Path -LiteralPath $localPropertiesPath -PathType Leaf) {
        $sdkLine = Get-Content -LiteralPath $localPropertiesPath |
            Where-Object { $_.StartsWith('sdk.dir=') } |
            Select-Object -First 1
        if ($sdkLine) {
            $sdkRoot = $sdkLine.Substring('sdk.dir='.Length).
                Replace('\\', '\').Replace('\ ', ' ')
        }
    }
    if (-not $sdkRoot) { $sdkRoot = $env:ANDROID_SDK_ROOT }
    if (-not $sdkRoot) { $sdkRoot = $env:ANDROID_HOME }
    if (-not $sdkRoot) {
        $sdkRoot = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
    }
    $aaptCommand = Get-Command 'aapt.exe' -ErrorAction SilentlyContinue
    if ($aaptCommand) {
        $aaptExecutable = $aaptCommand.Source
    } else {
        $buildToolsRoot = Join-Path $sdkRoot 'build-tools'
        $buildTools = Get-ChildItem -LiteralPath $buildToolsRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
            Sort-Object { [version]$_.Name } -Descending
        $aaptExecutable = $null
        foreach ($buildTool in $buildTools) {
            $candidate = Join-Path $buildTool.FullName 'aapt.exe'
            if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                $aaptExecutable = $candidate
                break
            }
        }
    }
    $apkanalyzerExecutable = $null
    $cmdlineToolsRoot = Join-Path $sdkRoot 'cmdline-tools'
    $apkanalyzerCandidates = @(
        (Join-Path $cmdlineToolsRoot 'latest\bin\apkanalyzer.bat')
    )
    if (Test-Path -LiteralPath $cmdlineToolsRoot -PathType Container) {
        $apkanalyzerCandidates += Get-ChildItem -LiteralPath $cmdlineToolsRoot -Directory |
            Sort-Object Name -Descending |
            ForEach-Object { Join-Path $_.FullName 'bin\apkanalyzer.bat' }
    }
    foreach ($candidate in $apkanalyzerCandidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            $apkanalyzerExecutable = $candidate
            break
        }
    }
    if (-not $aaptExecutable -and -not $apkanalyzerExecutable) {
        throw 'Android aapt.exe or apkanalyzer.bat is required to inspect the APK manifest; no install was attempted.'
    }

    $manifestPackage = $null
    $manifestEvidence = $null
    if ($aaptExecutable) {
        $manifestDetails = & $aaptExecutable dump badging $apkPath 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not read the built APK manifest with aapt.'
        }
        $packageLine = $manifestDetails |
            Where-Object { $_ -match "^package: name='" } |
            Select-Object -First 1
        if ($packageLine -and $packageLine -match "^package: name='([^']+)'") {
            $manifestPackage = $Matches[1]
            $manifestEvidence = $packageLine
        }
    } else {
        $manifestDetails = & $apkanalyzerExecutable manifest application-id $apkPath 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not read the built APK manifest with apkanalyzer.'
        }
        $manifestPackage = ($manifestDetails | Out-String).Trim()
        $manifestEvidence = "apkanalyzer application-id: $manifestPackage"
    }
    if ($manifestPackage -ne $applicationId) {
        throw "APK manifest package did not equal $applicationId; no install was attempted."
    }

    Write-Output "APK manifest package: $manifestEvidence"
    Write-Output "Validated Dart defines: TONOS_EXPRESSIVE_PREVIEW=true; TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD=true; TONOS_ANDROID_INTERNAL_BUILD=false; TONOS_DATABASE_NAME=$databaseName"
    Write-Output "APK: $apkPath"
    Write-Output 'Build-only runner; it does not install or launch the APK.'
} finally {
    Pop-Location
}
} finally {
    [Environment]::SetEnvironmentVariable('PATH', $originalPath, 'Process')
    [Environment]::SetEnvironmentVariable(
        'TONOS_ANDROID_INTERNAL_BUILD',
        $originalInternalSetting,
        'Process'
    )
    [Environment]::SetEnvironmentVariable(
        'TONOS_ANDROID_EXPRESSIVE_PREVIEW_BUILD',
        $originalPreviewSetting,
        'Process'
    )
}
