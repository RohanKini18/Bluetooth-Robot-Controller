import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  bool isConnected = false;

  /// Initialize Bluetooth and request permission
  Future<bool> initializeBluetooth() async {
    bool isEnabled = await _bluetooth.isEnabled ?? false;

    if (!isEnabled) {
      await _bluetooth.requestEnable();
      isEnabled = await _bluetooth.isEnabled ?? false;
    }

    return isEnabled;
  }

  /// Get list of paired Bluetooth devices
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await _bluetooth.getBondedDevices();
  }

  /// Connect to a specific Bluetooth device (HC-05)
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      isConnected = true;
      print('Connected to ${device.name}');
      return true;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  /// Disconnect the device
  void disconnect() {
    _connection?.dispose();
    _connection = null;
    isConnected = false;
    print('Disconnected');
  }

  /// Send a single-character command (e.g., 'F', 'B', 'L', 'R', 'S')
  Future<void> sendCommand(String command) async {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
      await _connection!.output.allSent;
    } else {
      print("Not connected to any device.");
    }
  }

  /// Listen to data received from Arduino (optional)
  void listenToData(void Function(String data) onDataReceived) {
    _connection?.input?.listen((Uint8List data) {
      String received = ascii.decode(data);
      onDataReceived(received);
    });
  }

  bool get connectionStatus => isConnected;
}
