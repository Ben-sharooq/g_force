class SensorDetails {
  String? tripId;
  String? tripName;
  String? filePath;
 String? distance;
  String? date;

  SensorDetails({this.tripId, this.tripName, this.filePath, this.distance, this.date});

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'tripName': tripName,
      'filePath': filePath,
      'distance': distance,
      'date': date,
    };
  }

  // Extract a SensorDetails object from a Map object
  factory SensorDetails.fromMap(Map<String, dynamic> map) {
    return SensorDetails(
      tripId: map['tripId'],
      tripName: map['tripName'],
      filePath: map['filePath'],
      distance: map['distance'],
      date: map['date'],
    );
  }
}