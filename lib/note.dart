class Note {
  String key;

  Note(this.key);

  Note.fromJson(Map<String, dynamic> json) {
    key = json['result'];
  }
}
