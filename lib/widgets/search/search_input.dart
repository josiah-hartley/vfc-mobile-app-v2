import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:voices_for_christ/widgets/search/advanced_search_options.dart';

Widget searchInput({required BuildContext context,
  bool? condensed,
  required TextEditingController topicSearchController,
  required TextEditingController speakerSearchController,
  void Function(String)? onChanged,
  void Function()? onReset,
  void Function()? onSearch,
  void Function()? onClearSearchStringTopic,
  void Function()? onClearSearchStringSpeaker,
  FocusNode? focusNodeTopic,
  FocusNode? focusNodeSpeaker,
  required TextEditingController minLengthTextController,
  required TextEditingController maxLengthTextController
  }) {
    if (condensed == true) {
      return Container(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
          child: _searchInputBody(
            context: context,
            condensed: condensed,
            topicSearchController: topicSearchController,
            speakerSearchController: speakerSearchController,
            focusNodeTopic: focusNodeTopic,
            focusNodeSpeaker: focusNodeSpeaker,
            onChanged: onChanged,
            onReset: onReset,
            onSearch: onSearch,
            onClearSearchStringTopic: onClearSearchStringTopic,
            onClearSearchStringSpeaker: onClearSearchStringSpeaker,
            minLengthTextController: minLengthTextController,
            maxLengthTextController: maxLengthTextController,
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: _searchInputBody(
          context: context,
          condensed: condensed,
          topicSearchController: topicSearchController,
          speakerSearchController: speakerSearchController,
          focusNodeTopic: focusNodeTopic,
          focusNodeSpeaker: focusNodeSpeaker,
          onChanged: onChanged,
          onReset: onReset,
          onSearch: onSearch,
          onClearSearchStringTopic: onClearSearchStringTopic,
          onClearSearchStringSpeaker: onClearSearchStringSpeaker,
          minLengthTextController: minLengthTextController,
          maxLengthTextController: maxLengthTextController,
        ),
      ),
    );
  }

Widget _searchInputBody({
  required BuildContext context,
  bool? condensed,
  required TextEditingController topicSearchController,
  required TextEditingController speakerSearchController,
  void Function(String)? onChanged,
  void Function()? onReset,
  void Function()? onSearch,
  void Function()? onClearSearchStringTopic,
  void Function()? onClearSearchStringSpeaker,
  FocusNode? focusNodeTopic,
  FocusNode? focusNodeSpeaker,
  required TextEditingController minLengthTextController,
  required TextEditingController maxLengthTextController,
}) {
  double _vertPadding = condensed == true ? 5.0 : 30.0;
  return Container(
    padding: EdgeInsets.symmetric(vertical: _vertPadding),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        condensed == true
        ? Container()
        : Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          alignment: Alignment.centerLeft,
          child: Text('Title'.toUpperCase(),
            style: TextStyle(
              fontSize: 18.0,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _searchBox(
                context: context,
                condensed: condensed,
                searchController: topicSearchController,
                focusNode: focusNodeTopic,
                onChanged: onChanged,
                onEditingComplete: onSearch,
                onClearSearchString: onClearSearchStringTopic,
                hintText: 'Search by topic',
                //icon: CupertinoIcons.textbox,
              ),
            ),
            condensed == true 
            ? Container(
              child: _smallButton(context: context, onTap: onReset, icon: CupertinoIcons.arrow_left),
            )
            : Container(),
          ],
        ),
        condensed == true
        ? Container()
        : Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Text('and / or',
            style: TextStyle(
              color: Theme.of(context).hintColor,
            )
          )
        ),
        condensed == true
        ? Container()
        : Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          alignment: Alignment.centerLeft,
          child: Text('Speaker'.toUpperCase(),
            style: TextStyle(
              fontSize: 18.0,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _searchBox(
                context: context,
                condensed: condensed,
                searchController: speakerSearchController,
                focusNode: focusNodeSpeaker,
                onChanged: onChanged,
                onEditingComplete: onSearch,
                onClearSearchString: onClearSearchStringSpeaker,
                hintText: 'Search by speaker name',
                //icon: CupertinoIcons.person_alt_circle,
              ),
            ),
            condensed == true 
            ? Container(
              child: _smallButton(context: context, onTap: onSearch, icon: CupertinoIcons.search),
            )
            : Container(),
          ],
        ),
        condensed == true 
        ? Container() 
        : _searchButton(
          context: context,
          onSearch: onSearch
        ),
        condensed == true ? Container() : AdvancedSearchOptions(
          minLengthTextController: minLengthTextController,
          maxLengthTextController: maxLengthTextController,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

Widget _smallButton({
  required BuildContext context,
  void Function()? onTap,
  required IconData icon,
}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
    child: GestureDetector(
      //minWidth: 1.0,
      child: Container(
        child: Icon(
          icon, 
          size: 22.0,
          color: Theme.of(context).hintColor,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 12.0
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: Theme.of(context).hintColor.withOpacity(0.3),
        ),
      ),
      onTap: onTap,
    ),
  );
}

Widget _searchButton({
  required BuildContext context,
  void Function()? onSearch
}) {
  return Container(
    padding: EdgeInsets.only(top: 40.0, left: 5.0, right : 5.0),
    child: GestureDetector(
      //minWidth: 1.0,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                child: Text('SEARCH',
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              )
            ),
            Icon(
              CupertinoIcons.search, 
              size: 22.0,
              color: Theme.of(context).hintColor,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 24.0
        ),
        color: Theme.of(context).hintColor.withOpacity(0.3),
      ),
      onTap: onSearch,
    ),
  );
}

Widget _searchBox({
  required BuildContext context,
  bool? condensed,
  required TextEditingController searchController,
  FocusNode? focusNode,
  void Function(String)? onChanged,
  void Function()? onEditingComplete,
  void Function()? onClearSearchString,
  String? hintText,
  IconData? icon,
}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
    child: Row(
      children: [
        icon == null
        ? Container()
        : Container(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(icon,
            color: Theme.of(context).hintColor,
            size: 28.0,
          ),
        ),
        Expanded(
          child: Container(
            child: TextField(
              controller: searchController,
              //autofocus: true,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              onEditingComplete: onEditingComplete,
              cursorColor: Theme.of(context).hintColor,
              cursorWidth: 2.0,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 24.0,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  //color: Theme.of(context).primaryColor.withOpacity(0.6),
                  color: Theme.of(context).hintColor.withOpacity(0.6),
                  fontSize: 18.0,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 12.0, right: 12.0),
              ),
            ),
            decoration: BoxDecoration(
              //color: Theme.of(context).hintColor,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).hintColor,
              )
              /*gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Theme.of(context).hintColor.withOpacity(0.8),
                  Theme.of(context).hintColor.withOpacity(0.6),
                ]
              ),*/
            ),
          ),
        ),
        searchController.text.length > 0
          ? Container(
            child: GestureDetector(
              child: Container(
                //minWidth: 1.0,
                child: Icon(
                  CupertinoIcons.xmark_circle, 
                  color: Theme.of(context).hintColor,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 13.0,
                  horizontal: 13.0
                ),
                color: Theme.of(context).hintColor.withOpacity(0.2),
              ),
              onTap: onClearSearchString,
            ),
          ) : Container(),
      ],
    )
  );
}