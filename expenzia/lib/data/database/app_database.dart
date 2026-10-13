import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_strings.dart';

/// Manages SQLite database initialization and provides access to the database.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase _instance = AppDatabase._();
  static AppDatabase get instance => _instance;

  static Database? _database;

  static const int _version = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppStrings.dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppStrings.tableExpenses} (
        ${AppStrings.colId}          INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppStrings.colTitle}       TEXT    NOT NULL,
        ${AppStrings.colAmount}      REAL    NOT NULL,
        ${AppStrings.colCategory}    TEXT    NOT NULL,
        ${AppStrings.colDate}        TEXT    NOT NULL,
        ${AppStrings.colDescription} TEXT,
        ${AppStrings.colCreatedAt}   TEXT    NOT NULL,
        ${AppStrings.colUpdatedAt}   TEXT    NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  /// Close the database connection. Prefer not calling unless absolutely needed.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
