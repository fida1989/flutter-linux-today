import 'package:floor/floor.dart';
import 'package:linux_today/news.dart';

@dao
abstract class NewsDao {
  @Query('SELECT * FROM news')
  Future<List<News>> findAllNews();


  @Query('DELETE FROM news')
  Future<void> deleteAllNews(); // query without returning an entity

  @insert
  Future<void> insertAllNews(List<News> news);
}
