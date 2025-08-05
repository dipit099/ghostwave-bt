import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/controller_provider.dart';
import '../widgets/control_grid_widget.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus for keyboard input on desktop platforms
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event, ControllerProvider controllerProvider) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        // Forward
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          controllerProvider.pressButton(ControlCommand.forward);
          break;
        // Backward
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.keyS:
          controllerProvider.pressButton(ControlCommand.backward);
          break;
        // Left
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyA:
          controllerProvider.pressButton(ControlCommand.left);
          break;
        // Right
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.keyD:
          controllerProvider.pressButton(ControlCommand.right);
          break;
        // Diagonal movements
        case LogicalKeyboardKey.keyQ:
          controllerProvider.pressButton(ControlCommand.forwardLeft);
          break;
        case LogicalKeyboardKey.keyE:
          controllerProvider.pressButton(ControlCommand.forwardRight);
          break;
        case LogicalKeyboardKey.keyZ:
          controllerProvider.pressButton(ControlCommand.backwardLeft);
          break;
        case LogicalKeyboardKey.keyX:
          controllerProvider.pressButton(ControlCommand.backwardRight);
          break;
        // Stop
        case LogicalKeyboardKey.space:
          controllerProvider.pressButton(ControlCommand.stop);
          break;
        // Calibrate
        case LogicalKeyboardKey.keyC:
          controllerProvider.pressButton(ControlCommand.calibrate);
          break;
        // Reset angle
        case LogicalKeyboardKey.keyR:
          controllerProvider.pressButton(ControlCommand.resetAngle);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ControllerProvider>(
      builder: (context, controllerProvider, child) {
        Widget content = Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(
            child: Column(
              children: [
                // ULTRA-COMPACT HEADER - Only 24px high
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/GhostWaveBT.png',
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'GhostWaveBT',
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 12, 
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                      Consumer<BluetoothProvider>(
                        builder: (context, bluetoothProvider, child) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.bluetooth,
                              color: bluetoothProvider.connectionStatus == ConnectionStatus.connected 
                                  ? Colors.green 
                                  : Colors.red,
                              size: 16,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // CONTROLLER AREA - Uses ALL remaining space
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: const ControlGridWidget(),
                  ),
                ),
              ],
            ),
          ),
        );

        // Wrap with keyboard listener only on desktop platforms
        if (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux) {
          return KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (event) => _handleKeyEvent(event, controllerProvider),
            child: content,
          );
        }

        return content;
      },
    );
  }
}