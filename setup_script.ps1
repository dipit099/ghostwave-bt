# GhostWaveBT Setup Script
# This script sets up the development environment and verifies everything is working

param()

$ErrorActionPreference = "Continue"
$ScriptDir = $PSScriptRoot
$GeneratedDir = Join-Path $ScriptDir "generated"

function Write-Header {
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "GhostWaveBT Setup Script" -ForegroundColor Cyan
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
    Write-Status "Checking Flutter installation..."
    
    try {
        $null = flutter --version
        Write-Success "Flutter is installed and working"
        flutter --version
        Write-Host ""
        return $true
    }
    catch {
        # Try to add Flutter to PATH if it exists at common location
        if (Test-Path "C:\flutter\bin\flutter.bat") {
            $env:PATH += ";C:\flutter\bin"
            Write-Status "Added Flutter to PATH temporarily"
            
            try {
                $null = flutter --version
                Write-Success "Flutter is now working"
                flutter --version
                Write-Host ""
                return $true
            }
            catch {
                Write-Error "Flutter found but not working properly"
                Show-FlutterInstallHelp
                return $false
            }
        }
        else {
            Write-Error "Flutter is not installed or not in PATH"
            Show-FlutterInstallHelp
            return $false
        }
    }
}

function Show-FlutterInstallHelp {
    Write-Host ""
    Write-Host "Please install Flutter first:" -ForegroundColor Yellow
    Write-Host "1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows"
    Write-Host "2. Extract to C:\flutter"
    Write-Host "3. Add C:\flutter\bin to your PATH"
    Write-Host "4. Restart PowerShell and run this script again"
    Write-Host ""
    Read-Host "Press Enter to exit"
}

function Invoke-FlutterDoctor {
    Write-Status "Running Flutter Doctor to check setup..."
    flutter doctor
    Write-Host ""
}

function Install-ProjectDependencies {
    Write-Status "Setting up project dependencies..."
    
    try {
        flutter pub get
        Write-Success "Dependencies installed successfully"
        Write-Host ""
    }
    catch {
        Write-Error "Failed to get Flutter dependencies"
        throw "Dependency installation failed"
    }
}

function New-ProjectDirectories {
    Write-Status "Creating project directories..."
    
    if (-not (Test-Path $GeneratedDir)) {
        New-Item -ItemType Directory -Path $GeneratedDir -Force | Out-Null
        Write-Status "Created generated directory: $GeneratedDir"
    }
}

function Test-WebBuild {
    Write-Status "Testing web build capability..."
    
    try {
        flutter build web --debug *>$null
        Write-Success "Web build test passed"
    }
    catch {
        Write-Warning "Web build test failed - this is optional"
    }
    Write-Host ""
}

function Test-AndroidBuild {
    Write-Status "Testing Android build capability..."
    
    try {
        flutter build apk --debug --dry-run *>$null
        Write-Success "Android build test passed"
    }
    catch {
        Write-Warning "Android build test failed - check Android SDK setup"
    }
    Write-Host ""
}

function Show-NextSteps {
    Write-Host "====================================" -ForegroundColor Green
    Write-Host "Setup Complete!" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. .\build_script.ps1 android      (to build APK)" -ForegroundColor Cyan
    Write-Host "2. flutter run -d chrome           (to test in browser)" -ForegroundColor Cyan
    Write-Host "3. flutter devices                 (to see available devices)" -ForegroundColor Cyan
    Write-Host "4. .\clean_script.ps1              (to clean build files)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available build options:"
    Write-Host "  .\build_script.ps1 android            - Build Android APK"
    Write-Host "  .\build_script.ps1 android -Clean     - Clean build Android APK"
    Write-Host "  .\build_script.ps1 web                - Build for Web"
    Write-Host ""
}

# Main execution
try {
    Set-Location $ScriptDir
    
    Write-Header
    
    if (-not (Test-Flutter)) {
        exit 1
    }
    
    New-ProjectDirectories
    Install-ProjectDependencies
    Invoke-FlutterDoctor
    Test-WebBuild
    Test-AndroidBuild
    Show-NextSteps
    
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    Read-Host
}
catch {
    Write-Error "Setup failed: $($_.Exception.Message)"
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    Read-Host
    exit 1
}
