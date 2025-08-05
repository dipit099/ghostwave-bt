# 🎮 GhostWaveBT - Bluetooth Car Controller

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.32.8-blue?logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-green)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Build](https://img.shields.io/badge/Build-Passing-brightgreen)

*A Flutter-based Bluetooth controller app for 8-direction car movement with a clean, modern interface.*

</div>

## ✨ Features

- 🎮 **8-Direction Movement Control** - Forward, backward, left, right, and diagonal movements
- 📡 **Bluetooth Connectivity** - Connect to Bluetooth-enabled devices
- 🎨 **Modern UI** - Dark theme with orange accent controls
- 📱 **Responsive Design** - Works on phones and tablets
- 🌐 **Web Testing** - Test functionality in browser before building APK
- 🔄 **Auto-versioning** - Automatic version management for builds

## 📱 Screenshots

*Add screenshots of your app here*

## 🚀 Quick Start

## 📋 Prerequisites

- Windows 10/11
- PowerShell 5.0+
- Flutter SDK 3.32.8+
- Android SDK (for APK builds)
- Git

## 🔧 Installation

1. **Clone the repository**
   ```powershell
   git clone https://github.com/yourusername/ghostwave-bt.git
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

## 🎯 Usage

### Development Commands
```powershell
.\setup_script.ps1
```

### Building the App
```powershell
.\build_script.ps1 android          # Build Android APK
.\build_script.ps1 android -Clean   # Clean build
.\build_script.ps1 web              # Build for web
.\build_script.ps1 all              # Build everything
```

### Cleaning Up
```powershell
.\clean_script.ps1
```

### Development Commands

**Setup Environment:**
```powershell
.\setup_script.ps1
```

**Build Applications:**
```powershell
.\build_script.ps1 android          # Build Android APK
.\build_script.ps1 android -Clean   # Clean build
.\build_script.ps1 web              # Build for web
.\build_script.ps1 all              # Build everything
```

**Clean Project:**
```powershell
.\clean_script.ps1
```

### Testing

**Run in Browser:**
```powershell
flutter run -d chrome
```

**Install on Android:**
1. Enable Developer Options and USB Debugging
2. Connect device via USB
3. Install the APK:
   ```powershell
   adb install generated\bt_controller_vX.apk
   ```

## 🏗️ Building from Source

1. Ensure all prerequisites are installed
2. Run the setup script to configure the environment
3. Use the build script to create APK or web builds
4. Generated files will be in the `generated/` directory

## 📦 Dependencies

## 📁 Project Structure

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

## 🛠️ Tech Stack

- **Framework**: Flutter 3.32.8
- **Language**: Dart
- **Bluetooth**: flutter_blue_plus
- **State Management**: Provider
- **Permissions**: permission_handler
- **Platform**: Android, Web

## 📂 Project Structure

```
📦 GhostWaveBT
├── 🔧 setup_script.ps1          # Environment setup
├── 🏗️ build_script.ps1          # Build automation
├── 🧹 clean_script.ps1          # Cleanup utilities
├── 📱 lib/                      # Flutter source code
│   ├── main.dart                # App entry point
│   ├── providers/               # State management
│   ├── screens/                 # App screens
│   └── widgets/                 # Reusable components
├── 🤖 android/                  # Android configuration
├── 🎨 assets/                   # Images and resources
└── 📚 README.md                 # Documentation
```

## 🛠️ Development Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup_script.ps1` | Initial setup and dependency installation | Run once when setting up |
| `build_script.ps1` | Build APK/web app with versioning | `.\build_script.ps1 android` |
| `clean_script.ps1` | Remove all build artifacts and caches | Run when having build issues |

### 🔧 Troubleshooting

### Flutter not found
Run `.\setup_script.ps1` - it will guide you through Flutter installation.

### Build failures
1. Run `.\clean_script.ps1`
2. Run `.\setup_script.ps1`
3. Try building again with `.\build_script.ps1 android -Clean`

### Android build issues
1. Check `flutter doctor` output
2. Ensure Android SDK is installed
3. Accept Android licenses: `flutter doctor --android-licenses`

## 📦 Built Files

- **APK files**: `generated/bt_controller_vX.apk`
- **Web builds**: `generated/web_vX/`
- **Version tracking**: `generated/.version`

Versions are automatically incremented with each build (v1, v2, v3, etc.).

## 🎮 App Features

- **8-Direction Movement Control**: Forward, backward, left, right, and diagonal movements
- **Bluetooth Connectivity**: Connect to Bluetooth-enabled devices
- **Modern UI**: Dark theme with orange accent controls
- **Responsive Design**: Works on phones and tablets
- **Web Testing**: Test functionality in browser before building APK

## 🔗 Dependencies

- `flutter_blue_plus`: Bluetooth connectivity
- `permission_handler`: Android permissions
- `provider`: State management

## 📝 Version History

## 📦 Dependencies

```yaml
dependencies:
  flutter_blue_plus: ^1.33.9    # Bluetooth connectivity
  permission_handler: ^12.0.1   # Android permissions
  provider: ^6.1.2              # State management

dev_dependencies:
  flutter_lints: ^4.0.0         # Code linting
  flutter_launcher_icons: ^0.14.1  # App icons
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- flutter_blue_plus contributors for Bluetooth functionality
- Community contributors and testers

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/ghostwave-bt/issues) page
2. Run `.\clean_script.ps1` and try rebuilding
3. Ensure Flutter and Android SDK are properly installed
4. Create a new issue with detailed information

---

<div align="center">
Made with ❤️ using Flutter
</div>
