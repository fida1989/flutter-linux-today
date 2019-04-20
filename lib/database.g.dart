// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final database = _$AppDatabase();
    database.database = await database.open(name ?? ':memory:', _migrations);
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  NewsDao _newsDaoInstance;

  Future<sqflite.Database> open(String name, List<Migration> migrations) async {
    final path = join(await sqflite.getDatabasesPath(), name);

    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (database, startVersion, endVersion) async {
        MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);
      },
      onCreate: (database, _) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `news` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `title` TEXT NOT NULL, `date` TEXT NOT NULL, `desc` TEXT NOT NULL, `link` TEXT NOT NULL)');
      },
    );
  }

  @override
  NewsDao get newsDao {
    return _newsDaoInstance ??= _$NewsDao(database, changeListener);
  }
}

class _$NewsDao extends NewsDao {
  _$NewsDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _newsInsertionAdapter = InsertionAdapter(
            database,
            'news',
            (News item) => <String, dynamic>{
                  '_id': item.id,
                  'title': item.title,
                  'date': item.date,
                  'desc': item.desc,
                  'link': item.link
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final _newsMapper = (Map<String, dynamic> row) => News(
      row['_id'] as int,
      row['title'] as String,
      row['date'] as String,
      row['desc'] as String,
      row['link'] as String);

  final InsertionAdapter<News> _newsInsertionAdapter;

  @override
  Future<List<News>> findAllNews() async {
    return _queryAdapter.queryList('SELECT * FROM news', mapper: _newsMapper);
  }

  @override
  Future<void> deleteAllNews() async {
    await _queryAdapter.queryNoReturn('DELETE FROM news');
  }

  @override
  Future<void> insertAllNews(List<News> news) async {
    await _newsInsertionAdapter.insertList(
        news, sqflite.ConflictAlgorithm.abort);
  }
}
