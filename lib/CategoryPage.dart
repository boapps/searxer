import 'package:flutter/material.dart';
import 'Searx.dart';
import 'Settings.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage(this.categoryName, {Key key}) : super(key: key);
  String categoryName;
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
      refreshEditableEngines();
      editableEngines.keys.toList().length;
  }

  Map<String, bool> editableEngines = Map();

  void refreshEditableEngines() async {
    editableEngines.clear();

    for (String engineName in ENGINES[widget.categoryName].keys) {
      bool enabled =
          await Settings().getEngine(engineName, widget.categoryName);

      editableEngines.putIfAbsent(engineName,
          () => enabled ?? ENGINES[widget.categoryName][engineName]);
    }
    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(widget.categoryName),
      ),
      body: new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return SwitchListTile(
            title: Text(ENGINES[widget.categoryName].keys.toList()[index]),
            value: editableEngines.values.toList()[index],
            onChanged: (bool enabled) {
              setState(() {
                editableEngines[editableEngines.keys.toList()[index]] = enabled;
                Settings().setEngine(
                    ENGINES[widget.categoryName].keys.toList()[index],
                    widget.categoryName,
                    enabled);
              });
              refreshCurrentEngines();
            },
          );
        },
        itemCount: editableEngines.keys.toList().length,
      ),
    );
  }
}
