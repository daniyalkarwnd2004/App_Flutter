import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app1/page/device_detail_page.dart';
import 'package:app1/models/device.dart';


class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});
  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> with SingleTickerProviderStateMixin {
  late Box<Device> devicesBox;
  late AnimationController _controller;
  late Animation<double> _fadeInTotalDevices;

  @override
  void initState() {
    super.initState();
    devicesBox = Hive.box<Device>('devices');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeInTotalDevices = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color headerColor = const Color.fromARGB(255, 24, 1, 70);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        title: const Text('My Devices List'),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: devicesBox.listenable(),
        builder: (context, Box<Device> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No devices found',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.015,
                  ),
                  child: FadeTransition(
                    opacity: _fadeInTotalDevices,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                      decoration: BoxDecoration(
                        color: headerColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: headerColor.withOpacity(0.6),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        'Total Devices: ${box.length}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(size.width * 0.04),
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final device = box.getAt(index)!;
                      final animation = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(
                            (index / box.length),
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        ),
                      );

                      return SlideTransition(
                        position: animation,
                        child: FadeTransition(
                          opacity: _controller,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: size.height * 0.008),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              leading: Container(
                                decoration: BoxDecoration(
                                  color: headerColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.devices,
                                  color: headerColor,
                                  size: size.width * 0.07,
                                ),
                              ),
                              title: Text(
                                device.name,
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple.shade900,
                                ),
                              ),
                              subtitle: Text(
                                device.phone,
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.grey[700],
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.deepPurple),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DeviceDetailPage(device: device),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
