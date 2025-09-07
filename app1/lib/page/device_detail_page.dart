import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:app1/screens/sms_display_report.dart';
import 'package:app1/models/device.dart';

class DeviceDetailPage extends StatefulWidget {
  final Device device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final Telephony telephony = Telephony.instance;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late Device device;

  // در DeviceDetailPage

  @override
  void initState() {
    super.initState();
    device = widget.device;
    _nameController = TextEditingController(text: device.name);
    _phoneController = TextEditingController(text: device.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> sendSms(String message) async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;

    if (permissionsGranted ?? false) {
      await telephony.sendSms(to: device.phone, message: message);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message sent.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to send SMS is not granted.')),
      );
    }
  }

  void _showMessage(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action for device: ${device.name}')),
    );
  }

  Future<void> _editDeviceDialog() async {
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Device'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter device name'
                    : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
                    return 'Phone must start with 09 and be 11 digits';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                device.name = _nameController.text.trim();
                device.phone = _phoneController.text.trim();
                await device.save();
                setState(() {});
                Navigator.pop(context);
                _showMessage('Device updated');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await device.delete();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Device deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final spacing = size.height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Details'),
        backgroundColor: const Color.fromARGB(255, 24, 1, 70),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container کوچکتر برای اسم دستگاه
            Container(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.015,
                horizontal: size.width * 0.05,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 24, 1, 70),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Device: ${device.name}',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: spacing * 2),

            // Turn OFF Button (unchanged)
            ElevatedButton.icon(
              onPressed: () {
                _showMessage('Turned OFF');
                sendSms('Turn OFF command sent to device: ${device.name}');
              },
              icon: const Icon(
                Icons.power_settings_new,
                color: Colors.redAccent,
              ),
              label: const Text(
                'Turn OFF',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, buttonHeight),
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.redAccent,
                shadowColor: Colors.redAccent.withOpacity(0.3),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: spacing),

            // Turn ON Button (unchanged)
            ElevatedButton.icon(
              onPressed: () {
                _showMessage('Turned ON');
                sendSms('Turn ON command sent to device: ${device.name}');
              },
              icon: const Icon(Icons.power, color: Colors.green),
              label: const Text(
                'Turn ON',
                style: TextStyle(color: Colors.green),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, buttonHeight),
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
                shadowColor: Colors.green.withOpacity(0.3),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: spacing),

            // Restart Button (unchanged)
            ElevatedButton.icon(
              onPressed: () {
                _showMessage('Turned RESTART');
                sendSms('Turn RESTART command sent to device: ${device.name}');
              },
              icon: const Icon(Icons.refresh, color: Colors.orange),
              label: const Text(
                'Restart',
                style: TextStyle(color: Colors.orange),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, buttonHeight),
                backgroundColor: Colors.orange.shade50,
                foregroundColor: Colors.orange.shade700,
                shadowColor: Colors.orange.withOpacity(0.3),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: spacing),

            // Check Status Button (unchanged)
            ElevatedButton.icon(
              onPressed: () async {
                _showMessage('Check the status');
                sendSms('Check the status sent to device: ${device.name}');
              },
              icon: const Icon(Icons.assignment, color: Colors.blue),
              label: const Text(
                'Check the status',
                style: TextStyle(color: Colors.blue),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, buttonHeight),
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                shadowColor: Colors.blue.withOpacity(0.3),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            SizedBox(height: spacing),

            // Edit Device Button با رنگ آبی کمرنگ و دور رنگ اصلی
            ElevatedButton.icon(
              onPressed: _editDeviceDialog,
              icon: const Icon(
                Icons.edit,
                color: Color.fromARGB(255, 24, 1, 70),
              ),
              label: const Text(
                'Edit Device',
                style: TextStyle(color: Color.fromARGB(255, 24, 1, 70)),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, buttonHeight),
                backgroundColor: Colors.blue.shade100,
                shadowColor: Colors.deepPurple.withOpacity(0.2),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: const Color.fromARGB(255, 24, 1, 70),
                    width: 2,
                  ),
                ),
              ),
            ),

            SizedBox(height: spacing),

            // Delete Device Button با رنگ آبی پررنگ، متن سفید و دور کادر رنگ اصلی
            ElevatedButton.icon(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'Delete Device',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, buttonHeight),
                backgroundColor: Colors.blue.shade900,
                shadowColor: Colors.blue.shade900.withOpacity(0.7),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: const Color.fromARGB(255, 24, 1, 70),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
