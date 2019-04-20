
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:linux_today/news.dart';
import 'package:linux_today/newsdao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [News])
abstract class AppDatabase extends FloorDatabase {
  NewsDao get newsDao;
}