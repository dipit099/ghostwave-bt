import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/controller_provider.dart';

class DirectionIndicatorWidget extends StatelessWidget {
  const DirectionIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ControllerProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double size = (constraints.maxWidth * 1.0).clamp(120.0, 200.0);
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF404040),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF404040).withValues(alpha: 0.1),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center car icon with enhanced size
              const Icon(
                Icons.drive_eta,
                color: Color(0xFF888888),
                size: 32,
              ),
              
              // Visual indicators for all currently active moves
              ..._buildActiveMovesIndicators(provider),
              
              // 8 directional arrows positioned around the center
              
              // Clean corner indicators similar to inspiration image
              // Top-Left indicator
              Positioned(
                top: 16,
                left: 16,
                child: _buildCornerIndicator(
                  _isDirectionActive(provider, ControlCommand.forwardLeft) ||
                  (_isDirectionActive(provider, ControlCommand.forward) && 
                   _isDirectionActive(provider, ControlCommand.left)),
                ),
              ),
              
              // Top-Right indicator
              Positioned(
                top: 16,
                right: 16,
                child: _buildCornerIndicator(
                  _isDirectionActive(provider, ControlCommand.forwardRight) ||
                  (_isDirectionActive(provider, ControlCommand.forward) && 
                   _isDirectionActive(provider, ControlCommand.right)),
                ),
              ),
              
              // Bottom-Left indicator
              Positioned(
                bottom: 16,
                left: 16,
                child: _buildCornerIndicator(
                  _isDirectionActive(provider, ControlCommand.backwardLeft) ||
                  (_isDirectionActive(provider, ControlCommand.backward) && 
                   _isDirectionActive(provider, ControlCommand.left)),
                ),
              ),
              
              // Bottom-Right indicator
              Positioned(
                bottom: 16,
                right: 16,
                child: _buildCornerIndicator(
                  _isDirectionActive(provider, ControlCommand.backwardRight) ||
                  (_isDirectionActive(provider, ControlCommand.backward) && 
                   _isDirectionActive(provider, ControlCommand.right)),
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


  List<Widget> _buildActiveMovesIndicators(ControllerProvider provider) {
    List<Widget> indicators = [];
    
    // Check all active commands and build indicators for each
    final activeCommands = provider.activeCommands;
    
    for (final command in activeCommands) {
      Widget? indicator = _buildMoveIndicator(command.command);
      if (indicator != null) {
        indicators.add(indicator);
      }
    }
    
    return indicators;
  }

  Widget? _buildMoveIndicator(String command) {
    switch (command) {
      case 'F':
        return Positioned(
          top: 6,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.keyboard_arrow_up,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      case 'B':
        return Positioned(
          bottom: 6,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      case 'L':
        return Positioned(
          left: 6,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      case 'R':
        return Positioned(
          right: 6,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.keyboard_arrow_right,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      default:
        return null;
    }
  }

  Widget _buildCornerIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2196F3) : const Color(0xFF444444),
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }

  bool _isDirectionActive(ControllerProvider provider, ControlCommand command) {
    return provider.isButtonPressed(command);
  }
}