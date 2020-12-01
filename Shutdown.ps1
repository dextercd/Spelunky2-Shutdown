param(
    [string]$GamePath
)

Write-Host "Using this installation directory: $GamePath"

$ScanDelay = 1000

$SavePath = Join-Path -Path $GamePath -ChildPath 'savegame.sav'

function Read-Deaths {
    $bytes = [System.IO.File]::ReadAllBytes($SavePath)
    $death_count = [BitConverter]::ToInt32($bytes, 1170)
    $death_count
}

$InitialDeathCount = Read-Deaths
while($true) {
    $NewDeathCount = Read-Deaths

    if ($NewDeathCount -gt $InitialDeathCount) {
        Stop-Computer -ComputerName localhost
        Exit 0
    }

    Start-Sleep -Milliseconds $ScanDelay
}





