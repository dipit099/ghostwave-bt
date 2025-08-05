import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ControlCommand {
  forward('F', 'Forward'),
  backward('B', 'Backward'),
  left('L', 'Left'),
  right('R', 'Right'),
  forwardLeft('G', 'Forward Left'),
  backwardLeft('H', 'Backward Left'),
  forwardRight('I', 'Forward Right'),
  backwardRight('J', 'Backward Right'),
  stop('S', 'Stop'),
  calibrate('C', 'Calibrate'),
  resetAngle('Z', 'Reset Angle');

  const ControlCommand(this.command, this.description);
  final String command;
  final String description;
}

class ControllerProvider extends ChangeNotifier {
  String? _lastCommand;
  DateTime? _lastCommandTime;
  final Map<ControlCommand, bool> _buttonStates = {};

  // Getters
  String? get lastCommand => _lastCommand;
  DateTime? get lastCommandTime => _lastCommandTime;
  
  List<ControlCommand> get activeCommands {
    return _buttonStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  bool isButtonPressed(ControlCommand command) {
    return _buttonStates[command] ?? false;
  }

  ControllerProvider() {
    // Initialize button states
    for (final command in ControlCommand.values) {
      _buttonStates[command] = false;
    }
  }

  void pressButton(ControlCommand command) {
    // Set button as pressed
    _buttonStates[command] = true;

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Update last command
    _lastCommand = command.command;
    _lastCommandTime = DateTime.now();

    notifyListeners();
  }

  void releaseButton(ControlCommand command) {
    _buttonStates[command] = false;
    notifyListeners();
  }

  void releaseAllButtons() {
    for (final command in ControlCommand.values) {
      _buttonStates[command] = false;
    }
    notifyListeners();
  }

  // Get button color based on state and command type
  Color getButtonColor(ControlCommand command) {
    if (isButtonPressed(command)) {
      return _getPressedColor(command);
    }
    return _getDefaultColor(command);
  }

  Color _getDefaultColor(ControlCommand command) {
    // Special buttons (C, S, Z) are orange, movement buttons are grey
    if (command == ControlCommand.calibrate || 
        command == ControlCommand.stop || 
        command == ControlCommand.resetAngle) {
      return const Color(0xFFFF8C00); // Orange for special buttons
    }
    return const Color(0xFF424242); // Dark grey for movement buttons
  }

  Color _getPressedColor(ControlCommand command) {
    // Special buttons turn white when pressed, movement buttons turn blue
    if (command == ControlCommand.calibrate || 
        command == ControlCommand.stop || 
        command == ControlCommand.resetAngle) {
      return const Color(0xFFFFFFFF); // White when pressed for special buttons
    }
    return const Color(0xFF2196F3); // Bright blue when pressed for movement buttons
  }

  // Get display symbol for command
  String getCommandSymbol(ControlCommand command) {
    switch (command) {
      case ControlCommand.forward:
        return '↑';
      case ControlCommand.backward:
        return '↓';
      case ControlCommand.left:
        return '←';
      case ControlCommand.right:
        return '→';
      case ControlCommand.forwardLeft:
        return '↖';
      case ControlCommand.backwardLeft:
        return '↙';
      case ControlCommand.forwardRight:
        return '↗';
      case ControlCommand.backwardRight:
        return '↘';
      case ControlCommand.stop:
        return 'S';
      case ControlCommand.calibrate:
        return 'C';
      case ControlCommand.resetAngle:
        return 'Z';
    }
  }
}