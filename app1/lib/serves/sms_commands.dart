import 'package:app1/models/device.dart';

class SmsCommands {
  static String turnOn(Device device) =>
      "Turn ON command sent to device: ${device.name}";

  static String turnOff(Device device) =>
      "Turn OFF command sent to device: ${device.name}";

  static String restart(Device device) =>
      "Turn RESTART command sent to device: ${device.name}";

  static String generateReport(Device device) =>
      "Turn Generate Report command sent to device: ${device.name}";
}
