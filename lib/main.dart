import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'page.dart';
import 'search.dart';

void main() =>
    runApp(new MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}
//Splash screen
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 7,
      navigateAfterSeconds: new AfterSplash(),
      title: new Text(
        'Flutter Wiki',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      image: Image.asset('assets/wikipedia.jpg',width: 240,height: 240,),
      backgroundColor: Colors.white,
      loaderColor: Colors.lightBlue,
    );
  }
}

class AfterSplash extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Wiki',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Wikipedia Search'),
    );
  }
}



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _searchview = TextEditingController();

  static var desctopics,lastsearch;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static List<String> relatedTopics=[
    "Python",
    "C",
    "C++",
    "Javascript",
    "Java",
    "Dart",
    "Anaconda",
    "Panda",
    "Oracle",
    "Hadoop",
    "Hive",
    "Canada",
    "Bengaluru",
    "Cycle","Flutter","Android","India","Australia","Car","Bike"
  ];
  final duplicateItems = List<String>.generate(20, (i) => relatedTopics[i]);
  var items = List<String>();
  var search_val;
  @override
  void initState() {
    relatedTopics.sort();
    items.addAll(duplicateItems);
    searchstate();
    super.initState();
  }



  searchstate() async {
    final SharedPreferences prefs = await _prefs;
    lastsearch=prefs.getString("value") ?? 'Android' ;
    setState(() {

        filterSearchResults(lastsearch);

    });

  }


  filterSearchResults(String query) async {
    List<String> dummySearchList = List<String>();
    final SharedPreferences prefs = await _prefs;
    relatedTopics = await search(query);
    setState(() {
      prefs.setString("value", query);
    });
    dummySearchList.addAll(relatedTopics);
    if(query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if(item.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Container(
        child: Column(
          children:
            <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              setState(() {
                                search_val=value;
                              });

                            },
                            onTap:() async {
                              filterSearchResults(search_val);
                            },
                            controller: _searchview,
                            decoration: InputDecoration(
                                labelText: "Search",
                                hintText: "Search",
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('${items[index]}'),
                                onTap: () async {
                                  final SharedPreferences prefs = await _prefs;
                                  setState(() {
                                    prefs.setString("value", '${items[index]}');
                                  });

                                  desctopics = await page('${items[index]}');
                                  var content = desctopics.content;
                                  var url = desctopics.url;
                                  showDialogFunc(context,index,content,url);
                                },

                              );
                            },
                          ),
                        ),
                      ]
          ,
        ),
      ),
    );
  }

  showDialogFunc(context, int item, content,url) {
    return showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(15),
              height: 320,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Text(
                    '${items[item]}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    // width: 200,
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        content,
                        maxLines: 3,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    // width: 200,
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                    child: Align(
                        alignment: Alignment.center,
                        child: new RaisedButton(
                            onPressed: ()async{launchURL(url);},
                            child: new Text('Read More',
                                style: TextStyle(fontSize: 16, color: Colors.black54)
                            )
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  launchURL(url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


}

