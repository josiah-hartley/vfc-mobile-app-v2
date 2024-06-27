import 'package:flutter/material.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/helpers/duration_in_minutes.dart';
import 'package:voices_for_christ/helpers/reverse_speaker_name.dart';

class MoreMessageDetailsDialog extends StatelessWidget {
  const MoreMessageDetailsDialog({Key? key, this.message}) : super(key: key);
  final Message? message;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.only(top: 14.0, bottom: 24.0, left: 20.0, right: 20.0),
      title: Text(message?.title ?? '',
        style: Theme.of(context).primaryTextTheme.displayMedium?.copyWith(fontSize: 18.0),
        textAlign: TextAlign.center,
      ),
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(speakerReversedName(message?.speaker),
                    style: Theme.of(context).primaryTextTheme.displayLarge?.copyWith(fontSize: 16.0),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(message?.durationinseconds == 0.0
                    ? message?.approximateminutes == 0
                      ? ''
                      : '${message?.approximateminutes} min'
                    : messageDurationInMinutes(message?.durationinseconds),
                    style: Theme.of(context).primaryTextTheme.displayLarge?.copyWith(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        _detail(
          context: context,
          label: 'Tags:',
          value: message == null || message?.taglist == null ? '' : message!.taglist.split(',').join(', '),
        ),
        _detail(
          context: context,
          label: 'Date:',
          value: message?.date ?? '',
        ),
        _detail(
          context: context,
          label: 'Language:',
          value: message?.language ?? '',
        ),
        _detail(
          context: context,
          label: 'Location:',
          value: message == null || message?.location == null || message?.location == 'unavailable' 
                  ? '' 
                  : message!.location,
        ),
      ],
    );
  }

  Widget _detail({required BuildContext context, required String label, required String value, double fontSize = 16.0}) {
    if (value.length < 1) {
      return SizedBox(height: 0.0);
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(label,
                style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(fontSize: fontSize),
              )
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(value,
                style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(fontSize: fontSize),
              )
            ),
          ),
        ],
      )
    );
  }
}