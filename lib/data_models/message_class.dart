import 'package:audio_service/audio_service.dart';

class Message {
  int id = 0;
  int created = 0; // timestamp when message was added to cloud database
  String date = ''; // year when message was given
  String language = '';
  String location = '';
  String speaker = '';
  String speakerurl = '';
  String taglist = '';
  String title = '';
  String url = '';
  num durationinseconds = 0.0;
  int approximateminutes = 0;
  num lastplayedposition = 0.0;
  int lastplayeddate = 0;
  int iscurrentlydownloading = 0;
  int iscurrentlyplaying = 0;
  int isdownloaded = 0;
  int downloadedat = 0;
  String filepath = '';
  int isfavorite = 0;
  int isplayed = 0;

  Message(
    this.id,
    this.created,
    this.date,
    this.language,
    this.location,
    this.speaker,
    this.speakerurl,
    this.taglist,
    this.title,
    this.url,
    this.durationinseconds,
    this.approximateminutes,
    this.lastplayedposition,
    this.lastplayeddate,
    this.iscurrentlydownloading,
    this.iscurrentlyplaying,
    this.isdownloaded,
    this.downloadedat,
    this.filepath,
    this.isfavorite,
    this.isplayed,
  );

  // message id's are unique; two messages are identical if they have the same id
  @override
  bool operator ==(o) => o is Message && o.id == id;
  @override
  int get hashCode => id.hashCode;

  Message.fromCloudMap(Map<String, dynamic> map) {
    // used when pulling message data from cloud database

    id = map['id'] ?? 0;
    created = map['created'] ?? 0;
    date = map['date'] ?? '';
    language = map['language'] ?? '';
    location = map['location'] ?? '';
    speaker = map['speaker'] ?? '';
    speakerurl = map['speakerUrl'] ?? '';
    title = map['title'] ?? '';
    url = map['url'] ?? '';

    // convert List of tags into string
    taglist = '';
    if (map['tags'] != null && map['tags'].length > 0) {
      map['tags'].forEach((tag) => taglist += tag['display'] + ',');
    }
    
    if (taglist.length > 0) { // remove trailing comma from last step
      taglist = taglist.substring(0, taglist.length - 1);
    }

    // get possibly null data
    durationinseconds = map['durationinseconds'] ?? 0.0;
    //approximateminutes = map['approximateminutes'] ?? 0;
    if (map['duration'] == null) {
      approximateminutes = 0;
    } else { // expect duration to be of the form hh:mm:ss
      List<String> durationComponents = map['duration'].split(':');
      if (durationComponents.length < 3) {
        approximateminutes = 0;
      } else {
        int hours = int.parse(durationComponents[0]);
        int minutes = int.parse(durationComponents[1]);
        approximateminutes = 60*hours + minutes;
      }
    }
    lastplayedposition = map['lastplayedposition'] ?? 0.0;
    lastplayeddate = map['lastplayeddate'] ?? 0;
    iscurrentlydownloading = map['iscurrentlydownloading'] ?? 0;
    isdownloaded = map['isdownloaded'] ?? 0;
    downloadedat = map['downloadedat'] ?? 0;
    filepath = map['filepath'] ?? '';
    isfavorite = map['isfavorite'] ?? 0;
    isplayed = map['isplayed'] ?? 0;
  }

  Message.fromMap(Map<String, dynamic> map) {
    // used when pulling message data from local SQLite database

    id = map['id'] ?? 0;
    created = map['created'] ?? 0;
    date = map['date'] ?? '';
    language = map['language'] ?? '';
    location = map['location'] ?? '';
    speaker = map['speaker'] ?? '';
    speakerurl = map['speakerUrl'] ?? '';
    title = map['title'] ?? '';
    url = map['url'] ?? '';
    taglist = map['taglist'] ?? '';
    durationinseconds = map['durationinseconds'] ?? 0.0;
    approximateminutes = map['approximateminutes'] ?? 0;
    lastplayedposition = map['lastplayedposition'] ?? 0.0;
    lastplayeddate = map['lastplayeddate'] ?? 0;
    iscurrentlydownloading = map['iscurrentlydownloading'] ?? 0;
    isdownloaded = map['isdownloaded'] ?? 0;
    downloadedat = map['downloadedat'] ?? 0;
    filepath = map['filepath'] ?? '';
    isfavorite = map['isfavorite'] ?? 0;
    isplayed = map['isplayed'] ?? 0;
  }

  Map<String, dynamic> toMap() {
    // used when adding message data to local SQLite database
    return {
      'id': id,
      'created': created,
      'date': date,
      'language': language,
      'location': location,
      'speaker': speaker,
      'speakerurl': speakerurl,
      'taglist': taglist,
      'title': title,
      'url': url,
      'durationinseconds': durationinseconds,
      'approximateminutes': approximateminutes,
      'lastplayedposition': lastplayedposition,
      'lastplayeddate': lastplayeddate,
      'isdownloaded': isdownloaded,
      'iscurrentlydownloading': iscurrentlydownloading,
      'downloadedat': downloadedat,
      'filepath': filepath,
      'isfavorite': isfavorite,
      'isplayed': isplayed
    };
  }

  MediaItem toMediaItem(String dir) {
    num seconds = durationinseconds;
    int milliseconds = (seconds * 1000).round();
    Map<String, dynamic> _extras = toMap();

    // for iOS: application directory changes with app update
    String fileLocation = '$dir/${id.toString()}.mp3';

    return MediaItem(
      id: fileLocation,
      title: title,
      duration: Duration(milliseconds: milliseconds),
      artist: speaker,
      album: speaker,
      extras: _extras,
    );
  }

  String toString() {
    return '$title, by $speaker';
  }
}

Message? messageFromMediaItem(MediaItem? mediaItem) {
  if (mediaItem == null || mediaItem.extras == null) {
    return null;
  }
  Message result = Message.fromMap(mediaItem.extras!);
  return result;
}