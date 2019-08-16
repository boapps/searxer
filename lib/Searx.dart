library searxer.Searx;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:searxer/SearchResult.dart';
import 'package:searxer/Settings.dart';
import 'package:xml/xml.dart' as xml;
import 'generated/i18n.dart';

Map<String, bool> currentEngines = Map();

Future<void> refreshCurrentEngines() async {
  currentEngines.clear();

  for (String engineName in ENGINES[selectedCategory].keys) {
    bool enabled = await Settings().getEngine(engineName, selectedCategory);

    currentEngines.putIfAbsent(
        engineName, () => enabled ?? ENGINES[selectedCategory][engineName]);
  }

}

const Map<String, Map<String, bool>> ENGINES = {
  "general": {
    "archive is": false,
    "wikipedia": true,
    "bing": true,
    "ddg definitions": false,
    "erowid": false,
    "wikidata": false,
    "duckduckgo": true,
    "etymonline": false,
    "faroo": false,
    "gigablast": false,
    "google": false,
    "library genesis": false,
    "qwant": true,
    "reddit": false,
    "startpage": true,
    "yahoo": true,
    "yandex": false,
    "dictzone": false,
    "mymemory translated": false,
    "Duden": false,
    "seznam": false,
    "mojeek": false,
  },
  "files": {
    "digbt": true,
    "fdroid": false,
    "google play apps": false,
    "kickass": true,
    "nyaa": true,
    "acgsou": false,
    "openrepos": false,
    "piratebay": true,
    "tokyotoshokan": false,
    "torrentz": true,
  },
  "images": {
    "bing images": true,
    "deviantart": true,
    "duckduckgo images": true,
    "1x": false,
    "flickr": false,
    "frinkiac": false,
    "google images": false,
    "nyaa": false,
    "acgsou": false,
    "qwant images": true,
    "reddit": true,
    "unsplash": true,
  },
  "it": {
    "apk mirror": false,
    "arch linux wiki": true,
    "bitbucket": true,
    "free software directory": true,
    "gentoo": false,
    "gitlab": true,
    "github": true,
    "geektimes": false,
    "habrahabr": false,
    "hoogle": false,
    "lobste.rs": false,
    "stackoverflow": true,
    "searchcode doc": false,
    "searchcode code": false,
    "framalibre": false,
  },
  "map": {
    "openstreetmap": true,
    "photon": false,
  },
  "music": {
    "deezer": true,
    "digbt": false,
    "genius": true,
    "google play music": false,
    "kickass": false,
    "mixcloud": false,
    "nyaa": false,
    "acgsou": false,
    "piratebay": false,
    "soundcloud": true,
    "spotify": true,
    "tokyotoshokan": false,
    "torrentz": false,
    "youtube": true,
  },
  "news": {
    "bing news": true,
    "digg": false,
    "faroo": false,
    "google news": false,
    "qwant news": true,
    "reddit": true,
    "yahoo news": true,
  },
  "science": {
    "arxiv": true,
    "base": false,
    "crossref": false,
    "google scholar": false,
    "microsoft academic": true,
    "openairedatasets": false,
    "openairepublications": true,
    "pdbe": true,
    "pubmed": false,
    "scanr structures": false,
    "semantic scholar": false,
    "wolframalpha": true,
  },
  "social media": {
    "digg": false,
    "qwant social": true,
    "reddit": true,
    "twitter": true,
    "voat": true,
  },
  "videos": {
    "bing videos": true,
    "ccc-tv": false,
    "digbt": false,
    "google videos": false,
    "google play movies": false,
    "ina": false,
    "kickass": false,
    "nyaa": false,
    "acgsou": false,
    "piratebay": false,
    "tokyotoshokan": false,
    "torrentz": false,
    "youtube": true,
    "dailymotion": true,
    "vimeo": true,
    "1337x": true,
  }
};
const Map<String, IconData> CATEGORY_LIST = {
  "general": Icons.category,
  "science": Icons.explore,
  "it": Icons.computer,
  "videos": Icons.videocam,
  "images": Icons.image,
  "files": Icons.folder,
  "music": Icons.music_note,
  "news": Icons.live_tv,
  "map": Icons.map,
  "social media": Icons.person,
};

Map<String, String> CATEGORY_NAMES(context) => {
  "general": S.of(context).category_general,
  "science": S.of(context).category_science,
  "it": S.of(context).category_it,
  "videos": S.of(context).category_videos,
  "images": S.of(context).category_images,
  "files": S.of(context).category_files,
  "music": S.of(context).category_music,
  "news": S.of(context).category_news,
  "map": S.of(context).category_map,
  "social media": S.of(context).category_social_media,
};

const String GOOGLE_AUTOCOMPLETE_URL =
    "https://suggestqueries.google.com/complete/search?client=toolbar&q=";

int selectedTimeRange = 0;
String selectedCategory = CATEGORY_LIST.keys.first;
String searxURL = "https://searx.site";
List<String> suggestions = new List();

Map<String, bool> get engines => currentEngines;

class Searx {
  String get searchUrl {
    String link = searxURL + "/search";
    return link;
  }

  String get formattedEngines {
    List<String> selectedEngines = new List();
    engines.forEach((String engine, bool isSelected) {
      if (isSelected) selectedEngines.add(engine);
    });
    return selectedEngines.join(",");
  }

  String get disabledFormattedEngines {
    List<String> selectedEngines = new List();
    engines.forEach((String engine, bool isSelected) {
      if (!isSelected) selectedEngines.add(engine);
    });

    return selectedEngines.join(",");
  }

  String get formattedCategories {
    return selectedCategory;
  }

  void updateEngine(bool state, String engine) {
    engines.update(engine, (bool a) => state);
  }

  bool getState(String engine) {
    return engines[engine];
  }

  static const List<String> TIME_RANGES = [
    "",
    "day",
    "week",
    "month",
    "year",
  ];

  static List<String> TIME_RANGE_NAMES(context) => [
    S.of(context).time_any,
    S.of(context).time_day,
    S.of(context).time_week,
    S.of(context).time_month,
    S.of(context).time_year,
  ];

  Future<List<SearchResult>> getSearchResults(String query, int page) async {
    Map<String, dynamic> body = {
      "format": "json",
      "q": query,
      "pageno": (page + 1).toString(),
      "categories": formattedCategories,
      //"enabled_engines": formattedEngines,
      //"disabled_engines": disabledFormattedEngines,
      "engines": formattedEngines,
      "time_range": TIME_RANGES[selectedTimeRange],
    };
    List<SearchResult> results = new List();
    var jsonResponse;
    http.Response response = await http.post(searchUrl, body: body);
    try {
      jsonResponse = json.decode(response.body);
    } catch (error) {
      print(error);
      Fluttertoast.showToast(
          msg: "error: " + response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    try {
      var jsonResults = jsonResponse["results"];

      for (var jsonResults in jsonResults) {
        String url = jsonResults["url"];
        String purl = jsonResults["pretty_url"];
        String title = jsonResults["title"];
        String description = jsonResults["content"];
        String engine = jsonResults["engine"];
        int leech = jsonResults["leech"] != null
            ? int.parse(jsonResults["leech"].toString())
            : null;
        int seed = jsonResults["seed"] != null
            ? int.parse(jsonResults["seed"].toString())
            : null;
        String magnet = jsonResults["magnetlink"];
        String thumb = jsonResults["thumbnail_src"];
        String img = jsonResults["img_src"];
        int filesize = jsonResults["filesize"];
        String date = jsonResults["publishedDate"];

        List<dynamic> enginesInDynamic = jsonResults["engines"];
        List<String> engines = new List();
        for (dynamic d in enginesInDynamic) engines.add(d as String);

        results.add(new SearchResult(url, purl, title, description,
            engine: engine,
            engines: engines,
            leech: leech,
            seed: seed,
            magnet: magnet,
            thumb: thumb,
            img: img,
            filesize: filesize,
            date: date));
      }
    } catch (error) {
      print(error);
    }

    return results;
  }

  void getAutoComplete(String term) async {
    http.Response response = await http.get(GOOGLE_AUTOCOMPLETE_URL + term);
    suggestions.clear();
    var document = xml.parse(response.body);
    List<xml.XmlElement> elements =
        document.findAllElements("suggestion").toList();
    for (xml.XmlElement element in elements) {
      int quateIndex = element.toString().indexOf("\"") + 1;
      suggestions.add(element
          .toString()
          .substring(quateIndex, element.toString().indexOf("\"", quateIndex)));
    }
  }
}
