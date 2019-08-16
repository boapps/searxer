import 'package:flutter/material.dart';
import 'Searx.dart';
import 'Settings.dart';
import 'CategoriesPage.dart';
import 'main.dart';
import 'generated/i18n.dart';

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

  Future<bool> back() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );    
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: back,
      child: Scaffold(
      appBar: AppBar(
        title: new Text(S.of(context).title_settings),
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
            title: new Text(S.of(context).settings_autocomplete),
            subtitle: Text(S.of(context).settings_autocomplete_summary),
          ),
          new ListTile(
            title: new Text(S.of(context).settings_url),
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
            subtitle: Text(S.of(context).settings_url_summary),
          ),
          new ListTile(
            title: Text(S.of(context).settings_category),
            onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesPage()),
                );
            },
            subtitle: Text(S.of(context).settings_category_summary),
          ),
        ],
      ),
    ),);
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
      title: new Text(S.of(context).dialog_url),
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
            child: new Text(S.of(context).ok))
      ],
      contentPadding: EdgeInsets.all(10),
    );
  }
}
