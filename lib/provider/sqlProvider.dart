import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlProvider extends ChangeNotifier {
  //
  List dataList = [];

  //
  static Future<void> createTables(sql.Database database) async {
    await database.execute(
        "CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, description TEXT, createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'sql1.db',
      version: 1,
      onCreate: (sql.Database database, version) async {
        await createTables(database);
      },
    );
  }

  createItem(String title, String? description) async {
    final db = await SqlProvider.db();
    final data = {'title': title, "description": description};
    await db.insert("items", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    getItems();
  }

  getItems() async {
    final db = await SqlProvider.db();
    final list = db.query("items", orderBy: "id");
    dataList = await list;
    notifyListeners();
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SqlProvider.db();
    return db.query("items", where: "id = ?", whereArgs: [id], limit: 1);
  }

  updateItem(int id, String title, String? description) async {
    final db = await SqlProvider.db();

    final data = {
      "title": title,
      "description": description,
      "createdAt": DateTime.now().toString()
    };

    await db.update("items", data, where: "id = ?", whereArgs: [id]);
    getItems();
  }

  deleteItem(int id) async {
    final db = await SqlProvider.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (e) {
      debugPrint("Something went wrong when deleting an item: $e");
    }
    getItems();
  }
}
