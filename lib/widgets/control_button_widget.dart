import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/controller_provider.dart';

class ControlButtonWidget extends StatelessWidget {
  final ControlCommand command;
  final double size;
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;

  const ControlButtonWidget({
    super.key,
    required this.command,
    this.size = 60,
    this.onPressed,
    this.onReleased,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ControllerProvider>(
      builder: (context, provider, child) {
        final isPressed = provider.isButtonPressed(command);
        final color = provider.getButtonColor(command);

        return GestureDetector(
          onTapDown: (_) {
            onPressed?.call();
          },
          onTapUp: (_) {
            provider.releaseButton(command);
            onReleased?.call();
          },
          onTapCancel: () {
            provider.releaseButton(command);
            onReleased?.call();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color,
              border: Border.all(
                color: isPressed 
                    ? Colors.transparent 
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: isPressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.05),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                provider.getCommandSymbol(command),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getIconColor(color),
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Color _getIconColor(Color backgroundColor) {
    // Return contrasting color for icon and text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}