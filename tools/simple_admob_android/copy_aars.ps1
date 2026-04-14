param(
    [string]$ProjectRoot = "..\.."
)

$DebugSrc = "plugin/build/outputs/aar/plugin-debug.aar"
$ReleaseSrc = "plugin/build/outputs/aar/plugin-release.aar"

$DebugDst = Join-Path $ProjectRoot "addons/simple_admob/bin/debug/simple-admob-debug.aar"
$ReleaseDst = Join-Path $ProjectRoot "addons/simple_admob/bin/release/simple-admob-release.aar"

if (!(Test-Path $DebugSrc)) {
    Write-Error "Missing debug AAR: $DebugSrc"
    exit 1
}
if (!(Test-Path $ReleaseSrc)) {
    Write-Error "Missing release AAR: $ReleaseSrc"
    exit 1
}

Copy-Item $DebugSrc $DebugDst -Force
Copy-Item $ReleaseSrc $ReleaseDst -Force

Write-Output "Copied AARs to addons/simple_admob/bin"
