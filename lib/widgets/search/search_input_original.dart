import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Widget searchInput({required BuildContext context, 
  void Function()? closeWindow,
  required searchController,
  void Function(String)? onChanged,
  void Function()? onSearch,
  void Function()? onClearSearchString,
  FocusNode? focusNode}) {
    return Container(
      padding: EdgeInsets.only(top: 30.0, right: 10.0),
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
              child: TextField(
                controller: searchController,
                //autofocus: true,
                focusNode: focusNode,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                onEditingComplete: onSearch,
                cursorColor: Theme.of(context).hintColor,
                cursorWidth: 2.0,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 24.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for topics or speakers',
                  hintStyle: TextStyle(
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
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).hintColor.withOpacity(0.1),
                    Theme.of(context).hintColor.withOpacity(0.2),
                  ]
                ),
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
                    vertical: 12.0,
                    horizontal: 12.0
                  ),
                  color: Theme.of(context).hintColor.withOpacity(0.2),
                ),
                onTap: onClearSearchString,
              ),
            ) : Container(),
          Container(
            child: GestureDetector(
              //minWidth: 1.0,
              child: Container(
                child: Icon(
                  CupertinoIcons.search, 
                  color: Theme.of(context).hintColor,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 12.0
                ),
                color: Theme.of(context).hintColor.withOpacity(0.3),
              ),
              onTap: onSearch,
            ),
          ),
        ],
      ),
    );
  }