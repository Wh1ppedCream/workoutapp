[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('check', 'dart', 'flutter')]
    [string]$Tool = 'check',

    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$ToolArguments = @()
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$workflow = Get-Content -LiteralPath (Join-Path $repoRoot '.github\workflows\ci.yml') -Raw
$versionMatch = [regex]::Match($workflow, '(?m)^  FLUTTER_VERSION:\s*(\d+\.\d+\.\d+)\s*$')
if (-not $versionMatch.Success) {
    throw 'The CI Flutter version pin could not be read.'
}
$requiredVersion = $versionMatch.Groups[1].Value
$sdkRoot = $env:TONOS_FLUTTER_SDK
if ([string]::IsNullOrWhiteSpace($sdkRoot)) {
    $sdkRoot = "E:\tools\flutter_sdks\$requiredVersion\flutter"
}
$flutterExecutable = Join-Path $sdkRoot 'bin\flutter.bat'
$dartExecutable = Join-Path $sdkRoot 'bin\cache\dart-sdk\bin\dart.exe'
foreach ($executable in @($flutterExecutable, $dartExecutable)) {
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
        throw "SDK executable missing: $executable. Set TONOS_FLUTTER_SDK to the Flutter $requiredVersion SDK root."
    }
}

$originalPath = $env:PATH
Push-Location $repoRoot
try {
    $env:PATH = "$(Join-Path $sdkRoot 'bin');$(Split-Path $dartExecutable);$originalPath"
    $versionOutput = & $flutterExecutable --version --machine
    if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the selected Flutter SDK.' }
    $version = $versionOutput | ConvertFrom-Json
    if ($version.frameworkVersion -ne $requiredVersion) {
        throw "Flutter $requiredVersion is required; selected SDK reports $($version.frameworkVersion)."
    }
    $dartVersion = (& $dartExecutable --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $dartVersion -notmatch 'Dart SDK version: (\S+)') {
        throw 'Could not inspect the bundled Dart SDK.'
    }
    if ($Matches[1] -ne ($version.dartSdkVersion -split ' ')[0]) {
        throw 'The bundled Dart SDK does not match the selected Flutter SDK.'
    }

    switch ($Tool) {
        'check' {
            Write-Output "Flutter ${requiredVersion}: $flutterExecutable"
            Write-Output $dartVersion
            $toolExitCode = 0
        }
        'dart' {
            & $dartExecutable @ToolArguments
            $toolExitCode = $LASTEXITCODE
        }
        'flutter' {
            & $flutterExecutable @ToolArguments
            $toolExitCode = $LASTEXITCODE
        }
    }
} finally {
    $env:PATH = $originalPath
    Pop-Location
}
exit $toolExitCode
