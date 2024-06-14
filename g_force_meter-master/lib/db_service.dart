import 'package:g_force_meter/model_class/db_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class SqliteService {
  late Database _database;

  Future<void> initializeDB() async {
    String path = await getDatabasesPath();
    _database = await openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE sensorDetails(tripId TEXT PRIMARY KEY, tripName TEXT, filePath TEXT, distance TEXT, date TEXT)",
        );
        await database.execute(
          "CREATE TABLE sensorResponse(id INTEGER PRIMARY KEY AUTOINCREMENT, tripId INTEGER)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertSensorDetails(SensorDetails sensorDetails) async {
    await _database.insert(
      'sensorDetails',
      sensorDetails.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
