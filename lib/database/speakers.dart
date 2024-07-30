import 'package:sqflite/sqflite.dart';
import 'package:voices_for_christ/data_models/speaker_class.dart';
import 'package:voices_for_christ/database/table_names.dart';
//import 'package:voices_for_christ/helpers/constants.dart' as Constants;

Future<int> getSpeakerMessageCount({required Database db, required String speakerName}) async {
  /*try {
    // MAGIC NUMBER: the queue is a hidden playlist with id 0
    var result = await db.query(playlistTable, where: 'id != ?', whereArgs: [Constants.QUEUE_PLAYLIST_ID]);

    if (result.isNotEmpty) {
      List<Playlist> playlists = result.map((pMap) => Playlist.fromMap(pMap)).toList();
      return playlists;
    }
    return [];
  } catch (error) {
    print(error);
    return [];
  }*/
  return 0;
}