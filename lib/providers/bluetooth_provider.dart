import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class BluetoothProvider extends ChangeNotifier {
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  String? _connectedDeviceName;
  List<BluetoothDevice> _availableDevices = [];
  bool _isDiscovering = false;
  String? _errorMessage;
  
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  // Getters
  ConnectionStatus get connectionStatus => _connectionStatus;
  String? get connectedDeviceName => _connectedDeviceName;
  List<BluetoothDevice> get availableDevices => _availableDevices;
  bool get isDiscovering => _isDiscovering;
  String? get errorMessage => _errorMessage;

  Future<void> startDiscovery() async {
    try {
      _isDiscovering = true;
      _errorMessage = null;
      _availableDevices.clear();
      notifyListeners();
      
      // Check Bluetooth permissions
      if (!await _checkPermissions()) {
        _isDiscovering = false;
        _errorMessage = 'Bluetooth permissions not granted';
        notifyListeners();
        return;
      }
      
      // Check if Bluetooth is on
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        _isDiscovering = false;
        _errorMessage = 'Bluetooth is turned off';
        notifyListeners();
        return;
      }
      
      // Start scanning
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = result.device;
          final deviceName = device.platformName.isNotEmpty ? device.platformName : device.remoteId.toString();
          
          // Filter for Arduino/ESP32/HC-05 devices (common Bluetooth car controllers)
          if (deviceName.toLowerCase().contains('hc-') ||
              deviceName.toLowerCase().contains('esp32') ||
              deviceName.toLowerCase().contains('arduino') ||
              deviceName.toLowerCase().contains('car') ||
              deviceName.toLowerCase().contains('bt')) {
            
            if (!_availableDevices.any((d) => d.remoteId == device.remoteId)) {
              _availableDevices.add(device);
              notifyListeners();
            }
          }
        }
      });
      
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      
      // Auto-stop discovery after timeout
      Future.delayed(const Duration(seconds: 10), () {
        stopDiscovery();
      });
      
    } catch (e) {
      _isDiscovering = false;
      _errorMessage = 'Error starting discovery: $e';
      notifyListeners();
    }
  }

  void stopDiscovery() {
    _isDiscovering = false;
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _connectionStatus = ConnectionStatus.connecting;
      _errorMessage = null;
      notifyListeners();

      // Connect to device
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      _connectedDeviceName = device.platformName.isNotEmpty ? device.platformName : device.remoteId.toString();
      
      // Listen for connection state changes
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          _connectionStatus = ConnectionStatus.connected;
        } else {
          _connectionStatus = ConnectionStatus.disconnected;
          _connectedDevice = null;
          _connectedDeviceName = null;
          _writeCharacteristic = null;
        }
        notifyListeners();
      });
      
      // Discover services and find write characteristic
      await _discoverServices(device);
      
    } catch (e) {
      _connectionStatus = ConnectionStatus.error;
      _errorMessage = 'Connection failed: $e';
      _connectedDevice = null;
      _connectedDeviceName = null;
      notifyListeners();
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Look for a characteristic that can write (typical for UART/Serial)
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
            _connectionStatus = ConnectionStatus.connected;
            notifyListeners();
            return;
          }
        }
      }
      
      // If no write characteristic found, still mark as connected but warn
      _connectionStatus = ConnectionStatus.connected;
      _errorMessage = 'Connected but no write characteristic found';
      notifyListeners();
      
    } catch (e) {
      _errorMessage = 'Service discovery failed: $e';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      _connectionSubscription?.cancel();
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      _connectionStatus = ConnectionStatus.disconnected;
      _connectedDeviceName = null;
      _connectedDevice = null;
      _writeCharacteristic = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Disconnect failed: $e';
      notifyListeners();
    }
  }

  Future<void> sendCommand(String command) async {
    if (_connectionStatus == ConnectionStatus.connected && _writeCharacteristic != null) {
      try {
        List<int> bytes = utf8.encode(command);
        await _writeCharacteristic!.write(bytes, withoutResponse: true);
        print('Sent command: $command');
      } catch (e) {
        _errorMessage = 'Failed to send command: $e';
        print('Error sending command: $e');
        notifyListeners();
      }
    } else {
      print('Cannot send command - not connected or no write characteristic');
    }
  }

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    
    return statuses.values.every((status) => status.isGranted);
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}