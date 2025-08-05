# GhostWaveBT Clean Script
# This script removes all build artifacts, caches, and temporary files

param()

$ErrorActionPreference = "Continue"
$ScriptDir = $PSScriptRoot
$GeneratedDir = Join-Path $ScriptDir "generated"

function Write-Header {
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "GhostWaveBT Clean Script" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Invoke-FlutterClean {
    Write-Status "Running Flutter clean..."
    
    try {
        flutter clean *>$null
        Write-Success "Flutter clean completed"
    }
    catch {
        Write-Warning "Flutter clean failed - Flutter may not be in PATH"
    }
}

function Remove-AndroidBuildDirs {
    Write-Status "Removing Android build directories..."
    
    $AndroidDirs = @(
        "android\app\build",
        "android\.gradle", 
        "android\build",
        ".gradle",
        "build",
        "android\app\.gradle"
    )
    
    foreach ($dir in $AndroidDirs) {
        if (Test-Path $dir) {
            Write-Status "Removing $dir..."
            Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Success "Android build directories cleaned"
}

function Remove-GlobalCaches {
    Write-Status "Removing global caches..."
    
    $GlobalCaches = @(
        "$env:USERPROFILE\.gradle",
        "$env:USERPROFILE\.android\build-cache",
        "$env:USERPROFILE\.android\cache"
    )
    
    foreach ($cache in $GlobalCaches) {
        if (Test-Path $cache) {
            Write-Status "Removing $cache..."
            Remove-Item $cache -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Success "Global caches cleaned"
}

function Remove-LockFiles {
    Write-Status "Removing lock files and package caches..."
    
    Get-ChildItem -Recurse -Filter "*.lock" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Recurse -Filter ".packages" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    
    Write-Success "Lock files cleaned"
}

function Remove-TempFiles {
    Write-Status "Removing temporary files..."
    
    $TempPatterns = @(
        "$env:TEMP\flutter_build_*",
        "$env:TEMP\dart_*", 
        "$env:USERPROFILE\.dartServer"
    )
    
    foreach ($pattern in $TempPatterns) {
        Get-ChildItem $pattern -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Success "Temporary files cleaned"
}

function Clear-PubCache {
    Write-Status "Clearing pub cache..."
    
    try {
        flutter pub cache clean --force *>$null
        Write-Success "Pub cache cleared"
    }
    catch {
        Write-Warning "Pub cache clean failed - Flutter may not be available"
    }
}

function Remove-GeneratedFiles {
    Write-Host ""
    $response = Read-Host "Do you want to remove generated APK files? (y/N)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        if (Test-Path $GeneratedDir) {
            Write-Status "Removing generated APK files..."
            Remove-Item $GeneratedDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "Generated files removed"
        }
    }
    else {
        Write-Status "Keeping generated APK files"
    }
}

function Remove-VSCodeFiles {
    Write-Host ""
    $response = Read-Host "Do you want to remove VS Code workspace files? (y/N)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        if (Test-Path ".vscode") {
            Write-Status "Removing .vscode directory..."
            Remove-Item ".vscode" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "VS Code files removed"
        }
    }
    else {
        Write-Status "Keeping VS Code workspace files"
    }
}

function Show-CleanupSummary {
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Green
    Write-Host "Cleanup Summary" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    Write-Host ""
    Write-Success "All build artifacts and caches have been cleaned"
    Write-Host ""
    Write-Host "What was cleaned:"
    Write-Host "  ✓ Flutter build cache"
    Write-Host "  ✓ Android build directories"
    Write-Host "  ✓ Global Gradle and Android caches"
    Write-Host "  ✓ Lock files and package caches"
    Write-Host "  ✓ Temporary files"
    Write-Host "  ✓ Pub cache"
    Write-Host ""
    Write-Host "To rebuild your project:"
    Write-Host "  1. .\setup_script.ps1        (to reinstall dependencies)" -ForegroundColor Cyan
    Write-Host "  2. .\build_script.ps1 android (to build APK)" -ForegroundColor Cyan
    Write-Host ""
}

# Main execution
try {
    Set-Location $ScriptDir
    
    Write-Header
    Write-Host "This will remove all build artifacts, caches, and temporary files."
    Write-Host ""
    $continue = Read-Host "Press Enter to continue or Ctrl+C to cancel"
    Write-Host ""
    
    Invoke-FlutterClean
    Remove-AndroidBuildDirs
    Remove-GlobalCaches
    Remove-LockFiles
    Remove-TempFiles
    Clear-PubCache
    Remove-GeneratedFiles
    Remove-VSCodeFiles
    Show-CleanupSummary
    
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    Read-Host
}
catch {
    Write-Error "Cleanup failed: $($_.Exception.Message)"
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    Read-Host
    exit 1
}
