import 'package:momentum/data/database_exception.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    try {
      var databasePath = await getDatabasesPath();
      String name = "momentum.db";
      String path = join(databasePath, name);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onOpen: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON')
      );
    } catch (e, stack) {
      Error.throwWithStackTrace(
        MomentumDBException('Failed to initialise database: $e'),
        stack
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(Project.createTableSql);
    await db.execute(Session.createTableSql);
    await db.execute(Idea.createTableSql);
  }
}
