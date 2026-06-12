import 'package:flutter/material.dart';
import 'package:map_initialization/models/lost_items.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {

  static final DbHelper instance = DbHelper._init();

  DbHelper._init();

  static Database? db;

  static Future<Database> get database async {
    if(db != null) {
      return db!;
    }

    db = await initDataBase();
    return db!;
  }

  static Future<Database> initDataBase() async {
    final  databasesPath = join(await getDatabasesPath(),'lost_found.db',);

    return await openDatabase(databasesPath,version: 1,onCreate: (data,version) async {



      await data.execute('''
      
      CREATE TABLE lost_items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      itemName TEXT,
      description TEXT,
      categoryType TEXT,
      lostDate TEXT,
      latitude REAL,
      longitude REAL,
      picture TEXT
      
      ) 
      ''');
    }
    );
  }



  //insert data's

  Future insertLostItems(LostItems lostItems) async{
    final dbClient = await database;

      return await dbClient.insert('lost_items', lostItems.toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
  }

  Future<List<LostItems>> getLostItems() async{
    final dbClient = await database;
    
    final data = await dbClient.query('lost_items',);
    return data.map((e) => LostItems.fromJson(e)).toList();
  }

}