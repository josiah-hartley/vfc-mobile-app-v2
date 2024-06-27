import 'dart:collection';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/data_models/playlist_class.dart';
import 'package:voices_for_christ/scoped_models/main_model.dart';
import 'package:voices_for_christ/widgets/buttons/action_button.dart';
import 'package:voices_for_christ/widgets/message_display/message_card.dart';
import 'package:voices_for_christ/helpers/constants.dart' as Constants;
import 'package:voices_for_christ/widgets/message_display/message_metadata.dart';
import 'package:voices_for_christ/widgets/message_display/multiselect_display.dart';

class QueueDialog extends StatefulWidget {
  QueueDialog({Key? key}) : super(key: key);

  @override
  _QueueDialogState createState() => _QueueDialogState();
}

class _QueueDialogState extends State<QueueDialog> {
  bool _reordering = false;
  List<Message> _reorderableQueue = [];
  LinkedHashSet<Message> _selectedMessages = LinkedHashSet();

  void _toggleMessageSelection(Message message) {
    setState(() {
      if (_selectedMessages.contains(message)) {
        _selectedMessages.remove(message);
      } else {
        if (_selectedMessages.length < Constants.MESSAGE_SELECTION_LIMIT) {
          _selectedMessages.add(message);
        }
      }
    });
  }

  void _selectAll(List<Message> messages) {
    if (messages.length > Constants.MESSAGE_SELECTION_LIMIT) {
      // max messages that can be selected
      messages = messages.sublist(0, Constants.MESSAGE_SELECTION_LIMIT - 1);
    }
    setState(() {
      _selectedMessages = LinkedHashSet.from(messages);
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedMessages = LinkedHashSet();
    });
  }

  void _openReorderingList(List<Message> futureQueue) {
    setState(() {
      _reorderableQueue = futureQueue;
      _reordering = true;
    });
  }

  void _closeReorderingList() {
    setState(() {
      _reordering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        if (model.queue == null) {
          return Container();
        }

        List<Message> nonNullQueue = model.queue!.where((m) => m != null).map((m) => m!).toList();

        Playlist _queueAsPlaylist = Playlist(
          id: Constants.QUEUE_PLAYLIST_ID, 
          created: 0, 
          title: 'Queue', 
          messages: nonNullQueue);
        int _indexOfCurrentMessage = nonNullQueue.indexWhere((m) => m.id == model.currentlyPlayingMessage?.id);
        List<Message> _futureQueue = nonNullQueue.length > _indexOfCurrentMessage + 1
          ? nonNullQueue.sublist(_indexOfCurrentMessage + 1)
          : [];

        return SizedBox.expand(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.0,
              sigmaY: 10.0,
            ),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.only(bottom: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectedMessages.length > 0
                    ? Container(
                      padding: EdgeInsets.only(top: 40.0),
                      child: MultiSelectDisplay(
                        selectedMessages: _selectedMessages,
                        onDeselectAll: _deselectAll,
                        showDownloadOptions: false,
                        showQueueOptions: false,
                      ),
                    )
                    : _titleAndActions(
                      currentMessage: model.currentlyPlayingMessage,
                      futureQueue: _futureQueue,
                      onSaveChanges: () {
                        model.updateFutureQueue(_reorderableQueue);
                      },
                    ),
                  _sectionTitle(context, 'Now Playing'),
                  model.currentlyPlayingMessage != null
                    ? _nowPlaying(context, model.currentlyPlayingMessage!, _queueAsPlaylist)
                    : Container(),
                  _futureQueue.length > 0
                    ? _sectionTitle(context, 'Up Next')
                    : Container(),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: _reordering
                        ? _reorderingUpNext()
                        : _upNext(_futureQueue, _queueAsPlaylist),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _titleAndActions({Message? currentMessage, required List<Message> futureQueue, required Function onSaveChanges}) {
    List<Widget> _titleChildren = [
      GestureDetector(
        child: Container(
          color: Theme.of(context).canvasColor.withOpacity(0.01),
          padding: EdgeInsets.only(right: 12.0, left: 16.0, top: 47.0, bottom: 7.0),
          child: Icon(CupertinoIcons.back, 
            size: 34.0,
            color: Theme.of(context).hintColor
          ),
        ),
        onTap: () { Navigator.of(context).pop(); },
      ),
      Expanded(
        child: Container(
          padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
          child: Text('Queue',
            style: Theme.of(context).primaryTextTheme.displayLarge?.copyWith(
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];

    if (_reordering) {
      _titleChildren.add(Container(
        padding: EdgeInsets.only(top: 37.0),
        child: ActionButton(
          onPressed: () async {
            onSaveChanges();
            _closeReorderingList();
          },
          text: 'Save',
        )
      ));

      _titleChildren.add(Container(
        padding: EdgeInsets.only(top: 37.0),
        child: ActionButton(
          onPressed: () async {
            _closeReorderingList();
          },
          text: 'Cancel',
        )
      ));
    } else {
      _titleChildren.add(Container(
        padding: EdgeInsets.only(top: 40.0),
        child: _queueActionsButton(
          currentMessage: currentMessage,
          futureQueue: futureQueue,
        ),
      ));
    }

    return Container(
      padding: EdgeInsets.only(bottom: 10.0, right: 16.0),
      child: Row(
        children: _titleChildren,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(
          color: Theme.of(context).hintColor
        ))
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
      child: Text(title,
        style: Theme.of(context).primaryTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w400),
      )
    );
  }

  Widget _nowPlaying(BuildContext context, Message message, Playlist queueAsPlaylist) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.only(bottom: 10.0),
        margin: EdgeInsets.only(bottom: 15.0),
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: MessageCard(
          message: message,
          playlist: queueAsPlaylist,
          selected: _selectedMessages.contains(message),
          onSelect: () {
            _toggleMessageSelection(message);
          },
        ),
      ),
    );
  }

  Widget _upNext(List<Message> futureQueue, Playlist queueAsPlaylist) {
    if (futureQueue.length < 1) {
      return Container();
    }
    List<Widget> _children = futureQueue.map((message) => MessageCard(
      message: message,
      playlist: queueAsPlaylist,
      selected: _selectedMessages.contains(message),
      onSelect: () {
        _toggleMessageSelection(message);
      },
    )).toList();

    return ListView(
      shrinkWrap: true,
      children: _children,
    );
  }

  Widget _reorderingUpNext() {
    return Theme(
      data: ThemeData(canvasColor: Colors.transparent),
      child: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final Message item = _reorderableQueue.removeAt(oldIndex);
            _reorderableQueue.insert(newIndex, item);
          });
        },
        shrinkWrap: true,
        children: _reorderingAndDeletingChildren(),
      )
    );
  }

  List<Widget> _reorderingAndDeletingChildren() {
    List<Widget> result = [];

    for (int i = 0; i < _reorderableQueue.length; i++) {
      Message message = _reorderableQueue[i];
      result.add(Container(
        key: Key('${message.id}'),
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
        child: Column(
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: i,
                  child: Container(
                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Container(
                      child: Icon(CupertinoIcons.line_horizontal_3, 
                        color: Theme.of(context).hintColor
                      ),
                      height: 40.0,
                      width: 40.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor.withOpacity(0.01),
                        shape: BoxShape.rectangle,
                        /*border: Border.all(
                          color: Theme.of(context).hintColor,
                          width: 1.0,
                        )*/
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: messageTitleAndSpeakerDisplay(
                    message: message,
                    truncateTitle: true,
                    textColor: Theme.of(context).hintColor,
                    showTime: false,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _reorderableQueue.removeAt(i);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                    child: Icon(CupertinoIcons.xmark,
                      color: Theme.of(context).hintColor,
                      size: 30.0,
                    )
                  ),
                ),
              ],
            ),
          ],
        ),
      ));
    }

    return result;
  }

  Widget _queueActionsButton({Message? currentMessage, required List<Message> futureQueue}) {
    //List<Message> _currentAndFutureQueue = [currentMessage]..addAll(futureQueue);
    List<Message> _currentAndFutureQueue = [];
    if (currentMessage != null) {
      _currentAndFutureQueue.add(currentMessage);
    }
    _currentAndFutureQueue.addAll(futureQueue);
    
    return Material(
      color: Theme.of(context).canvasColor.withOpacity(0.01),
      child: PopupMenuButton<int>(
        //iconSize: 25.0,
        icon: Icon(CupertinoIcons.ellipsis_vertical,
          color: Theme.of(context).hintColor,
          size: 24.0,
        ),
        color: Theme.of(context).primaryColor,
        shape: Border.all(color: Theme.of(context).hintColor.withOpacity(0.2)),
        offset: Offset(0.0, 30.0),
        elevation: 1.0,
        itemBuilder: (context) {
          return [
            _queueAction(
              value: 0,
              icon: CupertinoIcons.line_horizontal_3,
              text: 'Reorder and remove',
            ),
            _queueAction(
              value: 1,
              icon: Icons.check,
              text: 'Select all',
            ),
          ];
        },
        onSelected: (value) async {
          switch (value) {
            case 0:
              _openReorderingList(futureQueue);
              break;
            case 1:
              _selectAll(_currentAndFutureQueue);
              break;
          }
        },
      ),
    );
  }

  PopupMenuItem<int> _queueAction({required int value, IconData? icon, String? text}) {
    return PopupMenuItem<int>(
      value: value,
      child: Container(
        child: Row(
          children: [
            Container(
              child: Icon(icon,
                color: Theme.of(context).hintColor,
                size: 22.0,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
              child: Text(text ?? '',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16.0,
                )
              )
            ),
          ],
        )
      ),
    );
  }
}