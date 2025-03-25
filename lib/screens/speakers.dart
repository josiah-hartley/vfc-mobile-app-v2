/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:voices_for_christ/data_models/playlist_class.dart';
import 'package:voices_for_christ/scoped_models/main_model.dart';
import 'package:voices_for_christ/widgets/dialogs/new_playlist_dialog.dart';
import 'package:voices_for_christ/widgets/dialogs/playlist_dialog.dart';

class SpeakersPage extends StatefulWidget {
  SpeakersPage({Key? key}) : super(key: key);

  @override
  _SpeakersPageState createState() => _SpeakersPageState();
}

class _SpeakersPageState extends State<SpeakersPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return Container();
      },
    );
  }

  Widget _listOfPlaylists({required List<Playlist> playlists, required Function onOpenPlaylist}) {
    return Container(
      alignment: Alignment.topLeft,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 10.0),
        itemCount: playlists.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container();
          }
          if (index == playlists.length + 1) {
            return SizedBox(height: 250.0);
          }
          return Container();
        }
      )
    );
  }
}*/