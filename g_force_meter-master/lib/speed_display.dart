// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
//
// class SpeedCalculator extends StatefulWidget {
//   @override
//   _SpeedCalculatorState createState() => _SpeedCalculatorState();
// }
//
// class _SpeedCalculatorState extends State<SpeedCalculator> {
//   AccelerometerEvent? _accelerometerValues;
//   double _speed = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     // Subscribe to accelerometer updates
//     accelerometerEventStream().listen((AccelerometerEvent event) {
//       setState(() {
//         _accelerometerValues = event;
//         _calculateSpeed();
//       });
//     });
//   }
//
//   void _calculateSpeed() {
//     if (_accelerometerValues != null) {
//       // Assuming linear motion in one direction (e.g., x-axis)
//       // You may need to adjust this based on your specific use case
//       // Speed is calculated as the absolute value of acceleration multiplied by time
//       double acceleration = _accelerometerValues!.x;
//       double timeInterval = 0.1; // Example: Time interval between accelerometer readings
//       double speed = (acceleration * timeInterval).abs();
//
//       setState(() {
//         _speed = speed;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Speed Calculator'),
//       ),
//       body: Center(
//         child: Text(
//           'Speed: $_speed m/s',
//           style: TextStyle(fontSize: 24.0),
//         ),
//       ),
//     );
//   }
// }
