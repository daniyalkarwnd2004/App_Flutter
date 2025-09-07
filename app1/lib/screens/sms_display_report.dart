import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app1/serves/sms_service.dart';
import 'package:app1/serves/sms_commands.dart';
import 'package:app1/models/device.dart';

Future<void> saveReportAsPdfToDownloads(ReportData reportData) async {
  final pdf = pw.Document();
  final now = DateTime.now();
  final formattedDateTime =
      "${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}"
      "_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Device Report",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Generated on: $formattedDateTime",
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 20),

            buildReportRow("Temperature", "${reportData.temperature} °C"),
            buildReportRow("Humidity", "${reportData.humidity} %"),
            buildReportRow("Voltage", "${reportData.voltage} V"),
            buildReportRow("Signal Strength", "${reportData.signalStrength}"),
            buildReportRow(
              "Front Door",
              "${reportData.frontDoor ? 'Open' : 'Closed'}",
            ),
            buildReportRow(
              "Rear Door",
              "${reportData.rearDoor ? 'Open' : 'Closed'}",
            ),
            buildReportRow(
              "Smoke Detected",
              "${reportData.smokeDetected ? 'Yes' : 'No'}",
            ),
            buildReportRow(
              "Power Status",
              "${reportData.powerOn ? 'On' : 'Off'}",
            ),
          ],
        );
      },
    ),
  );

  try {
    Directory saveDir;

    if (Platform.isAndroid) {
      saveDir = Directory('/storage/emulated/0/Download');

      // Check if downloads folder exists
      if (!await saveDir.exists()) {
        print("❌ Cannot access Downloads folder. Saving PDF is not possible.");
        return;
      }
    } else {
      saveDir = await getApplicationDocumentsDirectory();
    }

    final fileName = "report_$formattedDateTime.pdf";
    final file = File('${saveDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    print("📄 PDF saved at: ${file.path}");
  } catch (e) {
    print("❌ Saving PDF on your device is not possible. Error: $e");
  }
}

/// Helper widget to build a row with a line under the text
pw.Widget buildReportRow(String title, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("$title: $value", style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 2),
        pw.Divider(thickness: 0.5, color: PdfColors.grey),
      ],
    ),
  );
}




class ReportData {
  final double temperature;
  final double humidity;
  final double voltage;
  final int signalStrength;
  final bool frontDoor;
  final bool rearDoor;
  final bool smokeDetected;
  final bool powerOn; // اضافه شده

  ReportData({
    required this.temperature,
    required this.humidity,
    required this.voltage,
    required this.signalStrength,
    required this.frontDoor,
    required this.rearDoor,
    required this.smokeDetected,
    required this.powerOn, // اضافه شده
  });
}

class ReportPage extends StatefulWidget {
  final ReportData? initialData;
  final Device device;   // 👈 اضافه شد

  const ReportPage({
    super.key,
    this.initialData,
    required this.device,   // 👈 اضافه شد
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}


class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  late ReportData reportData;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    reportData =
        widget.initialData ??
        ReportData(
          temperature: 0,
          humidity: 0,
          voltage: 0,
          signalStrength: 0,
          frontDoor: false,
          rearDoor: false,
          smokeDetected: false,
          powerOn: false,
        );

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.red.shade300,
      end: Colors.red.shade900,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isNormal(String label) {
    switch (label) {
      case 'Temperature':
        return reportData.temperature <= 30;
      case 'Humidity':
        return reportData.humidity <= 70;
      case 'Voltage':
        return reportData.voltage <= 12;
      case 'Signal Strength':
        return reportData.signalStrength >= 3;
      default:
        return true;
    }
  }

  Widget _reportItem(
    IconData icon,
    String label,
    String value,
    double iconSize,
  ) {
    bool normal = isNormal(label);

    Widget textWidget = Text(
      '$label: $value',
      style: TextStyle(
        fontSize: 14, // کاهش اندازه فونت
        color: normal ? Colors.black : Colors.red,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    if (!normal) {
      textWidget = AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _colorAnimation.value,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize * 0.7,
          color: Colors.blueAccent,
        ), // کوچکتر کردن آیکون
        SizedBox(height: 6),
        textWidget,
        SizedBox(height: 6),
        Divider(color: Colors.grey[400], thickness: 1),
      ],
    );
  }

  Widget _statusItem(
    IconData icon,
    String label,
    bool status,
    double iconSize,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize * 0.7,
          color: status ? Colors.green : Colors.red,
        ),
        SizedBox(height: 6),
        Text(
          '$label: ${status ? "On" : "Off"}',
          style: TextStyle(
            fontSize: 14,
            color: status ? Colors.green : Colors.red,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6),
        Divider(color: Colors.grey[400], thickness: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.12; //
    final spacing = size.height * 0.035;

    Widget headerImage = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: size.height * 0.42,
        width: double.infinity,
        child: Image.asset(
          reportData.frontDoor
              ? 'assets/icon/rack_open.png'
              : 'assets/icon/rack_close.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );

    List<Widget> items = [
      _reportItem(
        Icons.thermostat,
        'Temperature',
        '${reportData.temperature.toStringAsFixed(1)} °C',
        iconSize,
      ),
      _reportItem(
        Icons.water_drop,
        'Humidity',
        '${reportData.humidity.toStringAsFixed(1)} %',
        iconSize,
      ),
      _reportItem(
        Icons.bolt,
        'Voltage',
        '${reportData.voltage.toStringAsFixed(1)} V',
        iconSize,
      ),
      _reportItem(
        Icons.signal_cellular_alt,
        'Signal Strength',
        '${reportData.signalStrength}',
        iconSize,
      ),
      _statusItem(
        Icons.door_front_door,
        'Front Door',
        reportData.frontDoor,
        iconSize,
      ),
      _statusItem(
        Icons.door_back_door,
        'Rear Door',
        reportData.rearDoor,
        iconSize,
      ),
      _statusItem(
        Icons.local_fire_department,
        'Smoke Detected',
        reportData.smokeDetected,
        iconSize,
      ),
      _statusItem(
        Icons.power_settings_new,
        'Power Status',
        reportData.powerOn,
        iconSize,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Report',
          style: TextStyle(color: Colors.white), // رنگ متن سفید
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 24, 1, 70), // رنگ پس‌زمینه
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // رنگ آیکون‌ها (مثل back)
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.06),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            headerImage,
            SizedBox(height: spacing),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                return items[index];
              },
            ),
            SizedBox(height: spacing),
            ElevatedButton(
              onPressed: () {
                SmsService.sendSmsToDevice(
                context: context,
                device: widget.device,
                message: SmsCommands.generateReport(widget.device),
              );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(
                  255,
                  51,
                  5,
                  92,
                ), // رنگ دلنشین
                foregroundColor: Colors.white, // رنگ متن
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // گوشه‌های گرد
                ),
                elevation: 5, // سایه ملایم
              ),
              child: const Text(
                "Reset and Update",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15), // فاصله بین دکمه‌ها
            ElevatedButton(
              onPressed: () async {
                await saveReportAsPdfToDownloads(reportData);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("PDF saved successfully in Downloads!"),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 73, 12, 126),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                "Save as PDF",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
