import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_service.dart';
import 'home_screen.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> with SingleTickerProviderStateMixin {
  final BluetoothService _bluetoothService = BluetoothService();
  List<BluetoothDevice> _devices = [];
  bool _loading = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeFooter;

  @override
  void initState() {
    super.initState();
    _initialize();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeFooter = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _requestPermissions();
    await _setupBluetooth();
    _animationController.forward();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses.values.any((status) => status.isDenied || status.isPermanentlyDenied)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth and Location permissions are required')),
      );
    }
  }

  Future<void> _setupBluetooth() async {
    bool isEnabled = await _bluetoothService.initializeBluetooth();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable Bluetooth')),
      );
      return;
    }

    List<BluetoothDevice> devices = await _bluetoothService.getBondedDevices();
    setState(() {
      _devices = devices;
      _loading = false;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _loading = true);
    bool success = await _bluetoothService.connectToDevice(device);
    setState(() => _loading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(bluetoothService: _bluetoothService),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to ${device.name}')),
      );
    }
  }

  Widget _buildAnimatedDeviceTile(BluetoothDevice device, int index) {
    return SlideTransition(
      position: _slideAnimation,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () => _connectToDevice(device),
          splashColor: Colors.blueAccent.withOpacity(0.3),
          hoverColor: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(device.name ?? "Unknown"),
            subtitle: Text(device.address),
            trailing: const Icon(Icons.bluetooth, color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bluetooth Device'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _devices.isEmpty
                    ? const Center(child: Text('No paired devices found.'))
                    : ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) =>
                            _buildAnimatedDeviceTile(_devices[index], index),
                      ),
          ),
          FadeTransition(
            opacity: _fadeFooter,
            child: const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Designed and Developed By T Rohan Kini',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
