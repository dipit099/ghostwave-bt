import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 4,
        centerTitle: true,
        actions: [
          Consumer<BluetoothProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isDiscovering ? Icons.stop : Icons.refresh,
                  color: provider.isDiscovering ? Colors.orange : Colors.blue,
                ),
                onPressed: () {
                  if (provider.isDiscovering) {
                    provider.stopDiscovery();
                  } else {
                    provider.startDiscovery();
                  }
                },
                tooltip:
                    provider.isDiscovering ? 'Stop Scan' : 'Scan for Devices',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Connection Status
              Consumer<BluetoothProvider>(
                builder: (context, provider, child) {
                  return Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bluetooth,
                                color: provider.connectionStatus == ConnectionStatus.connected
                                    ? Colors.green
                                    : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.connectedDeviceName ?? 'Not Connected',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      _getStatusText(provider.connectionStatus),
                                      style: TextStyle(
                                        color: _getStatusColor(provider.connectionStatus),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (provider.errorMessage != null)
                                      Text(
                                        provider.errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (provider.connectionStatus == ConnectionStatus.connected)
                                ElevatedButton(
                                  onPressed: provider.disconnect,
                                  child: const Text('Disconnect'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Keyboard Shortcuts (show only on desktop platforms)
              if (defaultTargetPlatform == TargetPlatform.macOS ||
                  defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.linux)
                Card(
                  elevation: 8,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Keyboard Shortcuts',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildKeyboardShortcut('Forward', '↑ or W'),
                            _buildKeyboardShortcut('Backward', '↓ or S'),
                            _buildKeyboardShortcut('Left', '← or A'),
                            _buildKeyboardShortcut('Right', '→ or D'),
                            _buildKeyboardShortcut('Forward Left', 'Q'),
                            _buildKeyboardShortcut('Forward Right', 'E'),
                            _buildKeyboardShortcut('Backward Left', 'Z'),
                            _buildKeyboardShortcut('Backward Right', 'X'),
                            _buildKeyboardShortcut('Stop', 'Space'),
                            _buildKeyboardShortcut('Calibrate', 'C'),
                            _buildKeyboardShortcut('Reset Angle', 'R'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (defaultTargetPlatform == TargetPlatform.macOS ||
                  defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.linux)
                const SizedBox(height: 20),

              // Device List
              Expanded(
                child: Card(
                  elevation: 8,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Available Devices',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Consumer<BluetoothProvider>(
                          builder: (context, provider, child) {
                            if (provider.isDiscovering) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Scanning for devices...'),
                                  ],
                                ),
                              );
                            }

                            if (provider.availableDevices.isEmpty) {
                              return const Center(
                                child: Text('No devices found\nTap refresh to scan'),
                              );
                            }

                            return ListView.builder(
                              itemCount: provider.availableDevices.length,
                              itemBuilder: (context, index) {
                                final device = provider.availableDevices[index];
                                final deviceName = device.platformName.isNotEmpty 
                                    ? device.platformName 
                                    : device.remoteId.toString();
                                return ListTile(
                                  leading: const Icon(
                                    Icons.bluetooth,
                                    color: Colors.blue,
                                  ),
                                  title: Text(deviceName),
                                  subtitle: Text(device.remoteId.toString()),
                                  trailing: ElevatedButton(
                                    onPressed: provider.connectionStatus == ConnectionStatus.connecting
                                        ? null
                                        : () => provider.connectToDevice(device),
                                    child: Text(provider.connectionStatus == ConnectionStatus.connecting
                                        ? 'Connecting...'
                                        : 'Connect'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardShortcut(String action, String keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            action,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.error:
        return 'Connection Error';
    }
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.error:
        return Colors.red;
    }
  }
}