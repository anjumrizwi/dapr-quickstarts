# ==============================
# Dapr Local Environment Validator
# Author: Anjum Rizwi
# ==============================

Write-Host "🔍 Checking environment for Dapr local run..." -ForegroundColor Cyan
Write-Host "--------------------------------------------------`n"

# Function to check if a command exists
function Test-Command {
    param([string]$cmd)
    $exists = Get-Command $cmd -ErrorAction SilentlyContinue
    return $exists -ne $null
}

# Function to install using winget
function Install-IfMissing {
    param([string]$cmd, [string]$pkgName, [string]$displayName, [string]$versionArg = "--version")

    if (-not (Test-Command $cmd)) {
        Write-Host "❌ $displayName not found. Installing..." -ForegroundColor Yellow
        winget install --id $pkgName -e --accept-package-agreements --accept-source-agreements
    }
    else {
        Write-Host "✅ $displayName is installed. Version:" -ForegroundColor Green
        if ($cmd -eq "go") {
            & $cmd version
        }
        else {
            & $cmd $versionArg
        }
    }
}

# --- .NET 7 SDK ---
Install-IfMissing "dotnet" "Microsoft.DotNet.SDK.7" ".NET SDK 7.0"

# --- Dapr CLI ---
if (-not (Test-Command "dapr")) {
    Write-Host "❌ Dapr CLI not found. Installing..." -ForegroundColor Yellow
    Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/dapr/cli/master/install/install.ps1")
} else {
    Write-Host "✅ Dapr CLI is installed. Version:" -ForegroundColor Green
    dapr --version
}

# --- Go ---
Install-IfMissing "go" "GoLang.Go" "Go" "version"

# --- Python 3 ---
Install-IfMissing "python" "Python.Python.3.11" "Python 3"

# --- Node.js (includes npm) ---
Install-IfMissing "node" "OpenJS.NodeJS.LTS" "Node.js (with NPM)"

# --- Verify npm ---
if (Test-Command "npm") {
    Write-Host "✅ NPM is installed. Version:" -ForegroundColor Green
    npm -v
} else {
    Write-Host "⚠️ NPM not found. Try reinstalling Node.js." -ForegroundColor Yellow
}

# --- Final Summary ---
Write-Host "`n--------------------------------------------------"
Write-Host "🏁 Environment validation complete!" -ForegroundColor Cyan
Write-Host "Now you can run Dapr samples locally with:"
Write-Host "  - .NET 7  (for C# samples)"
Write-Host "  - Go      (for Go samples)"
Write-Host "  - Python3 (for Python samples)"
Write-Host "  - Node.js (for JS samples)"
Write-Host "  - Dapr CLI (for sidecar orchestration)"
Write-Host "--------------------------------------------------"
