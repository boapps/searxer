library searxer.Searx;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:searxer/SearchResult.dart';
import 'package:xml/xml.dart' as xml;

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
const String GOOGLE_AUTOCOMPLETE_URL =
    "https://suggestqueries.google.com/complete/search?client=toolbar&q=";

int selectedTimeRange = 0;
String selectedCategory = CATEGORY_LIST.keys.first;
String searxURL = "https://searx.site";
List<String> suggestions = new List();

Map<String, bool> categories = {
  "general": true,
  "science": false,
  "it": false,
  "videos": false,
  "images": false,
  "files": false,
  "music": false,
  "news": false,
  "map": false,
  "social media": false,
};

Map<String, bool> engines = {
  "1337x": false,
  "acgsou": false,
  "apkmirror": false,
  "archlinux": false,
  "arxiv": false,
  "bing_images": false,
  "bing_news": false,
  "bing": false,
  "bing_videos": false,
  "btdigg": false,
  "currency_convert": false,
  "dailymotion": false,
  "deezer": false,
  "deviantart": false,
  "dictzone": false,
  "digbt": false,
  "digg": false,
  "doku": false,
  "duckduckgo_definitions": false,
  "duckduckgo_images": false,
  "duckduckgo": false,
  "duden": false,
  "dummy": false,
  "faroo": false,
  "fdroid": false,
  "filecrop": false,
  "flickr_noapi": false,
  "flickr": false,
  "framalibre": false,
  "frinkiac": false,
  "genius": false,
  "gentoo": false,
  "gigablast": false,
  "github": false,
  "google_images": false,
  "google_news": false,
  "google": false,
  "google_videos": false,
  "ina": false,
  "json_engine": false,
  "kickass": false,
  "mediawiki": false,
  "microsoft_academic": false,
  "mixcloud": false,
  "nyaa": false,
  "openstreetmap": false,
  "pdbe": false,
  "photon": false,
  "piratebay": false,
  "pubmed": false,
  "qwant": false,
  "reddit": false,
  "scanr_structures": false,
  "searchcode_code": false,
  "searchcode_doc": false,
  "searx_engine": false,
  "soundcloud": false,
  "spotify": false,
  "stackoverflow": false,
  "startpage": false,
  "tokyotoshokan": false,
  "torrentz": false,
  "translated": false,
  "twitter": false,
  "unsplash": false,
  "vimeo": false,
  "wikidata": false,
  "wikipedia": false,
  "wolframalpha_api": false,
  "wolframalpha_noapi": false,
  "www1x": false,
  "xpath": false,
  "yacy": false,
  "yahoo_news": false,
  "yahoo": false,
  "yandex": false,
  "youtube_api": false,
  "youtube_noapi": false,
};

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

  static const List<String> TIME_RANGE_NAMES = [
    "Any",
    "Day",
    "Week",
    "Month",
    "Year",
  ];

  Future<List<SearchResult>> getSearchResults(String query, int page) async {
    List<SearchResult> results = new List();
    var jsonResponse;
    http.Response response = await http.post(
      searchUrl,
      body: {
        "format": "json",
        "q": query,
        "pageno": (page + 1).toString(),
        "categories": formattedCategories,
        "enabled_engines": "",
        "disabled_engines": "",
        "engines": formattedEngines,
        "time_range": TIME_RANGES[selectedTimeRange],
      },
    );
    try {
      jsonResponse = json.decode(response.body);
    } catch (e) {
      print(e);
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
