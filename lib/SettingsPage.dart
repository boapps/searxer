import 'package:flutter/material.dart';
import 'Searx.dart';
import 'Settings.dart';
import 'CategoriesPage.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool autoComplete = false;
  void initSettings() async {
    autoComplete = await Settings().getAutoComplete();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Settings"),
      ),
      body: new ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          new CheckboxListTile(
            value: autoComplete,
            onChanged: (bool isAuto) {
              setState(() {
                autoComplete = isAuto;
                Settings().setAutoComplete(isAuto);
              });
            },
            title: new Text("Auto-complete (with Google)"),
            subtitle: Text("show possible completions when typing search query"),
          ),
          new ListTile(
            title: new Text("Searx URL:"),
            trailing: new Text(searxURL),
            onTap: () {
              return showDialog(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext context) {
                  return new SearxURLDialog();
                },
              ).then((var a) {
                setState(() {});
              });
            },
            subtitle: Text("searx instance to use"),
          ),
          new ListTile(
            title: Text("Categories"),
            onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesPage()),
                );
            },
            subtitle: Text("enable/disable engines here"),
          ),
        ],
      ),
    );
  }
}

class SearxURLDialog extends StatefulWidget {
  @override
  SearxURLDialogState createState() => new SearxURLDialogState();
}

class SearxURLDialogState extends State<SearxURLDialog> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = new TextEditingController();
    controller.text = searxURL;

    return SimpleDialog(
      title: new Text("Searx engine URL"),
      children: [
        new TextField(
          onChanged: (String url) {
            searxURL = url;
          },
          autofocus: true,
          controller: controller,
        ),
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              Settings().setURL(searxURL);
            },
            child: new Text("OK"))
      ],
      contentPadding: EdgeInsets.all(10),
    );
  }
}
