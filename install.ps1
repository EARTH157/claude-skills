<#
.SYNOPSIS
  Link the skills in this repo into every skills-compatible agent on this machine.

.DESCRIPTION
  Agent Skills (https://agentskills.io) is an open format, but the spec does not say
  where a client looks for skills - each tool picks its own directory. This script
  creates a directory junction from each tool's skills directory to the skills in
  this repo, so there is exactly one source of truth: edit here, every agent sees it.

  Junctions do not require administrator rights on Windows.

.EXAMPLE
  .\install.ps1 -WhatIf
  Show what would be linked without touching anything.

.EXAMPLE
  .\install.ps1
  Link into every tool whose config directory already exists.

.EXAMPLE
  .\install.ps1 -Tools claude,cursor
  Link into specific tools only.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string[]] $Tools,
    [switch] $Force
)

$ErrorActionPreference = 'Stop'
$repoSkills = Join-Path $PSScriptRoot 'skills'

# Each tool's personal (global) skills directory, relative to $HOME.
# Verify against your tool's own docs before trusting an entry - these move.
$targets = [ordered]@{
    'claude' = '.claude/skills'      # https://code.claude.com/docs/en/skills
    'codex'  = '.codex/skills'       # https://developers.openai.com/codex/skills/
    'cursor' = '.cursor/skills'      # https://cursor.com/docs/context/skills
    'gemini' = '.gemini/skills'      # https://geminicli.com/docs/cli/skills/
    'agents' = '.agents/skills'      # vendor-neutral path some clients also scan
}

if ($Tools) {
    $unknown = $Tools | Where-Object { -not $targets.Contains($_) }
    if ($unknown) {
        throw "Unknown tool(s): $($unknown -join ', '). Known: $($targets.Keys -join ', ')"
    }
    $selected = $Tools
} else {
    $selected = $targets.Keys
}

$skills = Get-ChildItem -Path $repoSkills -Directory
if (-not $skills) { throw "No skills found in $repoSkills" }

Write-Host "Source: $repoSkills"
Write-Host "Skills: $($skills.Name -join ', ')`n"

foreach ($tool in $selected) {
    $skillsDir = Join-Path $HOME $targets[$tool]
    $toolRoot  = Split-Path $skillsDir -Parent

    # Only install into tools that are actually present, unless -Force.
    if (-not (Test-Path $toolRoot) -and -not $Force) {
        Write-Host "skip  $tool  (no $toolRoot - pass -Force to create it)" -ForegroundColor DarkGray
        continue
    }

    if (-not (Test-Path $skillsDir)) {
        if ($PSCmdlet.ShouldProcess($skillsDir, 'Create directory')) {
            New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
        }
    }

    foreach ($skill in $skills) {
        $link = Join-Path $skillsDir $skill.Name

        if (Test-Path $link) {
            $item = Get-Item $link -Force
            $isJunction = $item.LinkType -eq 'Junction'
            if ($isJunction -and $item.Target -contains $skill.FullName) {
                Write-Host "ok    $tool/$($skill.Name)  (already linked)" -ForegroundColor DarkGray
                continue
            }
            if (-not $Force) {
                Write-Warning "$tool/$($skill.Name) exists and is not a link to this repo. Use -Force to replace."
                continue
            }
            if ($PSCmdlet.ShouldProcess($link, 'Remove existing entry')) {
                if ($isJunction) {
                    # Remove the junction itself, never its contents.
                    [System.IO.Directory]::Delete($link)
                } else {
                    Remove-Item $link -Recurse -Force
                }
            }
        }

        if ($PSCmdlet.ShouldProcess($link, "Junction -> $($skill.FullName)")) {
            New-Item -ItemType Junction -Path $link -Target $skill.FullName | Out-Null
            Write-Host "link  $tool/$($skill.Name)" -ForegroundColor Green
        }
    }
}

Write-Host "`nDone. Restart your agent so it rescans its skills directory."
