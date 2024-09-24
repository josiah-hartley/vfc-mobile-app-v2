import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voices_for_christ/helpers/constants.dart' as Constants;
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/database/local_db.dart';
import 'package:voices_for_christ/helpers/minimize_keyboard.dart';
import 'package:voices_for_christ/widgets/buttons/action_button.dart';
import 'package:voices_for_christ/widgets/search/search_input.dart';
import 'package:voices_for_christ/widgets/search/search_results.dart';
import 'package:voices_for_christ/helpers/logger.dart' as Logger;

class SearchWindow extends StatefulWidget {
  SearchWindow({Key? key, this.focusNodeTopic, this.focusNodeSpeaker, required this.closeWindow/*, required this.navigateToSpeakerPage*/}) : super(key: key);
  final FocusNode? focusNodeTopic;
  final FocusNode? focusNodeSpeaker;
  final void Function() closeWindow;
  //final void Function() navigateToSpeakerPage;

  @override
  _SearchWindowState createState() => _SearchWindowState();
}

class _SearchWindowState extends State<SearchWindow> {
  final TextEditingController _searchControllerTopic = TextEditingController();
  final TextEditingController _searchControllerSpeaker = TextEditingController();
  final db = MessageDB.instance;
  List<Message> _searchResults = [];
  int _fullSearchResultCount = 0;
  int _currentlyLoadedMessageCount = 0;
  int _messageLoadingBatchSize = Constants.MESSAGE_LOADING_BATCH_SIZE;
  bool _hasSearched = false;
  bool _reachedEndOfList = false;
  bool _waitingForResults = false;
  bool _runningSearch = false;
  final TextEditingController _minLengthTextController = TextEditingController();
  final TextEditingController _maxLengthTextController = TextEditingController();

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          _searchTitle(context: context, closeWindow: widget.closeWindow),
          searchInput(
            context: context,
            condensed: _hasSearched,
            focusNodeTopic: widget.focusNodeTopic,
            focusNodeSpeaker: widget.focusNodeSpeaker,
            topicSearchController: _searchControllerTopic,
            speakerSearchController: _searchControllerSpeaker,
            onChanged: (String searchString) { setState(() {}); },
            onSearch: () {
              _onSearch(context);
            },
            onReset: () {
              _resetSearchParameters();
              _clearSearch();
            },
            onClearSearchStringTopic: () {
              setState(() {
                _searchControllerTopic.text = '';
                //_hasSearched = false;
                //_resetSearchParameters();
              });
            },
            onClearSearchStringSpeaker: () {
              setState(() {
                _searchControllerSpeaker.text = '';
                //_hasSearched = false;
                //_resetSearchParameters();
              });
            },
            minLengthTextController: _minLengthTextController,
            maxLengthTextController: _maxLengthTextController,
          ),
          _hasSearched ? SearchResultsDisplay(
            searchResults: _searchResults,
            fullSearchCount: _fullSearchResultCount,
            batchSize: _messageLoadingBatchSize,
            loadMoreResults: _search,
            reachedEndOfList: _reachedEndOfList,
          ) : Container(),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
      ),
    );
  }

  Widget _searchTitle({required BuildContext context, void Function()? closeWindow}) {
      return Container(
        padding:EdgeInsets.symmetric(horizontal: 15.0),
        child: Container(
          padding: EdgeInsets.only(top: 30.0, right: 10.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).hintColor.withOpacity(0.6),
                width: 1.0,
              )
            )
          ),
          child: Row(
            children: [
              Container(
                child: IconButton(
                  icon: Icon(CupertinoIcons.back),
                  iconSize: 34.0,
                  color: Theme.of(context).hintColor,
                  onPressed: closeWindow,
                ),
              ),
              Expanded(
                child: Container(
                  child: Text('Message Search'.toUpperCase(),
                    style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      );
    }

  void _onSearch(BuildContext context) async {
    await _initializeNewSearch(context);
  }

  Future<void> _initializeNewSearch(BuildContext context) async {
    minimizeKeyboard(context);
      if (_waitingForResults) {
      return;
    }
    // lock the search so that two searches won't happen simultaneously
    _waitingForResults = true;

    try {
      _resetSearchParameters();

      // get advanced search options
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool _mustContainAll = prefs.getBool('searchMustContainAllKeywords') ?? true;
      bool _onlyUnplayed = prefs.getBool('onlySearchUnplayed') ?? false;
      bool _onlyFavorite = prefs.getBool('onlySearchFavorites') ?? false;
      bool _onlyDownloaded = prefs.getBool('onlySearchDownloaded') ?? false;
      int _minLengthInMinutes = int.tryParse(_minLengthTextController.text.replaceAll(RegExp('[^0-9.]'), '').split('.')[0]) ?? -1;
      int _maxLengthInMinutes = int.tryParse(_maxLengthTextController.text.replaceAll(RegExp('[^0-9.]'), '').split('.')[0]) ?? -1;

      // TODO: test searching thoroughly!!!
      int _count = await db.advancedSearchCount(
        topicSearchTerm: _searchControllerTopic.text,
        speakerSearchTerm: _searchControllerSpeaker.text,
        mustContainAll: _mustContainAll,
        minLengthInMinutes: _minLengthInMinutes,
        maxLengthInMinutes: _maxLengthInMinutes,
        onlyDownloaded: _onlyDownloaded,
        onlyFavorites: _onlyFavorite,
        onlyUnplayed: _onlyUnplayed,
      );
      setState(() {
        _fullSearchResultCount = _count;
      });

      await _search(
        mustContainAll: _mustContainAll,
        minLengthInMinutes: _minLengthInMinutes,
        maxLengthInMinutes: _maxLengthInMinutes,
        onlyDownloaded: _onlyDownloaded,
        onlyFavorite: _onlyFavorite,
        onlyUnplayed: _onlyUnplayed,
      );
      showMultiSelectTip(context);
    } catch(e) {
      print(e);
    }
    // unlock search
    _waitingForResults = false;
  }

  void _resetSearchParameters() {
    setState(() {
      _searchResults = [];
      _currentlyLoadedMessageCount = 0;
      _reachedEndOfList = false;
      _fullSearchResultCount = 0;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchControllerTopic.text = '';
      _searchControllerSpeaker.text = '';
      _minLengthTextController.text = '';
      _maxLengthTextController.text = '';
      _hasSearched = false;
    });
  }

  Future<void> _search({
    bool? mustContainAll,
    int? minLengthInMinutes,
    int? maxLengthInMinutes,
    bool? onlyDownloaded,
    bool? onlyFavorite,
    bool? onlyUnplayed,
  }) async {
    if (_runningSearch) {
      return;
    }
    // lock the search so that two searches won't happen simultaneously
    _runningSearch = true;
    List<Message> result = [];

    // TODO: come back to this
    result = await db.advancedSearch(
      topicSearchTerm: _searchControllerTopic.text,
      speakerSearchTerm: _searchControllerSpeaker.text,
      mustContainAll: mustContainAll ?? true,
      minLengthInMinutes: minLengthInMinutes,
      maxLengthInMinutes: maxLengthInMinutes,
      onlyUnplayed: onlyUnplayed ?? false,
      onlyFavorites: onlyFavorite ?? false,
      onlyDownloaded: onlyDownloaded ?? false,
      start: _currentlyLoadedMessageCount, 
      end: _currentlyLoadedMessageCount + _messageLoadingBatchSize
    );

    if (result.length < _messageLoadingBatchSize) {
        _reachedEndOfList = true;
      }
      _currentlyLoadedMessageCount += result.length;
      setState(() {
        _hasSearched = true;
      });
      Logger.logEvent(event: 'Searching for topic: ${_searchControllerTopic.text} and speaker: ${_searchControllerSpeaker.text}; total number of results is $_fullSearchResultCount; currently loaded results: $_currentlyLoadedMessageCount; reached end of list is $_reachedEndOfList');
    /*if (_searchController.text != '') {
      //addToHistory(_searchController.text);
      result = await db.searchBySpeakerOrTitle(
        searchTerm: _searchController.text, 
        mustContainAll: false,
        start: _currentlyLoadedMessageCount, 
        end: _currentlyLoadedMessageCount + _messageLoadingBatchSize
      );

      if (result.length < _messageLoadingBatchSize) {
        _reachedEndOfList = true;
      }
      _currentlyLoadedMessageCount += result.length;
      setState(() {
        _hasSearched = true;
      });
      Logger.logEvent(event: 'Searching for ${_searchController.text}; total number of results is $_fullSearchResultCount; currently loaded results: $_currentlyLoadedMessageCount; reached end of list is $_reachedEndOfList');
    }*/
    setState(() {
      _searchResults.addAll(result);
    });

    // unlock search
    _runningSearch = false;
  }

  void showMultiSelectTip(BuildContext context) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool alreadyShownTip = _prefs.getBool('shownMultiSelectTip') ?? false;
    if (!alreadyShownTip) {
      _prefs.setBool('shownMultiSelectTip', true);
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text('Tip',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text('Tap on a message listing to see more actions.',
                style: TextStyle(fontSize: 16.0, color: Theme.of(context).hintColor),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text('You can select multiple messages by long pressing the message listings or by tapping the circles with the speakers\' initials.',
                style: TextStyle(fontSize: 16.0, color: Theme.of(context).hintColor),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              alignment: Alignment.centerRight,
              child: ActionButton(
                text: 'Got it',
                onPressed: () { Navigator.of(context).pop(); },
              ),
            ),
          ],
        ),
      );
    }
  }
}