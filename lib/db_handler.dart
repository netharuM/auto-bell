import 'package:auto_bell/models/bell.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DBHandler {
  DBHandler._init();
  static final DBHandler instance = DBHandler._init();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDB();

  Future<Database> _initDB() async {
    sqfliteFfiInit();
    String pathToDb = await getApplicationDocumentsDirectory().then((dir) {
      return join(dir.path, 'icmu-auto-bell', 'data', 'bells.db');
    });
    return databaseFactoryFfi.openDatabase(
      pathToDb,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bells (
        id INTEGER PRIMARY KEY,
        time TEXT,
        title TEXT,
        description TEXT,
        pathToAudio TEXT,
        days TEXT,
        activate INTEGER
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getBells() async {
    final Database db = await database;
    return await db.query('bells');
  }

  Future<int> insertBell(Bell bell) async {
    final Database db = await database;
    return await db.insert(
        'bells', bell.toMap(boolToInt: true, listToString: true));
  }

  Future<int> updateBell(Bell bell) async {
    final Database db = await database;
    bell.deactivateBell();
    bell.dispose();
    return await db.update(
        'bells', bell.toMap(boolToInt: true, listToString: true),
        where: 'id = ?', whereArgs: [bell.id]);
  }

  Future<int> deleteBell(Bell bell) async {
    final Database db = await database;
    bell.deactivateBell();
    bell.dispose();
    return await db.delete('bells', where: 'id = ?', whereArgs: [bell.id]);
  }
}
