import 'package:scoped_model/scoped_model.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/database/local_db.dart';
//import 'package:voices_for_christ/helpers/constants.dart' as Constants;

mixin FavoritesModel on Model {
  final db = MessageDB.instance;
  int _totalFavoritesCount = 0;
  int _playedFavoritesCount = 0;
  List<Message> _favorites = [];
  List<Message> _unplayedFavorites = [];
  List<Message> _playedFavorites = [];
  bool _favoritesLoading = false;
  //int _currentlyLoadedFavoritesCount = 0;
  //int _favoritesLoadingBatchSize = Constants.MESSAGE_LOADING_BATCH_SIZE;
  bool _reachedEndOfFavoritesList = false;

  int get totalFavoritesCount => _totalFavoritesCount;
  int get playedFavoritesCount => _playedFavoritesCount;
  List<Message> get favorites => _favorites;
  List<Message> get unplayedFavorites => _unplayedFavorites;
  List<Message> get playedFavorites => _playedFavorites;
  bool get favoritesLoading => _favoritesLoading;
  bool get reachedEndOFavoritesList => _reachedEndOfFavoritesList;

  Future<void> loadFavoritesFromDB() async {
    _favoritesLoading = true;
    notifyListeners();

    List<int> count = await db.getFavoritesCount(); // [total, played]
    _totalFavoritesCount = count[0];
    _playedFavoritesCount = count[1];

    /*List<Message> result = await db.queryFavorites(
      start: _currentlyLoadedFavoritesCount,
      end: _currentlyLoadedFavoritesCount + _favoritesLoadingBatchSize,
      orderBy: 'speaker',
      ascending: true,
    );

    if (result.length < _favoritesLoadingBatchSize) {
      _reachedEndOfFavoritesList = true;
    }*/
    List<Message> result = await db.queryFavorites(
      orderBy: 'speaker',
      ascending: true,
    );
    _reachedEndOfFavoritesList = true;

    //_currentlyLoadedFavoritesCount += result.length;

    _favorites.addAll(result);
    // classify played and unplayed downloads
    List<Message> playedResult = result.where((m) => m.isplayed == 1).toList();
    List<Message> unplayedResult = result.where((m) => m.isplayed != 1).toList();
    _playedFavorites.addAll(playedResult);
    _unplayedFavorites.addAll(unplayedResult);
    //_favorites = result;
    //_unplayedFavorites = result.where((f) => f.isplayed != 1).toList();
    //_playedFavorites = result.where((f) => f.isplayed == 1).toList();
    _favoritesLoading = false;
    notifyListeners();
  }

  /*void resetFavoriteSearchParameters() {
    _favorites = [];
    _unplayedFavorites = [];
    _playedFavorites = [];
    _favoritesLoading = false;
    _currentlyLoadedFavoritesCount = 0;
    _reachedEndOfFavoritesList = false;
    notifyListeners();
  }*/

  void addMessageToFavoriteList(Message message) {
    // don't add if it's already in the list
    if (_favorites.indexWhere((m) => m.id == message.id) > -1) {
      return;
    }
    _favorites.add(message);
    _totalFavoritesCount += 1;
    if (message.isplayed == 1) {
      _playedFavorites.add(message);
      _playedFavoritesCount += 1;
    } else {
      unplayedFavorites.add(message);
    }
    notifyListeners();
  }

  void removeMessageFromFavoriteList(Message message) {
    // don't remove if it's already not in the list
    if (_favorites.indexWhere((m) => m.id == message.id) < 0) {
      return;
    }
    _favorites.removeWhere((m) => m.id == message.id);
    _totalFavoritesCount -= 1;
    if (message.isplayed == 1) {
      _playedFavorites.removeWhere((m) => m.id == message.id);
      _playedFavoritesCount -= 1;
    } else {
      unplayedFavorites.removeWhere((m) => m.id == message.id);
    }
    notifyListeners();
  }

  void updateFavoritedMessage(Message message) {
    int indexInFavorites = _favorites.indexWhere((m) => m.id == message.id);
    if (indexInFavorites > -1) {
      bool shouldBePlayed = message.isplayed == 1;
      int indexInPlayedFavorites = _playedFavorites.indexWhere((m) => m.id == message.id);
      int indexInUnplayedFavorites = _unplayedFavorites.indexWhere((m) => m.id == message.id);
      if (indexInPlayedFavorites > -1) {
        if (shouldBePlayed) {
          _playedFavorites[indexInPlayedFavorites] = message;
        } else {
          _playedFavorites.removeAt(indexInPlayedFavorites);
          _playedFavoritesCount -= 1;
          _unplayedFavorites.add(message);
        }
      } else if (indexInUnplayedFavorites > -1) {
        if (shouldBePlayed) {
          _unplayedFavorites.removeAt(indexInUnplayedFavorites);
          _playedFavorites.add(message);
          _playedFavoritesCount += 1;
        } else {
          _unplayedFavorites[indexInUnplayedFavorites] = message;
        }
      }
      /*bool wasPreviouslyPlayed = _favorites[indexInFavorites].isplayed == 1;
      _favorites[indexInFavorites] = message;

      // classify updated download as played or unplayed;
      if (wasPreviouslyPlayed) {
        int indexInPlayedFavorites = _playedFavorites.indexWhere((m) => m.id == message.id);
        print('TEST 3b: $indexInPlayedFavorites');
        if (message.isplayed == 1) {
          if (indexInPlayedFavorites > -1) {
            _playedFavorites[indexInPlayedFavorites] = message;
          }
        } else {
          if (indexInPlayedFavorites > -1) {
            _playedFavorites.removeAt(indexInPlayedFavorites);
          }
          _unplayedFavorites.add(message);
        }
      } else {
        int indexInUnplayedFavorites = _unplayedFavorites.indexWhere((m) => m.id == message.id);
        print('TEST 3c: $indexInUnplayedFavorites');
        if (message.isplayed == 1) {
          if (indexInUnplayedFavorites > -1) {
            _unplayedFavorites.removeAt(indexInUnplayedFavorites);
          }
          _playedFavorites.add(message);
        } else {
          if (indexInUnplayedFavorites > -1) {
            _unplayedFavorites[indexInUnplayedFavorites] = message;
          }
        }
      }*/
    }
    notifyListeners();
  }

  void sortFavorites({String orderBy = '', bool ascending = true}) {
    switch (orderBy.toLowerCase()) {
      case 'speaker':
        ascending
          ? _favorites.sort((a,b) => a.speaker.compareTo(b.speaker))
          : _favorites.sort((a,b) => -a.speaker.compareTo(b.speaker));
        break;
      case 'title':
        ascending
          ? _favorites.sort((a,b) => a.title.compareTo(b.title))
          : _favorites.sort((a,b) => -a.title.compareTo(b.title));
        break;
    }
    if (['speaker', 'title'].contains(orderBy.toLowerCase())) {
      _playedFavorites = _favorites.where((m) => m.isplayed == 1).toList();
      _unplayedFavorites = _favorites.where((m) => m.isplayed != 1).toList();
    }
    notifyListeners();
  }

  Future<void> handleFavoriteToggling(Message message) async {
    await db.toggleFavorite(message);
    //await loadFavorites();
    if (message.isfavorite == 1) {
      addMessageToFavoriteList(message);
    } else {
      removeMessageFromFavoriteList(message);
    }
  }

  Future<void> setMultipleFavorites(List<Message> messages, int value) async {
    for (int i = 0; i < messages.length; i++) {
      messages[i].isfavorite = value;
      if (value == 1) {
        addMessageToFavoriteList(messages[i]);
      } else {
        removeMessageFromFavoriteList(messages[i]);
      }
      //await db.update(messages[i]);
    }
    await db.batchAddToDB(messages);
    //await loadFavorites();
  }
}