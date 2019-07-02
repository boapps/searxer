class SearchResult {
  SearchResult(this.url, this.purl, this.title, this.description,
      {this.engine,
      this.engines,
      this.leech,
      this.seed,
      this.magnet,
      this.thumb,
      this.img,
      this.date,
      this.filesize});

  String url;
  String purl; //pretty url
  String title;
  String description;
  String engine;
  String magnet; //magnet link for torrents
  String thumb; //link to thumbnail
  String img; //link to image
  List<String> engines;
  int leech; //for torrents
  int seed; //for torrents
  String date;
  int filesize;
}
