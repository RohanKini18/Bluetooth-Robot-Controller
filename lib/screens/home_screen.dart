import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import 'bluetooth_screen.dart';

class HomeScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const HomeScreen({Key? key, required this.bluetoothService}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut);
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _sendCommand(String cmd, {bool autoStop = true}) {
    widget.bluetoothService.sendCommand(cmd);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent command: $cmd'),
        duration: const Duration(milliseconds: 100),
      ),
    );

    if (autoStop && ['F', 'B', 'L', 'R'].contains(cmd)) {
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.bluetoothService.sendCommand('S');
      });
    }
  }

  void _stopCommand() {
    widget.bluetoothService.sendCommand('S');
  }

  Widget _buildAnimatedButton(IconData icon, String label, String command) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.reverse(),
        onTapUp: (_) => _scaleController.forward(),
        onTapCancel: () => _scaleController.forward(),
        onTap: () => _sendCommand(command, autoStop: true),
        onLongPress: () => _sendCommand(command, autoStop: false),
        onLongPressUp: _stopCommand,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: Icon(icon, size: 28),
            label: Text(label, style: const TextStyle(fontSize: 18)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
                  if (states.contains(MaterialState.hovered)) return Colors.blue.shade700;
                  return Colors.blueAccent;
                },
              ),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              elevation: MaterialStateProperty.resolveWith<double>(
                (states) => states.contains(MaterialState.pressed) ? 2 : 6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _disconnectAndNavigateBack() {
    widget.bluetoothService.disconnect();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BluetoothScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot Controller'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedButton(Icons.arrow_upward, 'Forward', 'F'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedButton(Icons.arrow_back, 'Left', 'L'),
                    const SizedBox(width: 32),
                    _buildAnimatedButton(Icons.arrow_forward, 'Right', 'R'),
                  ],
                ),
                const SizedBox(height: 24),
                _buildAnimatedButton(Icons.arrow_downward, 'Backward', 'B'),
                const SizedBox(height: 36),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    onPressed: _disconnectAndNavigateBack,
                    icon: const Icon(Icons.bluetooth_disabled),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
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
          ],
        ),
      ),
    );
  }
}
