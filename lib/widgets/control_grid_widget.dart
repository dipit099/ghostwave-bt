import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/controller_provider.dart';
import '../providers/bluetooth_provider.dart';
import 'control_button_widget.dart';
import 'direction_indicator_widget.dart';

class ControlGridWidget extends StatelessWidget {
  const ControlGridWidget({super.key});

  void _handleButtonPress(ControllerProvider controllerProvider, 
                         BluetoothProvider bluetoothProvider, 
                         ControlCommand command) {
    controllerProvider.pressButton(command);
    
    // Handle multitouch diagonal movements
    final activeCommands = controllerProvider.activeCommands;
    if (activeCommands.length == 2) {
      if (activeCommands.contains(ControlCommand.forward) && 
          activeCommands.contains(ControlCommand.left)) {
        bluetoothProvider.sendCommand('G'); // Forward Left
      } else if (activeCommands.contains(ControlCommand.forward) && 
                 activeCommands.contains(ControlCommand.right)) {
        bluetoothProvider.sendCommand('I'); // Forward Right
      } else if (activeCommands.contains(ControlCommand.backward) && 
                 activeCommands.contains(ControlCommand.left)) {
        bluetoothProvider.sendCommand('H'); // Backward Left
      } else if (activeCommands.contains(ControlCommand.backward) && 
                 activeCommands.contains(ControlCommand.right)) {
        bluetoothProvider.sendCommand('J'); // Backward Right
      }
    } else if (activeCommands.length == 1) {
      // Single command
      switch (command) {
        case ControlCommand.forward:
          bluetoothProvider.sendCommand('F');
          break;
        case ControlCommand.backward:
          bluetoothProvider.sendCommand('B');
          break;
        case ControlCommand.left:
          bluetoothProvider.sendCommand('L');
          break;
        case ControlCommand.right:
          bluetoothProvider.sendCommand('R');
          break;
        default:
          break;
      }
    }
  }

  void _handleButtonRelease(BluetoothProvider bluetoothProvider) {
    bluetoothProvider.sendCommand('S'); // Stop on release
  }

  void _handleSpecialButton(ControllerProvider controllerProvider,
                           BluetoothProvider bluetoothProvider,
                           ControlCommand command,
                           String btCommand) {
    controllerProvider.pressButton(command);
    bluetoothProvider.sendCommand(btCommand);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ControllerProvider, BluetoothProvider>(
      builder: (context, controllerProvider, bluetoothProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Use ALL available space
            double availableWidth = constraints.maxWidth;
            
            // Enhanced button sizes for better usability
            double specialButtonSize = (availableWidth / 10).clamp(45.0, 65.0);
            double moveButtonSize = (availableWidth / 6).clamp(70.0, 100.0);
            
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E1E1E),
                    Color(0xFF1A1A1A),
                    Color(0xFF161616),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF2A2A2A),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  // ULTRA-COMPACT special buttons row
                  SizedBox(
                    height: specialButtonSize + 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ControlButtonWidget(
                          command: ControlCommand.calibrate,
                          size: specialButtonSize,
                          onPressed: () => _handleSpecialButton(
                            controllerProvider, 
                            bluetoothProvider, 
                            ControlCommand.calibrate, 
                            'C'
                          ),
                        ),
                        const SizedBox(width: 8),
                        ControlButtonWidget(
                          command: ControlCommand.stop,
                          size: specialButtonSize,
                          onPressed: () => _handleSpecialButton(
                            controllerProvider, 
                            bluetoothProvider, 
                            ControlCommand.stop, 
                            'S'
                          ),
                        ),
                        const SizedBox(width: 8),
                        ControlButtonWidget(
                          command: ControlCommand.resetAngle,
                          size: specialButtonSize,
                          onPressed: () => _handleSpecialButton(
                            controllerProvider, 
                            bluetoothProvider, 
                            ControlCommand.resetAngle, 
                            'Z'
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tiny gap
                  const SizedBox(height: 2),
                  
                  // ULTRA-COMPACT movement controls
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left side: F/B buttons (vertical)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ControlButtonWidget(
                              command: ControlCommand.forward,
                              size: moveButtonSize,
                              onPressed: () => _handleButtonPress(
                                controllerProvider, 
                                bluetoothProvider, 
                                ControlCommand.forward
                              ),
                              onReleased: () => _handleButtonRelease(bluetoothProvider),
                            ),
                            const SizedBox(height: 8),
                            ControlButtonWidget(
                              command: ControlCommand.backward,
                              size: moveButtonSize,
                              onPressed: () => _handleButtonPress(
                                controllerProvider, 
                                bluetoothProvider, 
                                ControlCommand.backward
                              ),
                              onReleased: () => _handleButtonRelease(bluetoothProvider),
                            ),
                          ],
                        ),
                        
                        // Center: Enhanced direction indicator
                        SizedBox(
                          width: moveButtonSize * 1.2,
                          height: moveButtonSize * 1.2,
                          child: const DirectionIndicatorWidget(),
                        ),
                        
                        // Right side: L/R buttons (horizontal)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                ControlButtonWidget(
                                  command: ControlCommand.left,
                                  size: moveButtonSize,
                                  onPressed: () => _handleButtonPress(
                                    controllerProvider, 
                                    bluetoothProvider, 
                                    ControlCommand.left
                                  ),
                                  onReleased: () => _handleButtonRelease(bluetoothProvider),
                                ),
                                const SizedBox(width: 8),
                                ControlButtonWidget(
                                  command: ControlCommand.right,
                                  size: moveButtonSize,
                                  onPressed: () => _handleButtonPress(
                                    controllerProvider, 
                                    bluetoothProvider, 
                                    ControlCommand.right
                                  ),
                                  onReleased: () => _handleButtonRelease(bluetoothProvider),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}