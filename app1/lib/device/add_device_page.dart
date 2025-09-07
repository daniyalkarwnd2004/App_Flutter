import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app1/models/device.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});
  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter phone number';
    if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
      return 'Phone number must start with 09 and be exactly 11 digits';
    }
    return null;
  }

  Future<void> _saveDevice() async {
    var box = Hive.box<Device>('devices');
    if (box.length >= 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only have up to 30 devices')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final newDevice = Device(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      await box.add(newDevice);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device added successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final spacing = size.height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device'),
        backgroundColor: const Color.fromRGBO(24, 1, 70, 1),
        foregroundColor:Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Device Name',
                  labelStyle: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.045,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurple.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.deepPurple.shade600,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter device name'
                    : null,
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: Colors.deepPurple.shade900,
                ),
              ),
              SizedBox(height: spacing),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.045,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurple.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.deepPurple.shade600,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  counterText: '',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                validator: _validatePhone,
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: Colors.deepPurple.shade900,
                ),
              ),
              SizedBox(height: spacing * 2),
              ElevatedButton(
                onPressed: _saveDevice,
                child: const Text('Save Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 24, 1, 70),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.deepPurple.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(double.infinity, size.height * 0.07),
                  textStyle: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
