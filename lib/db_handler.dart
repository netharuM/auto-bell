import 'package:auto_bell/models/bell.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DBHandler {
  DBHandler._init();

  /// instance of the [DBHandler]
  static final DBHandler instance = DBHandler._init();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDB();

  /// initializes the [Database]
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

  /// this will execute a sql commands to create the databases
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

  /// returns bells as a [List] of [Map]s `List<Map<String, dynamic>>`
  /// - this also sorts the bells by there position or order
  Future<List<Map<String, dynamic>>> getBells() async {
    final Database db = await database;
    List<Map<String, dynamic>> map = [
      ...await db.query('bells')
    ]; // why its in an array is because we have to create a clone of it in order to modify it
    // (modifying it in the sorting function)
    map.sort((a, b) => a['position'].compareTo(b['position']));
    return map;
  }

  /// inserts a [Bell] into the database
  Future<int> insertBell(Bell bell) async {
    final Database db = await database;
    return await db.insert(
        'bells', bell.toMap(boolToInt: true, listToString: true));
  }

  /// updates a bell in the dataBase
  ///  - [bell] - a bell with updated parameters make sure that `id` is available in the bell
  ///   - lets say you wanna update the title of a bell
  ///     - ```dart
  ///     updateBell(someBell..title = "someNewTitle");
  ///     ```
  ///  - [dispose] - enable or disable the process of deactivating bell when updating
  ///
  Future<int> updateBell(Bell bell, {bool dispose = true}) async {
    final Database db = await database;
    if (dispose) {
      bell.dispose();
    }
    return await db.update(
        'bells', bell.toMap(boolToInt: true, listToString: true),
        where: 'id = ?', whereArgs: [bell.id]);
  }

  /// moves a bell from a [prevPos] to a [newPos] in the dataBase
  Future<void> moveBell(int prevPos, int newPos) async {
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
            intAsBool: true, listAsStrings: true, disableActivation: true);
      newbell.position = bellMaps[i]['position'];
      await updateBell(newbell);
    }
  }

  /// fixes the messed up bell positions
  ///
  /// when you delete a bell bell there are gaps between bell positions - `[0,1,2,4,5]`
  ///
  /// `3` is missing
  ///
  /// this will fix the bell positions to `[0,1,2,3,4]`
  Future<void> fixBellPositions() async {
    List<Map<String, dynamic>> bellsMap = await getBells();
    for (var i = 0; i < bellsMap.length; i++) {
      Bell fixedBell = Bell()
        ..fromMap(bellsMap[i], intAsBool: true, listAsStrings: true);
      fixedBell.position = i;
      await updateBell(fixedBell);
    }
  }

  /// deletes a [Bell]
  Future<int> deleteBell(Bell bell) async {
    final Database db = await database;
    bell.deactivateBell();
    bell.dispose();
    int deletedId =
        await db.delete('bells', where: 'id = ?', whereArgs: [bell.id]);
    fixBellPositions();
    return deletedId;
  }
}
