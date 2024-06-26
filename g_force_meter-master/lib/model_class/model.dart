class GyroscopeData {
  final DateTime date;
  final List<double> value;

  GyroscopeData(this.date, this.value);

  DateTime get getDate => date;
  List<double> get getValue => value;
}
class AccelerometerData {
  final DateTime date;
  final List<double> value;

  AccelerometerData(this.date, this.value);

  DateTime get getDate => date;
  List<double> get getValue => value;
}
