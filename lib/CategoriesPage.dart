import 'package:flutter/material.dart';
import 'Searx.dart';
import 'CategoryPage.dart';

class CategoriesPage extends StatefulWidget {
  CategoriesPage({Key key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Categories"),
      ),
      body: new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(CATEGORY_LIST.keys.toList()[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryPage(CATEGORY_LIST.keys.toList()[index])),
              );
            },
            leading: Icon(CATEGORY_LIST.values.toList()[index]),
          );
        },
        itemCount: CATEGORY_LIST.length,
      ),
    );
  }
}
