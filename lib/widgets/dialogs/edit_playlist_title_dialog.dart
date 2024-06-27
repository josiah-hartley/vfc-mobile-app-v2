import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:voices_for_christ/data_models/playlist_class.dart';
//import 'package:voices_for_christ/database/local_db.dart';
import 'package:voices_for_christ/scoped_models/main_model.dart';
import 'package:voices_for_christ/widgets/buttons/action_button.dart';

class EditPlaylistTitleDialog extends StatefulWidget {
  EditPlaylistTitleDialog({Key? key, required this.playlist, required this.originalTitle}) : super(key: key);
  final Playlist playlist;
  final String originalTitle;

  @override
  _EditPlaylistTitleDialogState createState() => _EditPlaylistTitleDialogState();
}

class _EditPlaylistTitleDialogState extends State<EditPlaylistTitleDialog> {
  String _title = '';
  List<String> _existingTitles = [];
  String _errorMessage = '';
  //final db = MessageDB.instance;

  @override
  void initState() { 
    super.initState();
    //loadCurrentPlaylistTitles();
  }

  Future<void> loadCurrentPlaylistTitles(List<Playlist> existingPlaylists) async {
    //List<Playlist> _existingPlaylists = await db.getAllPlaylistsMetadata();
    _existingTitles = existingPlaylists.map((p) => p.title.toLowerCase()).toList();
  }

  Future<void> save({required BuildContext context, required Function onEdit}) async {
    bool _titleAlreadyUsed = titleIsDuplicated(_title);
    setErrorMessage(_titleAlreadyUsed);
    if (!_titleAlreadyUsed) {
      //await db.editPlaylistTitle(widget.playlist, _title);
      onEdit(widget.playlist, _title);
      Navigator.of(context).pop(_title);
    }
  }

  bool titleIsDuplicated(String val) {
    return val != widget.originalTitle && _existingTitles.indexOf(val.toLowerCase()) > -1;
  }

  void setErrorMessage(bool titleIsDuplicated) {
    if (titleIsDuplicated) {
      setState(() {
        _errorMessage = 'A playlist already exists with that title';
      });
    } else {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        loadCurrentPlaylistTitles(model.playlists);
        return SimpleDialog(
          title: Text('Edit Title',
            style: TextStyle(
              color: Theme.of(context).hintColor,
            ),
          ),
          children: [
            _titleInput(),
            _errorDisplay(),
            _actionButtonRow(model.editPlaylistTitle),
          ],
        );
      }
    );
  }

  Widget _titleInput() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      child: TextFormField(
        initialValue: widget.playlist.title ?? '',
        style: TextStyle(
          color: Theme.of(context).hintColor,
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          hintText: 'Title'
        ),
        onChanged: (val) {
          setErrorMessage(titleIsDuplicated(val));
          _title = val;
        },
      ),
    );
  }

  Widget _errorDisplay() {
    if (_errorMessage == '') {
      return Container();
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 25.0),
      child: Text(_errorMessage,
        style: TextStyle(
          color: Theme.of(context).hintColor,
        )
      ),
    );
  }

  Widget _actionButtonRow(Function onEdit) {
    return Container(
      padding: EdgeInsets.only(top: 14.0, right: 12.0, left: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ActionButton(
            text: 'Save',
            onPressed: () async {
              await save(
                context: context,
                onEdit: onEdit,
              );
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
    );
  }
}