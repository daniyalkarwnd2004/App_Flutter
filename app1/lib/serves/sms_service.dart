import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:app1/models/device.dart';

class SmsService {
  static final Telephony _telephony = Telephony.instance;

  /// ارسال پیامک به یک Device
  static Future<void> sendSmsToDevice({
    required BuildContext context,
    required Device device,
    required String message,
  }) async {
    bool? permissionsGranted = await _telephony.requestSmsPermissions;

    if (permissionsGranted ?? false) {
      await _telephony.sendSms(to: device.phone, message: message);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message sent to ${device.name}')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied to send SMS.')),
        );
      }
    }
  }
}
