param(
    [ValidateSet('list', 'shot', 'tap', 'swipe', 'restart', 'start', 'stop', 'log')]
    [string]$Action = 'list',
    [string]$Name = 'screen',
    [string]$Target = '',
    [string]$Bundle = '',
    [int]$X = 0,
    [int]$Y = 0,
    [int]$FromX = 0,
    [int]$FromY = 0,
    [int]$ToX = 0,
    [int]$ToY = 0,
    [string]$Tag = 'CS-',
    [int]$WaitMs = 800,
    [string]$RepoRoot = ''
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = (Get-Location).Path }

function Find-Hdc {
    $candidates = @()
    if ($env:HDC) { $candidates += $env:HDC }
    $candidates += @(
        'D:\develop\harmony\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe',
        '/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc'
    )
    foreach ($path in $candidates) { if ($path -and (Test-Path $path)) { return $path } }
    $cmd = Get-Command hdc -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    throw 'hdc not found. Set HDC or install DevEco Studio.'
}

$hdc = Find-Hdc

function Invoke-Hdc {
    param([string[]]$HdcArgs)
    $prefix = @()
    if ($Target) { $prefix = @('-t', $Target) }
    & $hdc @prefix @HdcArgs
    if ($LASTEXITCODE -ne 0) { throw "hdc $($HdcArgs -join ' ') failed with exit code $LASTEXITCODE" }
}

function Get-FirstTarget {
    $lines = & $hdc list targets
    foreach ($line in $lines) {
        $t = $line.Trim()
        if ($t -and $t -notmatch 'Offline' -and $t -notmatch 'Empty') { return $t }
    }
    throw 'No online HDC target. Start the emulator/device and retry.'
}

switch ($Action) {
    'list' {
        & $hdc list targets
    }
    'shot' {
        if (-not $Target) { $script:Target = Get-FirstTarget }
        $remote = "/data/local/tmp/$Name.jpeg"
        Invoke-Hdc @('shell', 'snapshot_display', '-f', $remote)
        $dir = Join-Path $RepoRoot 'artifacts'
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $local = Join-Path $dir "$Name.jpeg"
        Invoke-Hdc @('file', 'recv', $remote, $local)
        Write-Host "Screenshot: $local"
    }
    'tap' {
        if (-not $Target) { $script:Target = Get-FirstTarget }
        Invoke-Hdc @('shell', 'uitest', 'uiInput', 'click', "$X", "$Y")
        Start-Sleep -Milliseconds $WaitMs
    }
    'swipe' {
        if (-not $Target) { $script:Target = Get-FirstTarget }
        Invoke-Hdc @('shell', 'uitest', 'uiInput', 'swipe', "$FromX", "$FromY", "$ToX", "$ToY", '600')
        Start-Sleep -Milliseconds $WaitMs
    }
    'restart' {
        if (-not $Target) { $script:Target = Get-FirstTarget }
        if (-not $Bundle) { throw 'Pass -Bundle com.example.app for restart.' }
        Invoke-Hdc @('shell', 'aa', 'force-stop', $Bundle)
        Start-Sleep -Milliseconds 400
        Invoke-Hdc @('shell', 'aa', 'start', '-a', 'EntryAbility', '-b', $Bundle)
        Start-Sleep -Milliseconds 2500
    }
    'start' {
        if (-not $Target) { $script:Target = Get-FirstTarget }
        if (-not $Bundle) { throw 'Pass -Bundle com.example.app for start.' }
        Invoke-Hdc @('shell', 'aa', 'start', '-a', 'EntryAbility', '-b', $Bundle)
    }
    'stop' {
        if (-not $Target) { $script:Target = Get-FirstTarget }
        if (-not $Bundle) { throw 'Pass -Bundle com.example.app for stop.' }
        Invoke-Hdc @('shell', 'aa', 'force-stop', $Bundle)
    }
    'log' {
        if (-not $Target) { $script:Target = Get-FirstTarget }
        & $hdc -t $Target shell "hilog -x | grep '$Tag' | tail -50"
    }
}
