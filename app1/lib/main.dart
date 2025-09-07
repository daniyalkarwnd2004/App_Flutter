import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:telephony/telephony.dart';
import 'screens/sms_display_page.dart';
import 'screens/sms_display_report.dart';
import 'page/devicel_list_page.dart';
import 'device/add_device_page.dart';
import 'models/device.dart';

part 'main.g.dart';

int dataflag = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
  }

  Hive.registerAdapter(DeviceAdapter());
  await Hive.openBox<Device>('devices');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takin Electronic Vida',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  double _opacity = 0;
  double _scale = 0.8;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();

    initSmsListener();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1;
        _scale = 1;
      });
      _controller.forward();
    });
  }

void initSmsListener() async {
  bool? granted = await telephony.requestPhoneAndSmsPermissions;
  if (granted ?? false) {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        String sender = message.address ?? "";
        String body = message.body ?? "";

        String normalizeNumber(String number) {
          number = number.replaceAll(' ', '');
          if (number.startsWith('+98')) {
            number = '0' + number.substring(3);
          } else if (number.startsWith('0098')) {
            number = '0' + number.substring(4);
          }
          return number;
        }

        String normalizedSender = normalizeNumber(sender);
        final box = Hive.box<Device>('devices');

        // پیدا کردن همان Device مرتبط با شماره‌ی فرستنده
        Device? matchedDevice;
        for (final d in box.values) {
          if (normalizeNumber(d.phone) == normalizedSender) {
            matchedDevice = d;
            break;
          }
        }

        // فقط اگر شماره در دیتابیس ثبت شده باشد صفحه باز شود
        if (matchedDevice != null && mounted) {
          final Device device = matchedDevice; // non-nullable

          final isReportMsg = body.contains('Temp:') ||
              body.contains('Hum:') ||
              body.contains('Volt:') ||
              body.contains('Signal:') ||
              body.contains('FrontDoor:') ||
              body.contains('RearDoor:') ||
              body.contains('Smoke:') ||
              body.contains('Power:');

          if (isReportMsg) {
            final reportData = parseReportData(body);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportPage(
                  initialData: reportData,
                  device: device, // بدون خطا
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SmsDisplayPage(sender: sender, body: body),
              ),
            );
          }
        } else {
          // شماره ناشناس؛ می‌توان لاگ زد یا نادیده گرفت
          print("Error");
        }
      },
      listenInBackground: false,
    );
  }
}

  ReportData parseReportData(String message) {
    double temperature = 0;
    double humidity = 0;
    double voltage = 0;
    int signalStrength = 0;
    bool frontDoor = false;
    bool rearDoor = false;
    bool smokeDetected = false;
    bool powerOn = false; // اضافه شده

    final parts = message.split(';');

    dataflag = 25;

    for (var part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim().toLowerCase();
        final value = keyValue[1].trim();

        switch (key) {
          case 'temp':
            temperature = double.tryParse(value) ?? 0;
            break;
          case 'hum':
            humidity = double.tryParse(value) ?? 0;
            break;
          case 'volt':
            voltage = double.tryParse(value) ?? 0;
            break;
          case 'signal':
            signalStrength = int.tryParse(value) ?? 0;
            break;
          case 'frontdoor':
            frontDoor = value.toLowerCase() == 'open';
            break;
          case 'reardoor':
            rearDoor = value.toLowerCase() == 'open';
            break;
          case 'smoke':
            smokeDetected =
                value.toLowerCase() == 'yes' ||
                value.toLowerCase() == 'detected';
            break;
          case 'power': // اضافه شده
            powerOn = value.toLowerCase() == 'on';
            break;
        }
      }
    }

    return ReportData(
      temperature: temperature,
      humidity: humidity,
      voltage: voltage,
      signalStrength: signalStrength,
      frontDoor: frontDoor,
      rearDoor: rearDoor,
      smokeDetected: smokeDetected,
      powerOn: powerOn, // اضافه شده
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.07;
    final spacing = size.height * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 24, 1, 70),
        elevation: 0,
        title: Image.asset(
          'assets/icon/app_icon.png', // مسیر لوگو توی پروژه‌ات
          height: 50,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.03),
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 800),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: _scale),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Takin Electronic Vida',
                      style: TextStyle(
                        fontSize: size.width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(193, 25, 2, 175),
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.deepPurple.shade200,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing * 2),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 28),
                      label: const Text('Add Device'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 24, 1, 70),
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: Colors.deepPurple.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(double.infinity, buttonHeight),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        var box = Hive.box<Device>('devices');
                        if (box.length >= 30) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You can only add up to 30 devices',
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddDevicePage(),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: spacing),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.list, size: 28),
                      label: const Text('My Devices List'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 24, 1, 70),
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: Colors.deepPurple.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(double.infinity, buttonHeight),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeviceListPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
