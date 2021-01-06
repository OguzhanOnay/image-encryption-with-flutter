class Album {
  final String key;

  Album({this.key});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      key: json['key'],
    );
  }
}
