$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$project = Join-Path $root 'HankakuSpace.xcodeproj/project.pbxproj'
$plist = Join-Path $root 'HankakuSpace/Info.plist'
$scheme = Join-Path $root 'HankakuSpace.xcodeproj/xcshareddata/xcschemes/HankakuSpace.xcscheme'

$required = @(
    'HankakuSpace/HankakuSpaceApp.swift',
    'HankakuSpace/AppModel.swift',
    'HankakuSpace/AppSettings.swift',
    'HankakuSpace/AppLogger.swift',
    'HankakuSpace/MenuBarView.swift',
    'HankakuSpace/SettingsView.swift',
    'HankakuSpace/KeyboardMonitor.swift',
    'HankakuSpace/InputSourceMonitor.swift',
    'HankakuSpace/PermissionManager.swift',
    'HankakuSpace/LoginItemManager.swift',
    'HankakuSpace/Info.plist',
    'HankakuSpace.xcodeproj/project.pbxproj',
    'HankakuSpace.xcodeproj/xcshareddata/xcschemes/HankakuSpace.xcscheme'
)

foreach ($relativePath in $required) {
    if (-not (Test-Path (Join-Path $root $relativePath))) {
        throw "Missing required file: $relativePath"
    }
}

$projectText = Get-Content -Raw -Encoding UTF8 $project
$swiftFiles = Get-ChildItem (Join-Path $root 'HankakuSpace') -Filter '*.swift'
foreach ($file in $swiftFiles) {
    if ($projectText -notmatch [regex]::Escape($file.Name)) {
        throw "Swift file is not referenced by project: $($file.Name)"
    }
}

[xml]$plistXml = Get-Content -Raw -Encoding UTF8 $plist
if ($plistXml.plist.dict.key -notcontains 'LSUIElement') {
    throw 'Info.plist does not contain LSUIElement'
}
[xml]$schemeXml = Get-Content -Raw -Encoding UTF8 $scheme
if ($schemeXml.Scheme.BuildAction.BuildActionEntries.BuildActionEntry.BuildableReference.BuildableName -ne 'HankakuSpace.app') {
    throw 'Shared scheme does not build HankakuSpace.app'
}

$source = ($swiftFiles | ForEach-Object { Get-Content -Raw -Encoding UTF8 $_.FullName }) -join "`n"
$requiredSymbols = @('CGEvent.tapCreate', 'TISCopyCurrentKeyboardInputSource', 'AXIsProcessTrustedWithOptions', 'SMAppService.mainApp')
foreach ($symbol in $requiredSymbols) {
    if ($source -notmatch [regex]::Escape($symbol)) {
        throw "Required API is not implemented: $symbol"
    }
}

Write-Output "Project structure verification passed ($($swiftFiles.Count) Swift files)."
