import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class Device extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  bool isOn = false;


  Device({required this.name, required this.phone, this.isOn = false});
}


