import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dog.dart';

class DbService {
  static Database? _db;

  // open (or create) the database
  static Future<Database> getDb() async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'dog_diary.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favorites(id INTEGER PRIMARY KEY AUTOINCREMENT, breed TEXT, imageUrl TEXT, caption TEXT, savedAt TEXT)',
        );
      },
      version: 1,
    );
    return _db!;
  }

  // insert a dog into favorites
  static Future<void> insertDog(Dog dog) async {
    final db = await getDb();
    await db.insert('favorites', dog.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // get all saved dogs
  static Future<List<Dog>> getFavorites() async {
    final db = await getDb();
    final maps = await db.query('favorites', orderBy: 'savedAt DESC');
    return maps.map((m) => Dog.fromMap(m)).toList();
  }

  // delete a single dog by id
  static Future<void> deleteDog(int id) async {
    final db = await getDb();
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  // delete all saved dogs
  static Future<void> clearAll() async {
    final db = await getDb();
    await db.delete('favorites');
  }

  // update caption for a saved dog
  static Future<void> updateCaption(int id, String caption) async {
    final db = await getDb();
    await db.update('favorites', {'caption': caption},
        where: 'id = ?', whereArgs: [id]);
  }
}