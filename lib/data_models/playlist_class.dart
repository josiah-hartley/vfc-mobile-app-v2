import 'package:audio_service/audio_service.dart';
import 'package:voices_for_christ/data_models/message_class.dart';

class Playlist {
  int id = -1;
  int created = -1; // timestamp when playlist was created
  String title = '';
  List<Message> messages = [];

  Playlist({
    required this.id,
    this.created = -1,
    this.title = '',
    required this.messages,
});

  Playlist.fromMap(Map<String, dynamic> map) {
    // used when getting playlist data from database
    id = map['id'];
    created = map['created'];
    title = map['title'];
    messages = []; // fill in from separate database call
  }

  Map<String, dynamic> toMap() {
    // used when adding message data to local SQLite database
    return {
      'created': created,
      'title': title
    };
  }

  List<MediaItem> toMediaItemList(String dir) {
    return messages.map((msg) => msg.toMediaItem(dir)).toList();
  }

  String toString() {
    return title;
  }
}

/*Future<Playlist> playlistFromMediaItemList(List<MediaItem> itemList) async {
  List<Message> messages = [];
  for (int i = 0; i < itemList.length; i++) {
    Message message = await messageFromMediaItem(itemList[i]);
    messages.add(message);
  }
  return Playlist(-1, 0, 'Temp', messages);
}*/