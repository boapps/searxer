import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:format_bytes/format_bytes.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:searxer/SearchResult.dart';
import 'package:searxer/Searx.dart';
import 'package:searxer/SettingsPage.dart';
import 'package:url_launcher/url_launcher.dart';
//adimport

import 'ImageView.dart';
import 'Searx.dart';
import 'Settings.dart';

void main() {
//adinit
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'searxer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  final TextEditingController _controller = new TextEditingController();
  List<SearchResult> results = new List();
  String searchTerm = "";
  double progress = 0;
  ScrollController _scrollController =
      new ScrollController(keepScrollOffset: false);
  int _page = 0;
//advar

  void initPrefs() async {
    searxURL = await Settings().getURL();
  }

  @override
  void initState() {
//adsetup
    super.initState();
    refreshCurrentEngines();
    initPrefs();
  }

  Future<File> file(String filename) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String pathName = dir.path + filename;
    return File(pathName);
  }

  Future<void> showimg(String url) async {
    ImageProvider imp = NetworkToFileImage(url: url, file: null);

    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HeroPhotoViewWrapper(
                            imageProvider: imp,
                          ),
                    ));
              },
              child: Container(
                  child: Hero(
                tag: "someTag",
                child: Image.network(url, width: 150.0),
              )),
            ),
          );
        });
  }

  Widget _searchItemBuilder(BuildContext context, int index) {
    if (index != results.length)
      return new Column(children: <Widget>[
        ListTile(
          title: new Text(results[index].title +
              ((results[index].filesize != null)
                  ? (" (" + format(results[index].filesize) + ")")
                  : "")),
          leading: results[index].seed != null
              ? new Container(
                  child: new Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text(results[index].seed.toString(),
                            style: TextStyle(color: Colors.green)),
                        new Text(results[index].leech.toString(),
                            style: TextStyle(color: Colors.blue)),
                      ]),
                  //alignment: Alignment(0, 0),
                  width: 40,
                )
              : results[index].thumb != null
                  ? GestureDetector(
                      onTap: () {
                        showimg(results[index].img);
                      },
                      child: new Image.network(results[index].thumb,
                          width: 60, height: 40),
                    )
                  : null,
          trailing: results[index].magnet != null
              ? new Container(
                  child: MaterialButton(
                    onPressed: () async {
                      openURL(results[index].magnet);
                    },
                    child: new Icon(
                      Icons.link,
                      color: Colors.white,
                      size: 18,
                    ),
                    color: Colors.blue,
                    shape: CircleBorder(),
                    height: 42,
                  ),
                  width: 50,
                )
              : null,
          subtitle: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              results[index].date != null
                  ? new Text(results[index].date ?? "")
                  : Container(),
              new Text(
                results[index].purl ?? "",
                style: TextStyle(
                  color: Colors.blue,
                ),
                textAlign: TextAlign.start,
              ),
              results[index].description != null
                  ? new Text(results[index].description ?? "")
                  : Container(),
              results[index].engine != null
                  ? new Text(
                      results[index].engine,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    )
                  : new Container(),
            ],
          ),
          onTap: () async {
            openURL(results[index].url);
          },
        )
      ]);
    else if (results.length != 0)
      return new FlatButton.icon(
          onPressed: () {
            _page++;
            search(searchTerm, page: _page);
          },
          icon: new Icon(Icons.more_horiz),
          label: new Text("more"));
    else
      return new Container();
  }

  void openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch url: ' + url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Searxer"),
        actions: <Widget>[
          new PopupMenuButton(
            itemBuilder: (context) {
              return CATEGORY_LIST.keys.map((String categoryName) {
                return PopupMenuItem(
                  child: Row(children: <Widget>[
                    Container(
                      child: new Icon(CATEGORY_LIST[categoryName]),
                      padding: EdgeInsets.only(right: 10),
                    ),
                    new Text(
                      categoryName,
                    ),
                  ]),
                  value: categoryName,
                );
              }).toList();
            },
            icon: new Icon(CATEGORY_LIST[selectedCategory]),
            onSelected: (String categoryName) {
              selectedCategory = categoryName;
              refreshCurrentEngines().then((void nothing) {
                setState(() {
                  search(searchTerm);
                });
              });
            },
            tooltip: "Category",
          ),
          new PopupMenuButton(
            itemBuilder: (context) {
              return Searx.TIME_RANGE_NAMES.map((String range) {
                return PopupMenuItem(
                  child: new Text(
                    range,
                    style: TextStyle(
                        fontWeight:
                            (Searx.TIME_RANGE_NAMES[selectedTimeRange] == range)
                                ? FontWeight.bold
                                : FontWeight.normal),
                  ),
                  value: range,
                );
              }).toList();
            },
            icon: new Icon(Icons.date_range),
            onSelected: (String range) {
              selectedTimeRange = Searx.TIME_RANGE_NAMES.indexOf(range);
              setState(() {
                search(searchTerm);
              });
            },
          ),
          new IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              }),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Container(
              child: progress != 0
                  ? new LinearProgressIndicator(
                      value: progress,
                    )
                  : new Container(),
              height: 2,
            ),
            new Container(
              padding: EdgeInsets.all(6),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new AutoCompleteTextField<String>(
                      itemSubmitted: (item) => search(item),
                      controller: _controller,
                      itemBuilder: (context, suggestion) => new Padding(
                            child: new ListTile(title: new Text(suggestion)),
                            padding: EdgeInsets.all(0.0),
                          ),
                      itemFilter: (suggestion, input) => suggestion
                          .toLowerCase()
                          .startsWith(input.toLowerCase()),
                      suggestions: suggestions,
                      key: key,
                      textChanged: (String text) async {
                        if (await Settings().getAutoComplete())
                          Searx().getAutoComplete(text);
                        searchTerm = text;
                      },
                      textSubmitted: search,
                      clearOnSubmit: false,
                      onFocusChanged: (hasFocus) {},
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                            gapPadding: 0),
                        contentPadding: EdgeInsets.all(8),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              suggestions.clear();
                              WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => FocusScope.of(context).requestFocus(
                                      key.currentState.textField.focusNode));
                            }),
                      ),
                    ),
                  ),
                  new IconButton(
                    color: Colors.blueAccent,
                    icon: new Icon(Icons.search),
                    onPressed: () => search(searchTerm),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.start,
              ),
            ),
            new Expanded(
              child: new NotificationListener(
                child: new ListView.builder(
                  itemBuilder: _searchItemBuilder,
                  itemCount: results.length + 1,
                  shrinkWrap: true,
                  controller: _scrollController,
                ),
              ),
            ),
//adcont
          ],
        ),
      ),
    );
  }

  void search(String text, {int page = 0}) async {
    setState(() {
      progress = null;
    });

    _page = page;
    searchTerm = text;
    if (page == 0) results.clear();
    if (searchTerm != "")
      results.addAll(await Searx().getSearchResults(searchTerm, page));
    setState(() {
      progress = 0;
    });
  }
}
