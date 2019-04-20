import 'package:flutter/material.dart';
import 'package:custom_progress_dialog/custom_progress_dialog.dart';
import 'package:linux_today/database.dart';
import 'package:linux_today/network.dart';
import 'package:linux_today/news.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/scheduler.dart';
import 'package:dio/dio.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linux Today',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Linux Today'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ProgressDialog _progressDialog = ProgressDialog();
  List<News> newsList = List<News>();
  int count = 0;

  final database =
      $FloorAppDatabase.databaseBuilder('linux_today_database.db').build();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              loadData();
            },
          )
        ],
      ),
      body:
          getNewsListView(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget getNewsListView() {
    return Scrollbar(
      child: ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
            title: Text(this.newsList[position].title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            subtitle: Text(this.newsList[position].date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            isThreeLine: false,
            dense: false,
            leading: Image(
              image: AssetImage('images/linux_today.png'),
              width: 60,
              height: 60,
            ),
            onTap: () {
              print(this.newsList[position].link);
              _launchURL(this.newsList[position].link);
            },
          );
        },
      ),
    );
  }

  void updateListView() {
    Future<List<News>> newsListFuture = getNewsList();
    newsListFuture.then((dataList) {
      setState(() {
        if (dataList != null) {
          this.newsList = dataList;
          this.count = dataList.length;
        } else {
          _showErrorDialog();
        }
      });
    });
  }

  void _showInternetErrorDialog() {
    Alert(
      context: context,
      type: AlertType.error,
      title: "Internet Not Found!",
      style: AlertStyle(isOverlayTapDismiss: false, isCloseButton: false),
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          width: 120,
        )
      ],
    ).show();
  }

  void _showErrorDialog() {
    Alert(
      context: context,
      type: AlertType.error,
      title: "An Error Has Occurred!",
      style: AlertStyle(isOverlayTapDismiss: false, isCloseButton: false),
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          width: 120,
        )
      ],
    ).show();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  void loadData() {
    Network.instance.checkNetwork().then((value) async {
      if (value) {
        updateListView();
      } else {
        print("No Net");

        database.then((db) {
          db.newsDao.findAllNews().then((onValue) {
            print("Cache Size ${onValue.length}");
            setState(() {
              if (onValue.length > 0) {
                this.newsList = onValue;
                this.count = onValue.length;
              } else {
                _showInternetErrorDialog();
              }
            });
          });
        });
      }
    });
  }

  Future<List<News>> getNewsList() async {
    _progressDialog.showProgressDialog(context);
    newsList.clear();
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      Response response = await Dio()
          .get("http://feeds.feedburner.com/linuxtoday/linux?format=xml");
      var rssFeed = RssFeed.parse(response.toString());
      print(rssFeed.items.length);

      database.then((db) {
        db.newsDao.deleteAllNews();
      });

      for (var item in rssFeed.items) {
        var news = News(item.hashCode, item.title, item.pubDate, item.description,
            item.link);
        newsList.add(news);
      }

      database.then((db) {
        db.newsDao.insertAllNews(this.newsList);
//        db.newsDao.findAllNews().then((values) {
//          print("Cache Size ${values.length}");
//        });
      });

      _progressDialog.dismissProgressDialog(context);
    } catch (e) {
      print(e);
      _progressDialog.dismissProgressDialog(context);
      _showErrorDialog();
    }
    return newsList;
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
      _showErrorDialog();
    }
  }
}
