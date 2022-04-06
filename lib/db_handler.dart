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
        position INTEGER NOT NULL,
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
    List<Map<String, dynamic>> map = [
      ...await db.query('bells')
    ]; // why its in an array is because we have to create a clone of it in order to modify it
    // (modifying it in the sorting function)
    map.sort((a, b) => a['position'].compareTo(b['position']));
    return map;
  }

  Future<int> insertBell(Bell bell) async {
    final Database db = await database;
    return await db.insert(
        'bells', bell.toMap(boolToInt: true, listToString: true));
  }

  ///
  /// @param deactivate - enable or disable the process of deactivating bell when updating
  ///
  Future<int> updateBell(Bell bell, {bool deactivate = true}) async {
    final Database db = await database;
    if (deactivate) {
      bell.deactivateBell();
      bell.dispose();
    }
    return await db.update(
        'bells', bell.toMap(boolToInt: true, listToString: true),
        where: 'id = ?', whereArgs: [bell.id]);
  }

  Future<void> moveBell(int prevPos, int newPos,
      {bool disposeBell = true}) async {
    List<Map<String, dynamic>> bellMaps = await getBells();
    prevPos = bellMaps[prevPos]['position'];
    newPos = bellMaps[newPos]['position'];
    List<int> indexArray = [];
    for (int i = 0; i < bellMaps.length; i++) {
      indexArray.add(bellMaps[i]['position']);
    }

    int prevIndex = indexArray.indexOf(prevPos);
    indexArray.removeAt(prevIndex);
    indexArray.insert(newPos, prevPos);

    for (int i = 0; i < indexArray.length; i++) {
      Bell newbell = Bell()
        ..fromMap(bellMaps[indexArray[i]],
            intAsBool: true, listAsStrings: true);
      newbell.position = bellMaps[i]['position'];
      await updateBell(newbell, deactivate: disposeBell);
    }
  }

  Future<void> fixTasksPosition() async {
    List<Map<String, dynamic>> bellsMap = await getBells();
    for (var i = 0; i < bellsMap.length; i++) {
      Bell fixedBell = Bell()
        ..fromMap(bellsMap[i], intAsBool: true, listAsStrings: true);
      fixedBell.position = i;
      await updateBell(fixedBell);
    }
  }

  Future<int> deleteBell(Bell bell) async {
    final Database db = await database;
    bell.deactivateBell();
    bell.dispose();
    int deletedId =
        await db.delete('bells', where: 'id = ?', whereArgs: [bell.id]);
    fixTasksPosition();
    return deletedId;
  }
}
