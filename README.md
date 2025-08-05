# GhostWaveBT - Bluetooth Car Controller

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.32.8-blue?logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-green)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Build](https://img.shields.io/badge/Build-Passing-brightgreen)

*A Flutter-based Bluetooth controller app for car movement with a clean, modern interface.*

</div>


##  App Features

- **8-Direction Movement Control**: Forward, backward, left, right
- **Bluetooth Connectivity**: Connect to Bluetooth-enabled devices
- **Modern UI**: Dark theme with controls

##  Installation

1. **Clone the repository**
   ```powershell
   cd ghostwave-bt
   ```

2. **Run setup script**
   ```powershell
   .\setup_script.ps1
   ```

3. **Build the app**
   ```powershell
   .\build_script.ps1 android
   ```

##  Project Structure

```
├── lib/                          # Flutter source code
│   ├── main.dart                 # App entry point
│   ├── providers/                # State management
│   ├── screens/                  # App screens
│   └── widgets/                  # Reusable components
├── android/                      # Android-specific files
├── assets/                       # Images and resources
├── generated/                    # Built APK and web files
├── setup_script.bat             # Environment setup
├── build_simple.bat             # Build script
├── clean_script.bat             # Cleanup script
└── quick_commands.bat            # Interactive menu
```


##  Development Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup_script.ps1` | Initial setup and dependency installation | Run once when setting up |
| `build_script.ps1` | Build APK/web app with versioning | `.\build_script.ps1 android` |
| `clean_script.ps1` | Remove all build artifacts and caches | Run when having build issues |

## Troubleshooting

### Flutter not found
Run `.\setup_script.ps1` - it will guide you through Flutter installation.

###  Built Files

- **APK files**: `generated/bt_controller_vX.apk`
