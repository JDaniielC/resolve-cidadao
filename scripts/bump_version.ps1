# Atualiza config/version em project.godot e prepara tag de release.
# Uso: .\scripts\bump_version.ps1 1.9.2

param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$projectFile = Join-Path $PSScriptRoot "..\project.godot"
$content = Get-Content $projectFile -Raw

if ($content -notmatch 'config/version="([^"]+)"') {
    Write-Error "config/version não encontrado em project.godot"
    exit 1
}

$oldVersion = $Matches[1]
$newContent = $content -replace ('config/version="' + [regex]::Escape($oldVersion) + '"'), ('config/version="' + $Version + '"')
Set-Content -Path $projectFile -Value $newContent -NoNewline

Write-Host "Versão atualizada: $oldVersion -> $Version"
Write-Host ""
Write-Host "Próximos passos:"
Write-Host "  1. Atualize CHANGELOG.md"
Write-Host "  2. git add project.godot CHANGELOG.md"
Write-Host "  3. git commit -m `"chore: release v$Version`""
Write-Host "  4. git tag v$Version"
Write-Host "  5. git push origin main --tags"
