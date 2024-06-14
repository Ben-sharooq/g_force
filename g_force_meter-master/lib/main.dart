import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:g_force_meter/db_service.dart';
import 'package:g_force_meter/g_force_display.dart';
import 'package:g_force_meter/model_class/base_class.dart';
import 'package:g_force_meter/model_class/db_models.dart';
import 'package:g_force_meter/model_class/main_model.dart';
import 'package:g_force_meter/sensor_display.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model_class/model.dart';

// const double G = 9.80665;
final Uri url = Uri.parse("https://github.com/navalt/g_force_meter");
//
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MyHomePage(title: "PROJECT"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SqliteService _sqliteService = SqliteService();
  // List<double>? _userAccelerometerValues;

  // List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  StreamSubscription<Position>? _positionStream;
  //final sensorSpeedCalculator = SensorSpeedCalculator();
  // final _positionStream= StreamSubscription<Position>;
  bool _flag = true;
  bool flag = true;
  List<SensorData> sensorDataList = [];
  List<SensorData> sensorDataListTemp = [];
  int backAndForth = 0;
  bool locationPermissionStatus = false;
  double gForceMagn = double.nan;
  double gForceX = double.nan;
  double gForceY = double.nan;
  double gForceZ = double.nan;
  bool noGravity = false;
  AccelerometerEvent? _accelerometerValues;
  double _speed = 0.0;

  SharedPreferences? prefs;

  void updateGForce(List<double>? vec) {
    if (vec == null) return;
    double gForceTmp = 0;
    for (double val in vec) {
      gForceTmp += val * val;
    }
    gForceTmp = sqrt(gForceTmp);
    // setState(() {
    //   gForceMagn = gForceTmp / G;
    //   gForceX = vec[0] / G;
    //   gForceY = vec[1] / G;
    //   gForceZ = vec[2] / G;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GForceDisplay(
                _speed,
                leftText: "Speed:",
                rightText: "km/h",
              ),
              const SizedBox(
                height: 10,
              ),
              GForceDisplay(gForceMagn, leftText: "Magnitude:"),
              Row(children: [
                Expanded(
                  child: GForceDisplay(gForceX,
                      leftText: "x:", fontSize: 40, padSign: true),
                ),
                Expanded(
                  child: GForceDisplay(gForceY,
                      leftText: "y:", fontSize: 40, padSign: true),
                ),
                Expanded(
                  child: GForceDisplay(gForceZ,
                      leftText: "z:", fontSize: 40, padSign: true),
                )
              ]),
              SensorDisplay(
                  name: "Accelerometer",
                  eventStream: accelerometerEventStream(),
                  eventToDoubles: (e) {
                    return <double>[e.x, e.y, e.z];
                  },
                  updateCallback: (vec) {
                    if (noGravity) return;
                    updateGForce(vec);
                  }),
              // SensorDisplay(
              //     name: "(w/o gravity)",
              //     eventStream: userAccelerometerEventStream() ,
              //     eventToDoubles: (e) {
              //       return <double>[e.x, e.y, e.z];
              //     },
              //     updateCallback: (vec) {
              //       if (!noGravity) return;
              //       updateGForce(vec);
              //     }),
              SensorDisplay(
                  name: "Gyroscope",
                  eventStream: gyroscopeEventStream(),
                  eventToDoubles: (e) {
                    return <double>[e.x, e.y, e.z];
                  }),
              SensorDisplay(
                  name: "Magnetometer",
                  eventStream: magnetometerEventStream(),
                  eventToDoubles: (e) {
                    return <double>[e.x, e.y, e.z];
                  }),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                child: Text("Start"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _flag
                      ? const Color.fromARGB(255, 194, 194, 194)
                      : Colors.blue,
                ),
                onPressed: () {
                  print("Button started");
                  startListening();
                  setState(() => _flag = !_flag);
                  // if (backAndForth % 2 == 1) {
                  //   _accelerometerData.clear();
                  //   _gyroscopeData.clear();
                  // }

                  // // start a stream that saves acceleroemeterData
                  // _streamSubscriptions.add(
                  //     accelerometerEvents.listen((AccelerometerEvent event) {
                  //       sensorData.add(SensorData(accelerometerX:event.x,accelerometerY:event.y,accelerometerZ:event.z   ));
                  //       // _accelerometerData.add(Se(
                  //       //     DateTime.now(), <double>[event.x, event.y, event.z]));
                  //     }));
                  // // start a stream that saves gyroscopeData
                  // _streamSubscriptions
                  //     .add(gyroscopeEvents.listen((GyroscopeEvent event) {
                  //   sensorData.add(SensorData(gyroscopeX:event.x,gyroscopeY:event.y,gyroscopeZ:event.z   ));

                  //   // _gyroscopeData.add(GyroscopeData(
                  //   //     DateTime.now(), <double>[event.x, event.y, event.z]));
                  // }));
                  backAndForth++;
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text("Stop"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _flag ? Color.fromARGB(255, 194, 194, 194) : Colors.blue,
                ),
                onPressed: () async {
                  setState(() => _flag = !_flag);
                  await stopListening();
                },
              ),
            ],
          ),
        ),
      )),
    );
  }

  void startListening() {
    LocationSettings locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      forceLocationManager: true,
    );
    _streamSubscriptions.add(
      StreamGroup.merge([
        accelerometerEventStream(),
        gyroscopeEventStream(),
      ]).listen((dynamic event) async {
        String dateTime = DateTime.now().toString();

        try {
          if (event is GyroscopeEvent) {
            final sensorData = SensorData(
              accelerometerX: null,
              accelerometerY: null,
              accelerometerZ: null,
              gyroscopeX: event.x,
              gyroscopeY: event.y,
              gyroscopeZ: event.z,
              speed: 0.0,
              distance: 0.0,
              reportDateTime: dateTime.toString(),
            );
            sensorDataListTemp.add(sensorData);
          } else if (event is AccelerometerEvent) {
            double totalDistance = 0.0;
            double speed = 0.0;
            Position? previousPosition;
            double totalTimeInSeconds = 0;
            Geolocator.getPositionStream(locationSettings: locationSettings)
                .listen((position) {
              double positionSpeedMps = position.speed ?? 0;
              double positionSpeedKmph = positionSpeedMps * 3.6;

              speed = positionSpeedKmph;
              setState(() {
                _speed = speed;
              });

              if (sensorDataListTemp.isNotEmpty) {
                final lastSensorData = sensorDataListTemp.last;

                /* print("Last Sensor Data: ${jsonEncode(lastSensorData)}");
                print("Current Speed: $speed");
                print("Current ACCELO: ${event.x} ${event.y} ${event.z}");*/
                final updatedSensorData = SensorData(
                  id: 0,
                  accelerometerX: event.x,
                  accelerometerY: event.y,
                  accelerometerZ: event.z,
                  gyroscopeX: lastSensorData.gyroscopeX,
                  gyroscopeY: lastSensorData.gyroscopeY,
                  gyroscopeZ: lastSensorData.gyroscopeZ,
                  speed: speed,
                  distance: totalDistance,
                  reportDateTime: dateTime.toString(),
                );
                print("updatedSensorData: ${jsonEncode(updatedSensorData)}");
                sensorDataList.add(updatedSensorData);
                //sensorDataList[sensorDataList.length - 1] = updatedSensorData;
              } else {
                print("Speeeeeeeeeeeeeed$speed");
                final updatedSensorData = SensorData(
                  id: 0,
                  accelerometerX: event.x,
                  accelerometerY: event.y,
                  accelerometerZ: event.z,
                  gyroscopeX: 0.0,
                  gyroscopeY: 0.0,
                  gyroscopeZ: 0.0,
                  // speed: speed,
                  distance: totalDistance,
                  reportDateTime: dateTime.toString(),
                );
                sensorDataList.add(updatedSensorData);
              }
            });
          }
        } catch (e) {
          print("Error updating sensor data: $e");
        }
      }),
    );
  }

  String generateUniqueId() {
// Get current timestamp
    DateTime now = DateTime.now();
    String timestamp = now.microsecondsSinceEpoch.toString();
    String randomString = ""; //append userid
    String tripId = timestamp + randomString;

    return tripId; //use this as tripId (User id + timestamp)
  }

  Future<void> stopListening() async {
    for (var subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
    if (_positionStream != null) {
      _positionStream?.cancel();
    }
    String tripId = generateUniqueId();
    final userModel =
        UserModel(userid: 123456, tripId: tripId, timeStamp: "", token: "");
    Future.delayed(const Duration(milliseconds: 5));
    // ignore: non_constant_identifier_names
    final sensorDataJson = sensorDataList.map((data) => data.toJson()).toList();
    final distance = calculateDistance(sensorDataList);
    try {
      String fileContent = jsonEncode({
        'UserModel': userModel,
        "totalDistance": distance,
        'SensorData': sensorDataJson,
      });
      final sensorDetails = SensorDetails(
        tripId: tripId,
        tripName: "",
        filePath: "$tripId.json",
        distance: distance.toString(),
      );
      await _sqliteService.insertSensorDetails(sensorDetails);
      writeFilesToCustomDevicePath(tripId, fileContent);
    } catch (e) {
      print("Exception in file creation $e");
    }
  }

  Future<void> writeFilesToCustomDevicePath(
      String tripId, String fileContent) async {
    try {
      Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();

      if (directory == null) {
        print("Directory is null. Unable to determine file path.");
        return;
      }
      if (locationPermissionStatus == false) {
        PermissionStatus storagePermissionStatus =
            await Permission.storage.request();
      }
      File file = File("${directory.path}/$tripId.json");
      print("FILE PATH: ${file.path}");

      await file.writeAsString(fileContent);
      print("File written successfully.");
    } catch (e) {
      print("Error writing file: $e");
    }
  }

  double calculateDistance(List<SensorData> sensorDataList) {
    double totalDistance = 0.0;

    for (int i = 1; i < sensorDataList.length; i++) {
      totalDistance += sensorDataList[i].distance ?? 0.0;
    }

    return totalDistance;
  }

  @override
  void dispose() {
    for (var subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
    if (_positionStream != null) {
      _positionStream?.cancel();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    @override
    void dispose() {
      for (var subscription in _streamSubscriptions) {
        subscription.cancel();
      }
      _streamSubscriptions.clear();
      if (_positionStream != null) {
        _positionStream?.cancel();
      }
      super.dispose();
    }

    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    _sqliteService.initializeDB();
    _requestLocationPermission();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      setState(() {
        noGravity = value.getBool("noGravity") ?? false;
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    PermissionStatus locationPermission = await Permission.location.request();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      //_calculateSpeed();
    } else {
      setState(() {
        _speed = -1.0;
      });
    }

    if (locationPermission.isGranted) {
      setState(() {
        locationPermissionStatus = true;
      });
    }
  }

  Future<SpeedAndDistance> _calculateSpeed() async {
    try {
      // Create a StreamController to handle the stream
      StreamController<SpeedAndDistance> controller = StreamController();

      // Initialize variables
      Position? previousPosition;
      double totalDistance = 0;
      double totalTimeInSeconds = 0;

      // Subscribe to the position stream
      StreamSubscription<Position> _positionStreamSubscription =
          Geolocator.getPositionStream().listen((Position newPosition) {
        if (previousPosition != null) {
          // Calculate distance between previous and current positions
          double distance = Geolocator.distanceBetween(
            previousPosition!.latitude,
            previousPosition!.longitude,
            newPosition.latitude,
            newPosition.longitude,
          );

          // Calculate time difference in seconds
          int timeDifferenceInSeconds =
              (newPosition.timestamp.difference(previousPosition!.timestamp))
                  .inSeconds;

          // Update total distance and total time
          totalDistance += distance;
          totalTimeInSeconds += timeDifferenceInSeconds;
        }

        previousPosition = newPosition;

        if (totalTimeInSeconds != 0) {
          double speed = totalDistance / (totalTimeInSeconds / 1000);
          double speedKmph = speed * 3.6;
          double totalDistanceKm = totalDistance / 1000;
          controller.add(SpeedAndDistance(speedKmph, totalDistanceKm));
        }
      });

      // Wait for the first result from the stream
      SpeedAndDistance result = await controller.stream.first;

      // Cancel the stream subscription
      await _positionStreamSubscription.cancel();

      // Close the stream controller
      await controller.close();

      // Return the result
      return result;
    } catch (e) {
      print('Error calculating speed: $e');
      return SpeedAndDistance(0.0, 0.0);
    }
  }
}
