import 'package:path_provider/path_provider.dart';
import 'package:pay_app/models/pay_app_model.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._privateConstructor();

  static final LocalDatabase _instance = LocalDatabase._privateConstructor();

  factory LocalDatabase() => _instance;

  final String _tableName = "PayApp";
  Database? _database;

  Future<void> init() async {
    if (_database == null) {
      _database = await _initDatabase();
    }
  }

  Future<Database> _initDatabase() async {
    try {
      final databasePath = await getApplicationDocumentsDirectory();
      final path = "${databasePath.path}/PayApp.db";
      return await openDatabase(path, version: 1, onCreate: _createTable);
    } catch (e, s) {
      print("Error initializing database: $e\n$s");
      rethrow;
    }
  }

  Future<void> _createTable(Database db, int version) async {
    try {
      await db.execute("""
        CREATE TABLE $_tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          price INTEGER NOT NULL,
          day TEXT NOT NULL,
          cardprice TEXT NULL
        )
      """);
    } catch (e, s) {
      print("Error creating table: $e\n$s");
      rethrow;
    }
  }

  Future<List<PayAppModel>> get() async {
    await init();
    final data = await _database?.query(_tableName) ?? [];
    return data.map((map) => PayAppModel.fromMap(map)).toList();
  }

  Future<int> insert(PayAppModel item) async {
    await init();
    return await _database!.insert(_tableName, item.toMap());
  }

  Future<void> update(PayAppModel item) async {
    await init();
    await _database!.update(
      _tableName,
      item.toMap(),
      where: "id = ?",
      whereArgs: [item.id],
    );
  }

  Future<void> delete(int id) async {
    await init();
    await _database!.delete(_tableName, where: "id = ?", whereArgs: [id]);
  }
}
