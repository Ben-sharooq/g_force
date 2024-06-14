import 'dart:async';

import 'package:flutter/material.dart';

class SensorDisplay<E> extends StatefulWidget {
  const SensorDisplay(
      {super.key,
      this.name = "Sensor",
      required this.eventStream,
      required this.eventToDoubles,
      this.updateCallback});

  final String name;
  final Stream<E> eventStream;
  final List<double>? Function(E) eventToDoubles;
  final void Function(List<double>?)? updateCallback;

  @override
  State<SensorDisplay<E>> createState() => _SensorDisplayState();
}

class _SensorDisplayState<E> extends State<SensorDisplay<E>> {
  late final StreamSubscription<E> _streamSubscription;

  String vToString(double v) {
    return v.toStringAsFixed(v.isNegative ? 2 : 3);
  }

  List<double>? _sensorValues;


  // void _calculateSpeed() {
  //   if (_accelerometerValues != null) {
  //     // Assuming linear motion in one direction (e.g., x-axis)
  //     // You may need to adjust this based on your specific use case
  //     // Speed is calculated as the absolute value of acceleration multiplied by time
  //     double acceleration = _accelerometerValues!.x;
  //     double timeInterval = 0.1; // Example: Time interval between accelerometer readings
  //     double speed = (acceleration * timeInterval).abs();
  //
  //     setState(() {
  //       _speed = speed;
  //     });
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    final sensor = _sensorValues?.map(vToString).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${widget.name}: '),
        Text(
          '$sensor',
          style: const TextStyle(fontFamily: 'RobotoMono'),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.eventStream.listen(
      (E event) {
        setState(() {
          _sensorValues = widget.eventToDoubles(event);
          widget.updateCallback?.call(_sensorValues);
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }
}
