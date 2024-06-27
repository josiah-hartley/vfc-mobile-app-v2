import 'package:flutter/material.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/database/local_db.dart';
import 'package:voices_for_christ/widgets/buttons/action_button.dart';

class DeletePlayedDownloadsDialog extends StatefulWidget {
  DeletePlayedDownloadsDialog({Key? key, required this.deleteMessages}) : super(key: key);
  final Function deleteMessages;

  @override
  _DeletePlayedDownloadsDialogState createState() => _DeletePlayedDownloadsDialogState();
}

class _DeletePlayedDownloadsDialogState extends State<DeletePlayedDownloadsDialog> {
  final db = MessageDB.instance;
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Remove Played Downloads?',
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Text('You can remove the downloaded audio files for messages that you have listened to.',
            style: TextStyle(color: Theme.of(context).hintColor),
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _deleting 
                ? ActionButton(
                  text: 'Removing',
                  onPressed: () {},
                )
                : ActionButton(
                  text: 'Remove',
                  onPressed: () async {
                    setState(() {
                      _deleting = true;
                    });
                    List<Message> _playedMessages = await db.queryAllPlayedDownloads();
                    widget.deleteMessages(_playedMessages);
                    setState(() {
                      _deleting = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ActionButton(
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}