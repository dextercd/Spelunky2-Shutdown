# Finds the Spelunky 2 installation path
# And launches the save scanning program

function Get-SteamExtraAppPaths {
    param(
        [string]$SteamPath
    )

    $LibraryFolders = Join-Path -Path $SteamPath -ChildPath "steamapps\libraryfolders.vdf"
    [Array]$Lines = (Get-Content $LibraryFolders).Split('`n')
    [Array]$Entries = $Lines | ? {$_ -match '^\s*"[0-9]*"'}
    $Paths = $Entries | % {
        $null = $_ -match '"(?<number>[0-9]+)"\s*"(?<path>.*)"'
        $Path = $Matches.path
        $Path = $Path -replace '\\"', '"'
        $Path = $Path -replace '\\\\', '\'
        Join-Path $Path -ChildPath "steamapps"
    }

    Write-Output -NoEnumerate $Paths
}

function Find-GamePath {
    param(
        [Parameter(Mandatory)]
        [string[]]$Paths,

        [Parameter(Mandatory)]
        [string]$GameId,

        [Parameter(Mandatory)]
        [string]$GameDir
    )

    foreach ($Path in $Paths) {
        $ManifestPath = Join-Path $Path ('appmanifest_' + $GameId + '.acf')
        if (Test-Path -LiteralPath $ManifestPath) {
            $GamePath = Join-Path -Path $Path -ChildPath "common\$GameDir"
            Write-Output $GamePath
        }
    }
}

$SteamReg = Get-ItemProperty `
    -Path HKCU:\Software\Valve\Steam `
    -ErrorVariable SteamRegError

if ($SteamRegError) {
    Write-Warning "Couldn't retrieve Steam installation information."
    Exit 1
}

$SteamPath = $SteamReg.SteamPath
$MainAppPath = Join-Path -Path $SteamPath -ChildPath "steamapps"
[Array]$ExtraAppPaths = Get-SteamExtraAppPaths $SteamPath
[Array]$Paths = $ExtraAppPaths + @($MainAppPath)

$Spelunky2Path = Find-GamePath -Paths $Paths -GameId '418530' -GameDir 'Spelunky 2'

.\Shutdown -GamePath $Spelunky2Path
