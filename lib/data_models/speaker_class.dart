class Speaker {
  String name = '';
  String url = '';
  String bio = '';
  int messageCount = 0;

  Speaker({
    required this.name,
    this.url = '',
    this.bio = '',
    this.messageCount = 0
  });

  Speaker.fromMap(Map<String, dynamic> map) {
    // used when getting playlist data from database
    name = map['name'] ?? '';
    url = map['url'] ?? '';
    bio = map['bio'] ?? '';
    messageCount = 0; // fill in from separate database call
  }

  Map<String, dynamic> toMap() {
    // used when adding message data to local SQLite database
    return {
      'name': name,
      'url': url,
      'bio': bio,
      'messageCount': messageCount
    };
  }

  String toString() {
    return name;
  }
}