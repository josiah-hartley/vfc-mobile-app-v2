import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/data_models/recommendation_class.dart';
import 'package:voices_for_christ/helpers/duration_in_minutes.dart';
import 'package:voices_for_christ/helpers/reverse_speaker_name.dart';
import 'package:voices_for_christ/scoped_models/main_model.dart';
import 'package:voices_for_christ/widgets/dialogs/message_actions_dialog.dart';
import 'package:voices_for_christ/helpers/constants.dart' as Constants;

class HomePage extends StatelessWidget {
  const HomePage({Key? key, this.debugMessage}) : super(key: key);
  final String? debugMessage;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return Container(
          child: Container(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 0.0, bottom: 250.0),
              shrinkWrap: true,
              itemCount: model.recommendations.length + 1,
              itemBuilder: (ctx, index) {
                if (index == 0) {
                  return Container(
                    padding: EdgeInsets.only(top: 12.0, left: 14.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Recommendations',
                                style: Theme.of(context).primaryTextTheme.displayLarge,
                              )
                            ),
                            Container(
                              child: IconButton(
                                icon: Icon(CupertinoIcons.question_circle,
                                  color: Theme.of(context).hintColor,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context, 
                                    builder: (context) => AlertDialog(
                                      title: Container(
                                        child: Text('Recommendations',
                                          style: TextStyle(color: Theme.of(context).hintColor),
                                        ),
                                      ),
                                      content: Container(
                                        child: Text('At first, the recommended messages on the home page come from pre-selected categories.  Over time, these recommendations will update based on speakers and topics related to messages that you download and favorite.',
                                          style: TextStyle(color: Theme.of(context).hintColor),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        debugMessage == ''
                          ? Container()
                          : Container(
                            child: Row(
                              children: [
                                Container(
                                  child: Text(debugMessage ?? '',
                                    style: TextStyle(color: Theme.of(context).hintColor),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    child: Text('Reset'),
                                    onPressed: () {
                                      model.resetLastCloudCheckedDateInDB();
                                    },
                                  )
                                ),
                              ]
                            ),
                          ),
                      ],
                    ),
                  );
                }
                return _recommendationCategory(
                  context: context, 
                  recommendation: model.recommendations[index - 1],
                  onLoadMore: () {
                    model.getMoreMessagesForRecommendation(index - 1);
                  }
                );
              }
            ),
          ),
        );
      }
    );
  }

  Widget _recommendationCategory({required BuildContext context, Recommendation? recommendation, void Function()? onLoadMore}) {
    if (recommendation == null) {
      return Container();
    }
    return Container(
      height: 235.0,
      padding: EdgeInsets.only(top: 30.0, bottom: 30.0, left: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(recommendation.getHeader(), 
              style: Theme.of(context).primaryTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w300, fontSize: 20.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
          //Container(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: recommendation.messages.length + 1,
              itemBuilder: (context, index) {
                if (index >= recommendation.messages.length) {
                  if (recommendation.type == 'featured' || recommendation.type == 'downloads') {
                    return Container();
                  }
                  return _loadMoreButton(context, onLoadMore);
                }
                return _recommendedMessageCard(context, recommendation.messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required BuildContext context, void Function()? onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
        child: Container(
          color: Theme.of(context).cardColor,
          margin: EdgeInsets.only(right: 14.0),
          //elevation: 0.5,
          child: Container(
            decoration: BoxDecoration(
              /*gradient: LinearGradient(
                colors: [
                  Theme.of(context).cardColor,
                  Theme.of(context).canvasColor.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),*/
              border: Border.all(
                color: Theme.of(context).hintColor.withOpacity(0.1),
                width: 1,
              ),
              color: Theme.of(context).hintColor.withOpacity(0.05),//Theme.of(context).hintColor.withOpacity(0.05),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            width: min(MediaQuery.of(context).size.width * 0.7, Constants.MAX_RECOMMENDATION_WIDTH),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _recommendedMessageCard(BuildContext context, Message message) {
    return _card(
      context: context,
      onTap: () {
        showDialog(
          context: context, 
          builder: (context) {
            return MessageActionsDialog(
              message: message,
            );
          }
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.title, 
            style: Theme.of(context).primaryTextTheme.displaySmall?.copyWith(fontSize: 20.0, fontWeight: FontWeight.w400),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
                    child: Text(speakerReversedName(message.speaker), 
                      style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                        fontSize: 18.0, 
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).hintColor.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: Text(message.durationinseconds == 0.0
                  ? message.approximateminutes == 0
                    ? ''
                    : '${message.approximateminutes} min'
                  : messageDurationInMinutes(message.durationinseconds), 
                  style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(fontSize: 14.0, fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadMoreButton(BuildContext context, void Function()? onPressed) {
    return _card(
      context: context,
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Icon(CupertinoIcons.add,
              size: 48.0,
              color: Theme.of(context).hintColor,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
            child: Text('Load More', 
              style: Theme.of(context).primaryTextTheme.displayMedium?.copyWith(fontSize: 22.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}