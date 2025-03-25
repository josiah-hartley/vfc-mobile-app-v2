import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voices_for_christ/helpers/logger.dart' as Logger;

class AdvancedSearchOptions extends StatefulWidget {
  AdvancedSearchOptions({Key? key, required this.minLengthTextController, required this.maxLengthTextController, this.onChanged}) : super(key: key);
  final TextEditingController minLengthTextController;
  final TextEditingController maxLengthTextController;
  void Function(String)? onChanged;

  @override
  State<AdvancedSearchOptions> createState() => _AdvancedSearchOptionsState();
}

class _AdvancedSearchOptionsState extends State<AdvancedSearchOptions> {
  SharedPreferences? prefs;
  bool _expanded = false;

  //TextEditingController _languageTextController = TextEditingController();
  //TextEditingController _locationTextController = TextEditingController();

  bool _mustContainAll = true;
  bool _onlyUnplayed = false;
  bool _onlyFavorite = false;
  bool _onlyDownloaded = false;
  //int? _minLengthInMinutes;
  //int? _maxLengthInMinutes;
  //String _language = '';
  //String _location = '';

  @override
  void initState() { 
    super.initState();
    _loadSearchPreferences();
  }

  void _loadSearchPreferences() async {
    Logger.logEvent(event: 'Initializing: in _loadSearchPreferences(), starting to load preferences');
    try {
      prefs = await SharedPreferences.getInstance();
      _mustContainAll = prefs?.getBool('searchMustContainAllKeywords') ?? true;
      _onlyUnplayed = prefs?.getBool('onlySearchUnplayed') ?? false;
      _onlyFavorite = prefs?.getBool('onlySearchFavorites') ?? false;
      _onlyDownloaded = prefs?.getBool('onlySearchDownloaded') ?? false;
    } catch(e) {
      await Logger.logEvent(type: 'error', event: 'Error loading advanced search preferences: $e');
    }
  }

  void _toggleContainAll() async {
    setState(() {
      _mustContainAll = !_mustContainAll;
    });
    try {
      prefs = await SharedPreferences.getInstance();
      prefs?.setBool('searchMustContainAllKeywords', _mustContainAll);
    } catch(e) {
      await Logger.logEvent(type: 'error', event: 'Error setting advanced search preferences: $e');
    }
  }

  void _toggleOnlyUnplayed() async {
    setState(() {
      _onlyUnplayed = !_onlyUnplayed;
    });
    try {
      prefs = await SharedPreferences.getInstance();
      prefs?.setBool('onlySearchUnplayed', _onlyUnplayed);
    } catch(e) {
      await Logger.logEvent(type: 'error', event: 'Error setting advanced search preferences: $e');
    }
  }

  void _toggleOnlyFavorite() async {
    setState(() {
      _onlyFavorite = !_onlyFavorite;
    });
    try {
      prefs = await SharedPreferences.getInstance();
      prefs?.setBool('onlySearchFavorites', _onlyFavorite);
    } catch(e) {
      await Logger.logEvent(type: 'error', event: 'Error setting advanced search preferences: $e');
    }
  }

  void _toggleOnlyDownloaded() async {
    setState(() {
      _onlyDownloaded = !_onlyDownloaded;
    });
    try {
      prefs = await SharedPreferences.getInstance();
      prefs?.setBool('onlySearchDownloaded', _onlyDownloaded);
    } catch(e) {
      await Logger.logEvent(type: 'error', event: 'Error setting advanced search preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        alignment: Alignment.center,
                        child: Text('Advanced Settings',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Theme.of(context).hintColor,
                          ),
                        )
                      ),
                    ),
                    Container(
                      child: _expanded
                      ? Icon(CupertinoIcons.arrowtriangle_up_circle,
                        color: Theme.of(context).hintColor,
                        size: 22.0,)
                      : Icon(CupertinoIcons.arrowtriangle_down_circle,
                        color: Theme.of(context).hintColor,
                        size: 22.0,),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _expanded
          ? _expandedOptions()
          : _collapsedOptions(),
        ],
      ),
    );
  }

  Widget _collapsedOptions() {
    // Remind user that some advanced settings are in effect
    if (_onlyUnplayed != true && _onlyFavorite != true && _onlyDownloaded != true) {
      return Container();
    }

    String message = 'Only searching for ';
    List<String> options = [];
    if (_onlyUnplayed == true) {
      options.add('unplayed');
    }
    if (_onlyFavorite == true) {
      options.add('favorite');
    }
    if (_onlyDownloaded == true) {
      options.add('downloaded');
    }
    message += options.join(', ') + ' messages';
    return Container(
      child: Text(message,
        style: Theme.of(context).primaryTextTheme.headlineMedium,
      ),
    );
  }

  Widget _expandedOptions() {
    return Container(
      child: Column(
        children: [
          _toggle(
            context: context,
            value: _mustContainAll,
            title: 'Contains all keywords',
            subtitle: _containsAllSubtitle(ctx: context, containsAll: _mustContainAll),
            toggle: _toggleContainAll,
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text("You can use quotation marks to search for exact matches",
              style: Theme.of(context).primaryTextTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
          ),
          _lengthConstraintWidget(),
          _toggle(
            context: context,
            value: _onlyUnplayed,
            title: 'Unplayed messages only',
            toggle: _toggleOnlyUnplayed,
          ),
          _toggle(
            context: context,
            value: _onlyFavorite,
            title: 'Favorited messages only',
            toggle: _toggleOnlyFavorite,
          ),
          _toggle(
            context: context,
            value: _onlyDownloaded,
            title: 'Downloaded messages only',
            toggle: _toggleOnlyDownloaded,
          ),
          _languageConstraintWidget(),
          _locationConstraintWidget(),
        ],
      ),
    );
  }

  Widget _toggle({required BuildContext context, required bool value, String? title, Widget? subtitle, required Function toggle}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title ?? '',
                  style: Theme.of(context).primaryTextTheme.displaySmall,
                ),
                subtitle == null
                  ? SizedBox(height: 0.0)
                  : Container(
                      padding: EdgeInsets.only(top: 5.0, right: 25.0),
                      child: subtitle,
                    ),
              ],
            ),
          ),
          Container(
            child: GestureDetector(
              child: Container(
                child: value == true
                      ? Icon(CupertinoIcons.checkmark_square_fill,
                          size: 32.0,
                          color: Theme.of(context).hintColor,
                        )
                      : Icon(CupertinoIcons.square,
                          size: 32.0,
                          color: Theme.of(context).hintColor,
                        ),
              ),
              onTap: () { toggle(); },
            ),
          ),
          /*Container(
            child: Switch(
              value: value,
              onChanged: (val) { toggle(); },
              activeColor: Theme.of(context).hintColor,
              inactiveThumbColor: Theme.of(context).hintColor.withOpacity(0.8),
              inactiveTrackColor: Theme.of(context).hintColor.withOpacity(0.25),
            ),
          ),*/
        ],
      )
    );
  }

  Widget _lengthConstraintWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Length (in minutes)',
            style: Theme.of(context).primaryTextTheme.displaySmall,
          ),
          Container(
            child: Text('Leave blank for no minimum or maximum',
              style: Theme.of(context).primaryTextTheme.headlineMedium,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        controller: widget.minLengthTextController,
                        onChanged: widget.onChanged,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'min',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    alignment: Alignment.center,
                    child: Text('to',
                      style: Theme.of(context).primaryTextTheme.displaySmall,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        controller: widget.maxLengthTextController,
                        onChanged: widget.onChanged,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'max',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*Container(
            child: Column(
              children: [
                Container(
                  child: Text('Minimum length (in minutes):',
                    style: Theme.of(context).primaryTextTheme.headlineMedium,
                  ),
                ),
                Container(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Min length (leave blank for no minimum)'
                    ),
                  ),
                ),
                Container(
                  child: Text('Maximum length:',
                    style: Theme.of(context).primaryTextTheme.headlineMedium,
                  ),
                ),
                Container(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Max length (leave blank for no maximum)'
                    ),
                  ),
                ),
              ],
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _languageConstraintWidget() {
    return Container();
  }

  Widget _locationConstraintWidget() {
    return Container();
  }

  Widget _containsAllSubtitle({required BuildContext ctx, required bool containsAll}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "e.g. ",
                style: Theme.of(ctx).primaryTextTheme.headlineMedium,
              ),
              TextSpan(
                text: "romans law ",
                style: Theme.of(ctx).primaryTextTheme.headlineMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: "means ",
                style: Theme.of(ctx).primaryTextTheme.headlineMedium,
              ),
              TextSpan(
                text: "romans ",
                style: Theme.of(ctx).primaryTextTheme.headlineMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: containsAll ? "AND " : "OR ",
                style: Theme.of(ctx).primaryTextTheme.headlineMedium,
              ),
              TextSpan(
                text: "law",
                style: Theme.of(ctx).primaryTextTheme.headlineMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: containsAll ? "" : " (or both)",
                style: Theme.of(ctx).primaryTextTheme.headlineMedium,
              )
            ]
          )
        ),
      ],
    );
  }
}