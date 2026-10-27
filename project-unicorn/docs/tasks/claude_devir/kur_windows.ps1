param([string]$ClaudeDir = (Join-Path $env:USERPROFILE '.claude'))
$ErrorActionPreference = 'Stop'
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Sid = '6d15b35f-66f1-4e87-b274-dc8c31d2f7b4'
# This folder is <repo>\project-unicorn\docs\tasks\claude_devir.
$Repo = (Resolve-Path (Join-Path $Here '..\..\..\..')).Path.TrimEnd('\')

# Claude Code names a project folder after its path with every non-alphanumeric character turned into '-'.
$Slug = $Repo -replace '[^A-Za-z0-9]', '-'
$Proj = Join-Path $ClaudeDir "projects\$Slug"
$Mem = Join-Path $Proj 'memory'
New-Item -ItemType Directory -Force $Mem | Out-Null
Copy-Item -Recurse -Force (Join-Path $Here 'memory\*') $Mem
Copy-Item -Recurse -Force (Join-Path $Here 'oturum\*') $Proj

Write-Host "Claude proje klasoru: $Proj"
Write-Host "Simdi: cd `"$Repo`"; claude --resume $Sid"
