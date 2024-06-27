import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/data_models/playlist_class.dart';
import 'package:voices_for_christ/helpers/reverse_speaker_name.dart';
import 'package:voices_for_christ/scoped_models/main_model.dart';
import 'package:voices_for_christ/widgets/dialogs/add_to_playlist_dialog.dart';
import 'package:voices_for_christ/widgets/dialogs/more_message_details_dialog.dart';
import 'package:voices_for_christ/widgets/dialogs/playback_speed_dialog.dart';
import 'package:voices_for_christ/widgets/dialogs/queue_dialog.dart';
import 'package:voices_for_christ/widgets/player/seekbar.dart';

class PlayerPanelExpanded extends StatefulWidget {
  PlayerPanelExpanded({Key? key, required this.panelOpen, this.togglePanel}) : super(key: key);
  final bool panelOpen;
  final void Function()? togglePanel;

  @override
  _PlayerPanelExpandedState createState() => _PlayerPanelExpandedState();
}

class _PlayerPanelExpandedState extends State<PlayerPanelExpanded> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        if (model.currentlyPlayingMessage == null || !model.playerVisible) {
          return SizedBox(height: 0.0);
        }
        if (!widget.panelOpen) {
          return Container(color: Theme.of(context).bottomAppBarTheme.color);
        }
        return Container(
          alignment: Alignment.center,
          color: Theme.of(context).bottomAppBarTheme.color,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _closeButton(),
                  Expanded(child: Container()),
                  _info(
                    onPressed: () {
                      showDialog(
                        context: context, 
                        builder: (context) => MoreMessageDetailsDialog(message: model.currentlyPlayingMessage),
                      );
                    }
                  ),
                  _favorite(
                    message: model.currentlyPlayingMessage,
                    onPressed: () async {
                      await model.toggleFavorite(model.currentlyPlayingMessage);
                    },
                  ),
                ],
              ),
              Expanded(
                child: _messageTitle(model.currentlyPlayingMessage?.title ?? ''),
              ),
              Expanded(
                child: _speakerName(model.currentlyPlayingMessage?.speaker ?? ''),
              ),
              _slider(
                duration: model.duration,
                currentPositionStream: model.currentPositionStream,
                updatePosition: model.seekToSecond,
              ),
              Expanded(
                child: _mainActions(
                  playingStream: model.playingStream,
                  onPlay: model.play,
                  onPause: model.pause,
                  onSeekBackward: model.seekBackwardFifteenSeconds,
                  onSeekForward: model.seekForwardFifteenSeconds,
                  hasPrevious: model.queueIndex != null && model.queueIndex! > 0,
                  hasNext: model.queue?.length != null 
                            && model.queue!.length > 1 
                            && model.queueIndex != null 
                            && model.queueIndex! < (model.queue!.length - 1),
                  onSkipPrevious: model.skipPrevious,
                  onSkipNext: model.skipNext,
                ),
              ),
              Expanded(
                child: _extraActions(model),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _info({void Function()? onPressed}) {
    return Container(
      padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 12.0),
      child: IconButton(
        icon: Icon(CupertinoIcons.info,
          color: Colors.white,
          size: 28.0,
        ),
        onPressed: onPressed,
      )
    );
  }

  Widget _favorite({Message? message, void Function()? onPressed}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: IconButton(
        icon: Icon(message?.isfavorite == 1 ? CupertinoIcons.star_fill : CupertinoIcons.star,
          color: Colors.white,
          size: 28.0,
        ),
        onPressed: onPressed,
      )
    );
  }

  Widget _closeButton() {
    return TextButton(
      onPressed: widget.togglePanel,
      child: Container(
        color: Theme.of(context).bottomAppBarTheme.color?.withOpacity(0.01),
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
        child: Icon(CupertinoIcons.chevron_down,
          color: Colors.white,
          size: 28.0,
        ),
      ),
    );
  }

  Widget _messageTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      alignment: Alignment.bottomCenter,
      child: Text(title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.displayLarge,
      )
    );
  }

  Widget _speakerName(String speaker) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      alignment: Alignment.topCenter,
      child: Text(speakerReversedName(speaker),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.displayMedium,
      )
    );
  }

  Widget _slider({Stream<Duration>? currentPositionStream, required Duration duration, required Function updatePosition}) {
    return StreamBuilder(
      stream: currentPositionStream,
      builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
        Duration position = snapshot.data ?? Duration(seconds: 0);
        return SeekBar(
          position: position,
          duration: duration,
          updatePosition: updatePosition,
          verticalPadding: MediaQuery.of(context).size.height > 700 ? 10.0 : 0.0,
          horizontalPadding: MediaQuery.of(context).size.width > 500 ? MediaQuery.of(context).size.width / 12 : 0.0,
        );
      }
    );
  }

  Widget _mainActions({
    Stream<bool>? playingStream, 
    void Function()? onPlay, 
    void Function()? onPause,
    void Function()? onSeekBackward,
    void Function()? onSeekForward,
    required bool hasPrevious,
    required bool hasNext,
    void Function()? onSkipPrevious,
    void Function()? onSkipNext}) {
      List<Widget> _children = [
        _skipPrevious(
          hasPrevious: hasPrevious,
          onSkipPrevious: onSkipPrevious,
        ),
        _seekBackward(onSeekBackward),
        _playOrPause(
          playingStream: playingStream,
          onPlay: onPlay,
          onPause: onPause,
        ),
        _seekForward(onSeekForward),
        _skipNext(
          hasNext: hasNext,
          onSkipNext: onSkipNext,
        ),
      ];

      if (MediaQuery.of(context).size.width > 500) {
        _children.insert(0, Expanded(child: Container()));
        _children.add(Expanded(child: Container()));
      }

      return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: 25.0, left: 15.0, right: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _children,
        ),
      );
  }

  Widget _skipPrevious({required bool hasPrevious, void Function()? onSkipPrevious}) {
    return Expanded(
      child: IconButton(
        icon: Icon(Icons.skip_previous, 
          size: 32.0, 
          color: hasPrevious ? Colors.white : Colors.white.withOpacity(0.5),
        ),
        onPressed: hasPrevious ? onSkipPrevious : null,
      ),
    );
  }

  Widget _skipNext({required bool hasNext, void Function()? onSkipNext}) {
    return Expanded(
      child: IconButton(
        icon: Icon(Icons.skip_next, 
          size: 32.0, 
          color: hasNext ? Colors.white : Colors.white.withOpacity(0.5),
        ),
        onPressed: hasNext ? onSkipNext : null,
      ),
    );
  }

  Widget _playOrPause({Stream<bool>? playingStream, void Function()? onPlay, void Function()? onPause}) {
    return StreamBuilder(
      stream: playingStream,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        bool playing = snapshot.data ?? false;
        if (playing) {
          return _pause(onPause);
        }
        return _play(onPlay);
      }
    );
  }

  Widget _play(void Function()? onPlay) {
    return Expanded(
      child: RawMaterialButton(
        fillColor: Colors.orange[800]?.withOpacity(0.9),
        child: Icon(Icons.play_arrow,
          color: Colors.white,
          size: 50.0,
        ),
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.orange[800]!.withOpacity(0.9),
            width: 2.0,
          )
        ),
        padding: EdgeInsets.all(5.0),
        constraints: BoxConstraints(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        splashColor: Colors.transparent,
        onPressed: onPlay,
      ),
    );
  }

  Widget _pause(void Function()? onPause) {
    return Expanded(
      child: RawMaterialButton(
        fillColor: Colors.orange[800]?.withOpacity(0.9),
        child: Icon(Icons.pause,
          color: Colors.white,
          size: 50.0,
        ),
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.orange[800]!.withOpacity(0.9),
            width: 2.0,
          )
        ),
        padding: EdgeInsets.all(5.0),
        constraints: BoxConstraints(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        splashColor: Colors.transparent,
        onPressed: onPause,
      ),
    );
  }

  Widget _seekBackward(void Function()? onSeekBackward) {
    return Expanded(
      child: IconButton(
        icon: Icon(CupertinoIcons.gobackward_15, size: 32.0, color: Colors.white),
        onPressed: onSeekBackward,
      ),
    );
  }

  Widget _seekForward(void Function()? onSeekForward) {
    return Expanded(
      child: IconButton(
        icon: Icon(CupertinoIcons.goforward_15, size: 32.0, color: Colors.white),
        onPressed: onSeekForward,
      ),
    );
  }

  Widget _extraActions(MainModel model) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _viewQueue(),
          _playbackSpeed(
            speed: model.playbackSpeed,
            onChanged: model.setSpeed,
          ),
          model.currentlyPlayingMessage != null
            ? _addToPlaylist(message: model.currentlyPlayingMessage!, model: model)
            : Container(),
        ],
      ),
    );
  }

  Widget _viewQueue() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(45.0),
          )
        ),
        height: 45.0,
        width: 65.0,
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 3.0),
        child: Icon(CupertinoIcons.list_dash, size: 22.0, color: Colors.white),
      ),
      onTap: () {
        showDialog(
          context: context, 
          builder: (context) => QueueDialog(),
        );
      },
    );
  }

  Widget _playbackSpeed({required double speed, required Function onChanged}) {
    return GestureDetector(
      child: Container(
        height: 45.0,
        alignment: Alignment.center,
        color: Colors.white.withOpacity(0.25),
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Text('${speed}x',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      onTap: () async {
        double newSpeed = await showDialog(
          context: context, 
          builder: (context) {
            return PlaybackSpeedDialog(
              initialSpeed: speed,
            );
          }
        );
        if (newSpeed != speed) {
          onChanged(newSpeed);
        }
      },
    );
  }

  Widget _addToPlaylist({required Message message, required MainModel model}) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(45.0),
          )
        ),
        height: 45.0,
        width: 65.0,
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 3.0),
        child: Icon(Icons.playlist_add, size: 28.0, color: Colors.white),
      ),
      onTap: () async {
        List<Playlist> containing = await model.playlistsContainingMessage(message);
        showDialog(
          context: context, 
          builder: (context) {
            return AddToPlaylistDialog(
              message: message,
              playlistsOriginallyContainingMessage: containing,
            );
          }
        );
      },
    );
  }
}