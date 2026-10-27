param(
    [string]$SkillName = 'harmony-arkts-delivery',
    [switch]$SkipProject,
    [switch]$SkipUser
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$source = Join-Path $projectRoot "skills/$SkillName"
$manifest = Join-Path $source 'SKILL.md'

if (-not (Test-Path $manifest)) {
    throw "Skill source not found: $source"
}

$destinations = @()
if (-not $SkipProject) {
    $destinations += (Join-Path $projectRoot ".dsh/skills/$SkillName")
    $destinations += (Join-Path $projectRoot ".claude/skills/$SkillName")
}
if (-not $SkipUser) {
    $destinations += (Join-Path $HOME ".dsh/skills/$SkillName")
    $destinations += (Join-Path $HOME ".claude/skills/$SkillName")
}

foreach ($dest in $destinations) {
    if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
    New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
    Copy-Item -LiteralPath $source -Destination $dest -Recurse -Force
    $installed = Join-Path $dest 'SKILL.md'
    if (-not (Test-Path $installed)) { throw "Install failed: $dest" }
    $hash = (Get-FileHash $installed -Algorithm SHA256).Hash.Substring(0, 12)
    Write-Host "installed  $dest  (SKILL.md sha256:$hash)"
}

Write-Host ''
Write-Host 'DSH:      restart the session (or reopen the project) to load the skill catalog.'
Write-Host 'Claude:   restart Claude Code; the skill is discovered under ~/.claude/skills or .claude/skills.'
