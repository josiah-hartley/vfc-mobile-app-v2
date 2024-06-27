import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voices_for_christ/helpers/constants.dart' as Constants;

class CheckDatabaseUpdatesDialog extends StatefulWidget {
  CheckDatabaseUpdatesDialog({Key? key, required this.lastUpdated}) : super(key: key);
  final DateTime lastUpdated;

  @override
  _CheckDatabaseUpdatesDialogState createState() => _CheckDatabaseUpdatesDialogState();
}

class _CheckDatabaseUpdatesDialogState extends State<CheckDatabaseUpdatesDialog> {
  Duration difference = Duration(days: 0);

  @override
  void initState() { 
    super.initState();
    setState(() {
      difference = DateTime.now().difference(widget.lastUpdated);
    });
  }

  void _checkForUpdates() {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text('Coming Soon',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        content: Text('This feature will be available in a future version',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int staleDays = Constants.DAYS_TO_MANUALLY_CHECK_CLOUD;

    return SimpleDialog(
      title: Text('Check for New Messages',
        style: TextStyle(
          color: Theme.of(context).hintColor,
        ),
      ),
      children: [
        Container(
          alignment: Alignment.center,
          child: Text('Last updated on ${widget.lastUpdated.month}/${widget.lastUpdated.day}/${widget.lastUpdated.year}',
            style: TextStyle(
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          child: TextButton(
            onPressed: difference.inDays > staleDays
              ? _checkForUpdates
              : null,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              color: difference.inDays > staleDays
                      ? Theme.of(context).hintColor
                      : Theme.of(context).hintColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.refresh,
                    size: 16.0,
                    color: difference.inDays > staleDays
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).hintColor.withOpacity(0.6),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5.0, top: 2.0),
                    child: Text('Update',
                      style: TextStyle(
                        color: difference.inDays > staleDays
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).hintColor.withOpacity(0.6),
                        fontSize: 18.0,  
                      ),
                    )
                  ),
                ],
              )
            ),
          ),
        ),
      ],
    );
  }
}