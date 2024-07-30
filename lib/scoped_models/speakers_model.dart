import 'package:scoped_model/scoped_model.dart';
import 'package:voices_for_christ/data_models/speaker_class.dart';
import 'package:voices_for_christ/database/local_db.dart';
import 'package:voices_for_christ/helpers/constants.dart' as Constants;
//import 'package:voices_for_christ/helpers/logger.dart' as Logger;

mixin SpeakersModel on Model {
  final db = MessageDB.instance;
  List<Speaker> _speakers = [];
  Speaker? _selectedSpeaker;
  bool _reachedEndOfSpeakersList = false;
  int _speakersLoadingBatchSize = Constants.SPEAKER_LOADING_BATCH_SIZE;
  
  List<Speaker> get speakers => _speakers;
  Speaker? get selectedSpeaker => _selectedSpeaker;

  Future<void> loadMoreSpeakers() async {
    if (_reachedEndOfSpeakersList) {
      return;
    }

    int start = _speakers.length;
    int end = start + _speakersLoadingBatchSize;

    notifyListeners();
  }
}