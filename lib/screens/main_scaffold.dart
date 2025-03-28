import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:voices_for_christ/helpers/constants.dart' as Constants;
import 'package:scoped_model/scoped_model.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:voices_for_christ/helpers/minimize_keyboard.dart';
import 'package:voices_for_christ/scoped_models/main_model.dart';
import 'package:voices_for_christ/screens/settings.dart';
import 'package:voices_for_christ/widgets/player/player_panel_collapsed.dart';
import 'package:voices_for_christ/widgets/player/player_panel_expanded.dart';
import 'package:voices_for_christ/screens/search.dart';
import 'package:voices_for_christ/screens/home.dart';
import 'package:voices_for_christ/screens/favorites.dart';
import 'package:voices_for_christ/screens/playlists.dart';
import 'package:voices_for_christ/screens/downloads.dart';

class MainScaffold extends StatefulWidget {
  MainScaffold({Key? key, this.debugMessage}) : super(key: key);
  final String? debugMessage;

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  List<String> _routeNames = ['Home', 'Downloads', 'Playlists', 'Favorites'];//, 'Speakers'];
  List<int> _pageRoutes = [0];
  String _currentRouteName = 'Home';
  bool _searchWindowOpen = false;
  final PanelController _playerPanelController = PanelController();
  bool _playerPanelOpen = false;
  FocusNode? _searchFocusNodeTopic;
  FocusNode? _searchFocusNodeSpeaker;

  @override
  void initState() { 
    super.initState();
    _searchFocusNodeTopic = FocusNode();
    _searchFocusNodeSpeaker = FocusNode();
  }

  @override
  void dispose() { 
    _searchFocusNodeTopic?.dispose();
    _searchFocusNodeSpeaker?.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    // if already on this page, don't navigate
    if (index == _pageRoutes.last) {
      return;
    }

    switch (index) {
      case 0:
        _navigatorKey.currentState?.pushNamed('/');
        break;
      case 1:
        _navigatorKey.currentState?.pushNamed('/downloads');
        break;
      case 2:
        _navigatorKey.currentState?.pushNamed('/playlists');
        break;
      case 3:
        _navigatorKey.currentState?.pushNamed('/favorites');
        break;
      //case 4:
      //  _navigatorKey.currentState?.pushNamed('/speakers');
      //  break;
      default:
        _navigatorKey.currentState?.pushNamed('/');
    }

    setState(() {
      _pageRoutes.add(index);
      _currentRouteName = _routeNames[index];
    });
  }

  Future<bool> _handleBackButton() {
    // close window drawer if it's open
    if (_searchWindowOpen) {
      _closeSearchDrawer();
      return Future.value(false);
    }
    // close player panel if it's open
    if (_playerPanelOpen) {
      _togglePlayerPanel();
      return Future.value(false);
    }
    // otherwise, navigate back to last route
    if(_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState?.pop();
      setState(() {
        _pageRoutes.removeLast();
        // update page header
        _currentRouteName = _routeNames[_pageRoutes.last]; //?? '';
      });
      return Future.value(false);
    }
    // if the navigator stack is empty, close the application
    return Future.value(true);
  }

  void _openSearchDrawer() {
    setState(() {
      _searchWindowOpen = true;
    });
  }

  void _closeSearchDrawer() {
    setState(() {
      _searchWindowOpen = false;
    });
    minimizeKeyboard(context);
  }

  /*void _navigateToSpeakerPage() {
    // move to Speakers tab
    _navigateToPage(4);
    // close search panel
    _closeSearchDrawer();
  }*/

  PreferredSizeWidget _appBar(void Function()? _openSearchDrawer) {
    return AppBar(
      title: Text(_currentRouteName.toUpperCase(),
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xff002D47),
      ),
      actions: [
        IconButton(
          icon: Icon(CupertinoIcons.gear_alt, size: 24.0), 
          onPressed: () {
            showDialog(
              context: context, 
              builder: (context) => SettingsPage()
            );
          }
        ),
        IconButton(
          icon: Icon(CupertinoIcons.search, size: 24.0),
          onPressed: _openSearchDrawer
        ),
      ],
    );
  }

  Widget _mainPageSlidingPanelWrapper(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        double maxHeight = (model.currentlyPlayingMessage == null || !model.playerVisible) ? 0.0 : MediaQuery.of(context).size.height - kBottomNavigationBarHeight - Constants.EXPANDED_PLAYBAR_TOP_PADDING;
        if (maxHeight > Constants.MAX_EXPANDED_PLAYBAR_HEIGHT) {
          maxHeight = Constants.MAX_EXPANDED_PLAYBAR_HEIGHT;
        }
        return Container(
          child: SlidingUpPanel(
            controller: _playerPanelController,
            minHeight: (model.currentlyPlayingMessage == null || !model.playerVisible) ? 0.0 : Constants.COLLAPSED_PLAYBAR_HEIGHT,
            maxHeight: maxHeight,
            backdropEnabled: false,
            backdropTapClosesPanel: false,
            collapsed: PlayerPanelCollapsed(panelOpen: _playerPanelOpen, togglePanel: _togglePlayerPanel),
            panel: PlayerPanelExpanded(panelOpen: _playerPanelOpen, togglePanel: _togglePlayerPanel),
            //panel: _playerPanelController.isPanelOpen ? PlayerPanelExpanded(togglePanel: _togglePlayerPanel) : PlayerPanelCollapsed(togglePanel: _togglePlayerPanel),
            body: _mainPageBody(context, model),
            onPanelOpened: () {
              setState(() { _playerPanelOpen = true; });
            },
            onPanelClosed: () {
              setState(() { _playerPanelOpen = false; });
            },
          ),
        );
      }
    );
  }

  void _togglePlayerPanel() {
    if (_playerPanelController.isPanelOpen) {
      _playerPanelController.close();
      setState(() { _playerPanelOpen = false; });
    } else {
      _playerPanelController.open();
      setState(() { _playerPanelOpen = true; });
    }
  }

  Widget _mainPageBody(BuildContext context, MainModel model) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          child: Container(
            child: Navigator(
              key: _navigatorKey,
              initialRoute: '/',
              onGenerateRoute: (settings) {
                return _onGenerateRoute(settings, model);
              },
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).hintColor.withOpacity(0.6),
                  width: 1.0,
                )
              )
            ),
          ),
          padding: EdgeInsets.only(
            //top: 0.0,
            top: Scaffold.of(context).appBarMaxHeight ?? 75.0, // default supposedly 56
            left: 15.0,
            right: 15.0
          ),
          decoration: BoxDecoration(
            /*gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.65,
              colors: [
                Theme.of(context).dialogBackgroundColor, 
                Theme.of(context).canvasColor,
              ]
            )*/
            color: Theme.of(context).canvasColor,
          ),
        );
      }
    );
  }

  Widget _mainScaffold() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: _appBar(_openSearchDrawer),
      body: _mainPageSlidingPanelWrapper(context),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      elevation: 6.0,
      items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.house_fill, size: 20.0),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download_sharp, size: 26.0),
          label: 'Downloads',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.playlist_play, size: 28.0),
          label: 'Playlists',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.star_fill, size: 20.0),
          label: 'Favorites',
        ),
        /*BottomNavigationBarItem(
          //icon: Icon(Icons.group, size: 28.0),
          //icon: Icon(CupertinoIcons.music_mic, size: 28.0),
          //icon: Icon(Icons.recent_actors, size: 28.0),
          //icon: Icon(Icons.spatial_audio_off, size: 28.0),
          //icon: Icon(Icons.people, size: 28.0),
          icon: Icon(Icons.record_voice_over, size: 26.0),
          label: 'Speakers',
        ),*/
      ],
      //currentIndex: _pageRoutes.last < 5 ? _pageRoutes.last : 0,
      currentIndex: _pageRoutes.last < 4 ? _pageRoutes.last : 0,
      onTap: _navigateToPage,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
    );
  }

  Widget _searchDrawer() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      top: 0.0,
      left: _searchWindowOpen ? 0.0 : MediaQuery.of(context).size.width,
      child: Scaffold(
        body: SearchWindow(
          focusNodeTopic: _searchFocusNodeTopic,
          focusNodeSpeaker: _searchFocusNodeSpeaker,
          closeWindow: _closeSearchDrawer,
          //navigateToSpeakerPage: _navigateToSpeakerPage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // handle back button on Android
      onWillPop: _handleBackButton,
      child: Container(
        child: Stack(
          children: [
            _mainScaffold(),
            _searchDrawer(),
          ],
        ),
      ),
    );
  }

  Route _onGenerateRoute(RouteSettings settings, MainModel model) {
    Widget page;
    switch (settings.name) {
      case '/':
        page = HomePage(debugMessage: widget.debugMessage);
        break;
      case '/favorites':
        page = FavoritesPage();
        break;
      case '/playlists':
        page = PlaylistsPage();
        break;
      case '/downloads':
        page = DownloadsPage();
        break;
      /*case '/speakers':
        page = SpeakersPage();
        break;*/
      default:
        page = HomePage();
    }
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => page,
      transitionDuration: Duration(seconds: 0),
    );
  }
}