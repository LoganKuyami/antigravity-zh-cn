param([ValidateSet('Chinese','English')][string]$Mode='Chinese',[string]$AppPath,[string]$BuildDirectory)
$ErrorActionPreference='Stop'
$packRoot=if ($BuildDirectory) { [IO.Path]::GetFullPath($BuildDirectory) } else { Join-Path $PSScriptRoot '.local-build' }
$agRoot=if ($AppPath) { [IO.Path]::GetFullPath($AppPath) } else { Join-Path $env:LOCALAPPDATA 'Programs\antigravity' }
$agRes=Join-Path $agRoot 'resources'
$agExe=Join-Path $agRoot 'Antigravity.exe'
$manifest=Get-Content -LiteralPath (Join-Path $packRoot 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not (Test-Path -LiteralPath $agExe)) { throw 'Antigravity installation not found.' }
foreach ($entry in $manifest.files.PSObject.Properties) {
    $file=Join-Path $packRoot $entry.Name
    if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -ne $entry.Value) { throw "Package checksum failed: $($entry.Name)" }
}
$liveAsar=Join-Path $agRes 'app.asar'
$currentHash=(Get-FileHash -LiteralPath $liveAsar -Algorithm SHA256).Hash
$englishHash=$manifest.files.'payload/app.english.asar'
$chineseHash=$manifest.files.'payload/app.chinese.asar'
if ($manifest.acceptedInstalledAsarSha256 -notcontains $currentHash) { throw "Application differs from supported version $($manifest.version). Refusing to overwrite an update or unknown patch." }
$running=@(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq 'Antigravity' -and $_.Path -eq $agExe })
if ($running.Count -gt 0) { throw 'Exit Antigravity completely using its tray Quit command, then run this script again. No running tasks were terminated.' }
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss-fff'
$backup=Join-Path $agRes ('zh-backups\'+$stamp)
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Copy-Item -LiteralPath $liveAsar -Destination (Join-Path $backup 'app.asar')
$bundle=Join-Path $agRes 'web_bundle'
$staging=Join-Path $agRes ('web_bundle.staging-'+$stamp)
$oldBundleMoved=$false
$newBundleInstalled=$false
$hadBundle=Test-Path -LiteralPath $bundle
$backupBundle=Join-Path $backup 'web_bundle'
try {
    if ($Mode -eq 'Chinese') { Copy-Item -LiteralPath (Join-Path $packRoot 'payload\web_bundle') -Destination $staging -Recurse }
    if ($hadBundle) {
        $resolved=(Resolve-Path -LiteralPath $bundle).Path
        if ($resolved -ne [IO.Path]::GetFullPath((Join-Path $agRes 'web_bundle'))) { throw 'Unexpected bundle path' }
        Move-Item -LiteralPath $resolved -Destination $backupBundle
        $oldBundleMoved=$true
    }
    if ($Mode -eq 'Chinese') {
        if ([IO.Path]::GetFullPath($staging).StartsWith([IO.Path]::GetFullPath($agRes)+'\') -ne $true) { throw 'Unexpected staging path' }
        Move-Item -LiteralPath $staging -Destination $bundle
        $newBundleInstalled=$true
        Copy-Item -LiteralPath (Join-Path $packRoot 'payload\app.chinese.asar') -Destination $liveAsar -Force
    } else {
        Copy-Item -LiteralPath (Join-Path $packRoot 'payload\app.english.asar') -Destination $liveAsar -Force
    }
    $expected=if ($Mode -eq 'Chinese') { $chineseHash } else { $englishHash }
    if ((Get-FileHash -LiteralPath $liveAsar -Algorithm SHA256).Hash -ne $expected) { throw 'Installed application checksum failed' }
    if ($Mode -eq 'Chinese') {
        foreach ($entry in $manifest.files.PSObject.Properties) {
            if ($entry.Name.StartsWith('payload/web_bundle/')) {
                $installed=Join-Path $bundle $entry.Name.Substring('payload/web_bundle/'.Length)
                if ((Get-FileHash -LiteralPath $installed -Algorithm SHA256).Hash -ne $entry.Value) { throw 'Installed UI checksum failed' }
            }
        }
    }
} catch {
    Copy-Item -LiteralPath (Join-Path $backup 'app.asar') -Destination $liveAsar -Force
    if ($newBundleInstalled -and (Test-Path -LiteralPath $bundle)) {
        $resolved=(Resolve-Path -LiteralPath $bundle).Path
        if ($resolved -ne [IO.Path]::GetFullPath((Join-Path $agRes 'web_bundle'))) { throw 'Rollback path mismatch' }
        Move-Item -LiteralPath $resolved -Destination (Join-Path $backup 'failed-new-bundle')
    }
    if ($oldBundleMoved -and (Test-Path -LiteralPath $backupBundle)) {
        $resolved=(Resolve-Path -LiteralPath $backupBundle).Path
        if (-not $resolved.StartsWith([IO.Path]::GetFullPath($backup)+'\')) { throw 'Rollback backup path mismatch' }
        Move-Item -LiteralPath $resolved -Destination $bundle
    }
    throw
}
Write-Host "Installed $Mode. Backup: $backup"
Start-Process -FilePath $agExe


