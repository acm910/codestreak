param(
    [ValidateSet('build', 'test', 'clean')]
    [string]$Task = 'build',
    [string]$Product = 'default',
    [ValidateSet('debug', 'release')]
    [string]$BuildMode = 'debug',
    [string]$RepoRoot = ''
)

$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) { $RepoRoot = (Get-Location).Path }
if (-not (Test-Path (Join-Path $RepoRoot 'AppScope/app.json5'))) {
    throw "Not a HarmonyOS project root: $RepoRoot. Run from the project root or pass -RepoRoot."
}

function Find-DevEcoSdk {
    $candidates = @()
    if ($env:DEVECO_SDK_HOME) { $candidates += $env:DEVECO_SDK_HOME }
    $candidates += @(
        'D:\develop\harmony\DevEco Studio\sdk',
        (Join-Path $env:LOCALAPPDATA 'Huawei\Sdk'),
        '/Applications/DevEco-Studio.app/Contents/sdk',
        (Join-Path $HOME 'Library/Huawei/Sdk')
    )
    foreach ($path in $candidates) {
        if ($path -and (Test-Path (Join-Path $path 'default'))) { return $path }
        if ($path -and (Test-Path $path)) { return $path }
    }
    throw 'HarmonyOS SDK not found. Set DEVECO_SDK_HOME to the DevEco Studio sdk directory.'
}

$sdk = Find-DevEcoSdk
$env:DEVECO_SDK_HOME = $sdk
$studio = Split-Path $sdk -Parent

$node = Join-Path $studio 'tools\node\node.exe'
if (-not (Test-Path $node)) {
    $cmd = Get-Command node -ErrorAction SilentlyContinue
    if (-not $cmd) { throw "Node not found under $studio or PATH." }
    $node = $cmd.Source
}
$hvigor = Join-Path $studio 'tools\hvigor\bin\hvigorw.js'
if (-not (Test-Path $hvigor)) { throw "hvigorw.js not found under $studio." }

Write-Host "SDK:    $sdk"
Write-Host "Node:   $node"
Write-Host "Hvigor: $hvigor"

Push-Location $RepoRoot
try {
    switch ($Task) {
        'build' {
            & $node $hvigor --no-daemon assembleHap -p "product=$Product" -p "buildMode=$BuildMode"
            if ($LASTEXITCODE -ne 0) { throw "assembleHap failed with exit code $LASTEXITCODE" }
            $hap = "entry/build/$Product/outputs/$Product/entry-$Product-unsigned.hap"
            if (Test-Path $hap) {
                $size = [math]::Round((Get-Item $hap).Length / 1KB, 1)
                Write-Host "HAP: $hap ($size KB)"
            }
        }
        'test' {
            & $node $hvigor --no-daemon test -p "product=$Product"
            if ($LASTEXITCODE -ne 0) { throw "test failed with exit code $LASTEXITCODE" }
            $result = "entry/.test/$Product/intermediates/test/coverage_data/test_result.txt"
            if (Test-Path $result) {
                Get-Content $result -Encoding UTF8 | Select-Object -Last 1
            }
            $coverage = "entry/.test/$Product/outputs/test/reports/coverageReport.json"
            if (Test-Path $coverage) {
                Write-Host "Coverage: $coverage"
            }
        }
        'clean' {
            & $node $hvigor --no-daemon clean
            if ($LASTEXITCODE -ne 0) { throw "clean failed with exit code $LASTEXITCODE" }
        }
    }
}
finally {
    Pop-Location
}
