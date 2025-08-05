# GhostWaveBT Build Script - Improved Version
# Usage: .\build_script.ps1 [android|web|all] [-Clean]

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("android", "web", "all")]
    [string]$Platform,
    
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$GeneratedDir = Join-Path $ScriptDir "generated"
$VersionFile = Join-Path $GeneratedDir ".version"

function Write-Header {
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "GhostWaveBT Build Script - Improved" -ForegroundColor Cyan
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

function Test-Flutter {
    try {
        $null = flutter --version
        return $true
    }
    catch {
        if (Test-Path "C:\flutter\bin\flutter.bat") {
            $env:PATH += ";C:\flutter\bin"
            Write-Status "Added Flutter to PATH temporarily"
            try {
                $null = flutter --version
                return $true
            }
            catch {
                Write-Error "Flutter found but not working properly"
                return $false
            }
        }
        else {
            Write-Error "Flutter is not installed or not in PATH"
            Write-Host "Run .\setup_script.ps1 first to set up your environment"
            return $false
        }
    }
}

function New-ProjectDirectories {
    if (-not (Test-Path $GeneratedDir)) {
        New-Item -ItemType Directory -Path $GeneratedDir -Force | Out-Null
    }
}

function Get-NextVersion {
    if (Test-Path $VersionFile) {
        $currentVersion = Get-Content $VersionFile -Raw
        $versionNum = [int]($currentVersion.Trim() -replace 'v', '')
        $nextVersion = "v$($versionNum + 1)"
    }
    else {
        $nextVersion = "v1"
    }
    
    $nextVersion | Out-File $VersionFile -Encoding ASCII -NoNewline
    Write-Status "Building version: $nextVersion"
    return $nextVersion
}

function Invoke-CleanBuild {
    if ($Clean) {
        Write-Status "Performing clean build..."
        flutter clean
        
        $DirsToRemove = @("android\app\build", "build")
        foreach ($dir in $DirsToRemove) {
            if (Test-Path $dir) {
                Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
    else {
        Write-Status "Quick build (use -Clean for full clean)..."
    }
    
    flutter pub get
}

function Wait-ForApkGeneration {
    param([array]$PossibleLocations)
    
    Write-Status "Waiting for APK generation..."
    $MaxWaitTime = 45  # Increased wait time
    $WaitCount = 0
    
    do {
        Start-Sleep -Seconds 1
        $WaitCount++
        $ApkExists = $PossibleLocations | Where-Object { Test-Path $_ }
        
        if ($WaitCount % 5 -eq 0) {
            # Show progress every 5 seconds
            Write-Status "Still waiting... ($WaitCount/$MaxWaitTime seconds)"
        }
    } while (-not $ApkExists -and $WaitCount -lt $MaxWaitTime)
    
    return $ApkExists
}

function Find-ApkFile {
    Write-Status "Searching for APK file..."
    
    # Extended list of possible APK locations
    $PossibleLocations = @(
        "build\app\outputs\flutter-apk\app-debug.apk",
        "android\app\build\outputs\flutter-apk\app-debug.apk", 
        "android\app\build\outputs\apk\debug\app-debug.apk",
        "build\app\outputs\apk\debug\app-debug.apk",
        "android\app\build\outputs\apk\app\debug\app-debug.apk",
        "build\app\outputs\apk\app\debug\app-debug.apk",
        "android\app\build\outputs\apk\debug\app-arm64-v8a-debug.apk"
    )
    
    # First, check known locations
    foreach ($location in $PossibleLocations) {
        if (Test-Path $location) {
            Write-Status "Found APK at known location: $location"
            return $location
        }
    }
    
    # Wait for APK generation if not found immediately
    $ApkExists = Wait-ForApkGeneration -PossibleLocations $PossibleLocations
    if ($ApkExists) {
        Write-Status "Found APK after waiting: $ApkExists"
        return $ApkExists
    }
    
    # If still not found, do a comprehensive search
    Write-Status "Performing comprehensive APK search..."
    $ApkFiles = Get-ChildItem -Recurse -Filter "*.apk" -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -like "*debug*" -or $_.Name -like "*app*" } |
    Sort-Object LastWriteTime -Descending
    
    if ($ApkFiles) {
        Write-Status "All APK files found:"
        $ApkFiles | ForEach-Object {
            $size = [math]::Round($_.Length / 1MB, 2)
            Write-Host "  $($_.FullName) - $size MB - Modified: $($_.LastWriteTime)"
        }
        
        # Return the most recently modified APK
        $LatestApk = $ApkFiles[0].FullName
        Write-Status "Using most recent APK: $LatestApk"
        return $LatestApk
    }
    
    return $null
}

function Invoke-AndroidBuild {
    param([string]$BuildVersion)
    
    Write-Status "Building Android APK..."
    
    # Try both debug and release builds
    try {
        Write-Status "Attempting debug build..."
        flutter build apk --debug --target-platform android-arm64 --tree-shake-icons
    }
    catch {
        Write-Warning "Debug build failed, trying release build..."
        flutter build apk --release --target-platform android-arm64 --tree-shake-icons
    }
    
    # Give extra time for build completion
    Write-Status "Build command completed, searching for APK..."
    Start-Sleep -Seconds 3
    
    $ApkSource = Find-ApkFile
    
    if (-not $ApkSource -or -not (Test-Path $ApkSource)) {
        Write-Error "APK file not found - build may have failed"
        Write-Status "Showing all files in build directories:"
        
        $BuildDirs = @("build", "android\app\build")
        foreach ($dir in $BuildDirs) {
            if (Test-Path $dir) {
                Write-Host "Contents of ${dir}:"
                Get-ChildItem $dir -Recurse -ErrorAction SilentlyContinue | 
                Where-Object { -not $_.PSIsContainer } | 
                Select-Object -First 10 | 
                ForEach-Object { Write-Host "  $($_.FullName)" }
            }
        }
        throw "Build failed - no APK generated"
    }
    
    $VersionedApk = Join-Path $GeneratedDir "bt_controller_$BuildVersion.apk"
    Copy-Item $ApkSource $VersionedApk -Force
    
    # Verify the copied file
    if (Test-Path $VersionedApk) {
        $ApkSize = (Get-Item $VersionedApk).Length / 1MB
        Write-Success "Android APK built successfully: $VersionedApk ($([math]::Round($ApkSize, 2)) MB)"
        Write-Status "Source: $ApkSource"
        
        # Additional verification
        $Hash = Get-FileHash $VersionedApk -Algorithm MD5
        Write-Status "APK Hash: $($Hash.Hash.Substring(0,8))..."
    }
    else {
        Write-Error "Failed to copy APK to generated directory"
        throw "Copy operation failed"
    }
}

function Invoke-WebBuild {
    param([string]$BuildVersion)
    
    Write-Status "Building for Web..."
    flutter build web --debug
    
    $WebDir = Join-Path $GeneratedDir "web_$BuildVersion"
    if (Test-Path "build\web") {
        if (Test-Path $WebDir) {
            Remove-Item $WebDir -Recurse -Force
        }
        Copy-Item "build\web" $WebDir -Recurse -Force
        Write-Success "Web build created: $WebDir"
        
        # Check index.html exists
        $IndexPath = Join-Path $WebDir "index.html"
        if (Test-Path $IndexPath) {
            Write-Status "Web build verified - index.html found"
        }
        else {
            Write-Warning "Web build may be incomplete - index.html not found"
        }
    }
    else {
        throw "Web build directory not found"
    }
}

function Show-GeneratedFiles {
    Write-Status "Generated files:"
    if (Test-Path $GeneratedDir) {
        Write-Host ""
        
        $ApkFiles = Get-ChildItem $GeneratedDir -Filter "*.apk" | Sort-Object LastWriteTime -Descending
        if ($ApkFiles) {
            Write-Host "APK Files:" -ForegroundColor Yellow
            $ApkFiles | ForEach-Object {
                $size = $_.Length / 1MB
                Write-Host "  $($_.Name) - $([math]::Round($size, 2)) MB - $($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))"
            }
        }
        
        $WebDirs = Get-ChildItem $GeneratedDir -Directory -Filter "web_*" | Sort-Object LastWriteTime -Descending
        if ($WebDirs) {
            Write-Host "Web Builds:" -ForegroundColor Yellow
            $WebDirs | ForEach-Object {
                Write-Host "  $($_.Name) - $($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))"
            }
        }
        
        Write-Host ""
        if (Test-Path $VersionFile) {
            $currentVersion = Get-Content $VersionFile -Raw
            Write-Status "Current version: $($currentVersion.Trim())"
        }
        
        # Show total size
        $TotalSize = (Get-ChildItem $GeneratedDir -Recurse -File | Measure-Object Length -Sum).Sum / 1MB
        Write-Status "Total generated files size: $([math]::Round($TotalSize, 2)) MB"
    }
    else {
        Write-Warning "No generated files found"
    }
}

function Show-Usage {
    Write-Host "Usage: .\build_script.ps1 [android|web|all] [-Clean]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  android  - Build Android APK"
    Write-Host "  web      - Build for Web"
    Write-Host "  all      - Build for all platforms"
    Write-Host "  -Clean   - Clean build cache before building"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\build_script.ps1 android         # Quick Android build"
    Write-Host "  .\build_script.ps1 android -Clean  # Clean Android build"
    Write-Host "  .\build_script.ps1 web             # Web build"
    Write-Host "  .\build_script.ps1 all             # Build everything"
    Write-Host ""
    Write-Host "Improvements in this version:"
    Write-Host "  - Better APK detection and waiting"
    Write-Host "  - More comprehensive file searching"
    Write-Host "  - Enhanced error reporting"
    Write-Host "  - Fallback to release build if debug fails"
}

# Main execution
try {
    Set-Location $ScriptDir
    
    Write-Header
    Write-Status "Building for platform: $Platform"
    if ($Clean) {
        Write-Status "Clean build enabled"
    }
    
    if (-not (Test-Flutter)) {
        exit 1
    }
    
    New-ProjectDirectories
    $buildVersion = Get-NextVersion
    Invoke-CleanBuild
    
    switch ($Platform) {
        "android" {
            Invoke-AndroidBuild $buildVersion
        }
        "web" {
            Invoke-WebBuild $buildVersion
        }
        "all" {
            Invoke-AndroidBuild $buildVersion
            Write-Host ""
            Invoke-WebBuild $buildVersion
        }
    }
    
    Write-Host ""
    Write-Success "Build completed successfully!"
    Show-GeneratedFiles
    
    Write-Host ""
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    Read-Host
}
catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Debug Information:" -ForegroundColor Yellow
    Write-Host "  Script Directory: $ScriptDir"
    Write-Host "  Generated Directory: $GeneratedDir"
    Write-Host "  PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Host ""
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    Read-Host
    exit 1
}