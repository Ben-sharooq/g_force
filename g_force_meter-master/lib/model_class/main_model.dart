import 'dart:convert';

List<SensorData> emptyFromJson(String str) =>
    List<SensorData>.from(json.decode(str).map((x) => SensorData.fromJson(x)));

String emptyToJson(List<SensorData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SensorData {
  double? accelerometerZ;
  double? accelerometerX;
  double? gyroscopeX;
  double? gyroscopeZ;
  double? accelerometerY;
  double? speed;
  int? id;
  double? gyroscopeY;
  String? reportDateTime;
  double? distance;

  SensorData(
      {this.accelerometerZ,
      this.accelerometerX,
      this.gyroscopeX,
      this.gyroscopeZ,
      this.accelerometerY,
      this.speed,
      this.id,
      this.gyroscopeY,
      this.reportDateTime,
      this.distance});

  factory SensorData.fromJson(Map<String, dynamic> json) => SensorData(
        id: json["id"],
        accelerometerX: json["accelerometer_x"],
        accelerometerY: json["accelerometer_y"],
        accelerometerZ: json["accelerometer_z"],
        gyroscopeX: json["gyroscope_x"],
        gyroscopeY: json["gyroscope_y"],
        gyroscopeZ: json["gyroscope_z"],
        speed: json["speed"],
        distance: json["distance"],
        reportDateTime: json["report_date_time"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "accelerometer_x": accelerometerX,
        "accelerometer_y": accelerometerY,
        "accelerometer_z": accelerometerZ,
        "gyroscope_x": gyroscopeX,
        "gyroscope_y": gyroscopeY,
        "gyroscope_z": gyroscopeZ,
        "speed": speed,
        "distance": distance,
        "report_date_time": reportDateTime,
      };
}

class SpeedAndDistance {
  final double speed;
  final double totalDistance;

  SpeedAndDistance(this.speed, this.totalDistance);
}
