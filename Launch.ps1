# Finds the Spelunky 2 installation path
# And launches the save scanning program

$ManualInstructions = @'
You can supply the Spelunky 2 installation path manually by launching Powershell and starting .\Shutdown.ps1 and passing the installation directory like so:

.\Shutdown.ps1 'c:\program files (x86)\steam\steamapps\common\Spelunky 2'

Obviously you'll need to change the path into whatever is appropriate for your system.
'@

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
            if (Test-Path -LiteralPath $GamePath) {
                Write-Output $GamePath
            }
        }
    }
}

$SteamReg = Get-ItemProperty `
    -Path HKCU:\Software\Valve\Steam `
    -ErrorVariable SteamRegError

if ($SteamRegError) {
    Write-Warning "Couldn't retrieve Steam installation information."
    Write-Host $ManualInstructions
    Exit 1
}

$SteamPath = $SteamReg.SteamPath
$MainAppPath = Join-Path -Path $SteamPath -ChildPath "steamapps"
[Array]$ExtraAppPaths = Get-SteamExtraAppPaths $SteamPath
[Array]$Paths = $ExtraAppPaths + @($MainAppPath)

$Spelunky2Path = Find-GamePath -Paths $Paths -GameId '418530' -GameDir 'Spelunky 2'

if ($null -eq $Spelunky2Path) {
	Write-Warning "Couldn't find Spelunky 2's installation directory."
    Write-Host $ManualInstructions
    Exit 1
}

.\Shutdown -GamePath $Spelunky2Path
