import 'package:floor/floor.dart';

@Entity(tableName: 'news')
class News {

  @PrimaryKey(autoGenerate: true)
  final int _id;

  @ColumnInfo(name: 'title', nullable: false)
  final String _title;

  int get id => _id;

  @ColumnInfo(name: 'date', nullable: false)
  final String _date;

  @ColumnInfo(name: 'desc', nullable: false)
  final String _desc;

  @ColumnInfo(name: 'link', nullable: false)
  final String _link;





  News(this._id,this._title,this._date, this._desc, this._link);

  String get title => _title;



  String get date => _date;



  String get desc => _desc;



  String get link => _link;




}