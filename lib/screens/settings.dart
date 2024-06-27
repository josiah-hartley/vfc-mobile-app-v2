import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:voices_for_christ/scoped_models/main_model.dart';
import 'package:voices_for_christ/widgets/dialogs/settings/check_database_updates_dialog.dart';
import 'package:voices_for_christ/widgets/dialogs/settings/delete_played_downloads_dialog.dart';
import 'package:voices_for_christ/widgets/dialogs/settings/error_reporting_dialog.dart';
import 'package:voices_for_christ/widgets/dialogs/settings/history_dialog.dart';
import 'package:voices_for_christ/helpers/constants.dart' as Constants;

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return SizedBox.expand(
          child: Material(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
              color: Theme.of(context).canvasColor,
              child: ListView(
                padding: EdgeInsets.only(top: 0.0),
                children: [
                  _title(context),
                  _toggle(
                    context: context,
                    value: model.darkMode, 
                    title: 'Dark theme',
                    subtitle: model.darkMode ? 'On' : 'Off',
                    toggle: model.toggleDarkMode,
                  ),
                  _toggle(
                    context: context,
                    value: model.downloadOverData, 
                    title: 'Download over data',
                    subtitle: model.downloadOverData 
                      ? 'Messages will download over WiFi or mobile connections' 
                      : 'Messages will only download over WiFi',
                    toggle: model.toggleDownloadOverData,
                  ),
                  _toggle(
                    context: context,
                    value: model.removePlayedDownloads, 
                    title: 'Remove played downloads',
                    subtitle: model.removePlayedDownloads 
                      ? 'Message files will be periodically removed from your device if they have been played' 
                      : 'Off',
                    toggle: model.toggleRemovePlayedDownloads,
                  ),
                  _storageUsage(
                    context: context, 
                    bytes: model.downloadedBytes,
                    deleteMessages: model.deleteMessages,
                  ),
                  _viewHistory(
                    context: context,
                  ),
                  _reportError(
                    context: context,
                  ),
                  _checkForUpdates(
                    context: context,
                    lastUpdated: model.cloudLastCheckedDate,
                  ),
                  _versionNumber(
                    context: context,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _title(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).hintColor.withOpacity(0.6),
            width: 1.0,
          )
        )
      ),
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              color: Theme.of(context).canvasColor.withOpacity(0.01),
              padding: EdgeInsets.only(right: 10.0, top: 12.0, bottom: 12.0, left: 12.0),
              child: Icon(CupertinoIcons.back, 
                size: 34.0,
                color: Theme.of(context).hintColor
              ),
            ),
            onTap: () { Navigator.of(context).pop(); },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 2.0),
              child: Text('SETTINGS', 
                style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontSize: 22.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle({required BuildContext context, required bool value, String? title, String? subtitle, required Function toggle}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title ?? '',
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                ),
                subtitle == null
                  ? SizedBox(height: 0.0)
                  : Container(
                      padding: EdgeInsets.only(top: 5.0, right: 25.0),
                      child: Text(subtitle,
                        style: Theme.of(context).primaryTextTheme.headlineMedium,
                      ),
                    ),
              ],
            ),
          ),
          Container(
            child: Switch(
              value: value,
              onChanged: (val) { toggle(); },
              activeColor: Theme.of(context).hintColor,
              inactiveThumbColor: Theme.of(context).hintColor.withOpacity(0.8),
              inactiveTrackColor: Theme.of(context).hintColor.withOpacity(0.25),
            ),
          ),
        ],
      )
    );
  }

  Widget _storageUsage({required BuildContext context, required int bytes, required Function deleteMessages}) {
    double mb = bytes / 1000000;
    double gb = mb / 1000;
    // round megabytes to 1 decimal place
    mb = (mb * 10).round() / 10;
    // round gigabytes to 2 decimal places
    gb = (gb * 100).round() / 100;
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => DeletePlayedDownloadsDialog(deleteMessages: deleteMessages),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Storage used',
                    style: Theme.of(context).primaryTextTheme.displayMedium,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5.0, right: 25.0),
                    child: Text('You can remove downloaded messages to free up space',
                      style: Theme.of(context).primaryTextTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              child: Text(mb > 500 ? '$gb GB' : '$mb MB',
                style: Theme.of(context).primaryTextTheme.displayMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewHistory({required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => HistoryDialog(),
        );
      },
      child: Container(
        color: Theme.of(context).canvasColor.withOpacity(0.01),
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('History',
              style: Theme.of(context).primaryTextTheme.displayMedium,
            ),
            Container(
              padding: EdgeInsets.only(top: 5.0, right: 25.0),
              child: Text('View recently played messages',
                style: Theme.of(context).primaryTextTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkForUpdates({required BuildContext context, required int lastUpdated}) {
    DateTime d = DateTime.fromMillisecondsSinceEpoch(lastUpdated);
    String lastUpdatedReadable = '${d.month}/${d.day}/${d.year}';
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CheckDatabaseUpdatesDialog(lastUpdated: d),
        );
      },
      child: Container(
        color: Theme.of(context).canvasColor.withOpacity(0.01),
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Check for new messages',
              style: Theme.of(context).primaryTextTheme.displayMedium,
            ),
            Container(
              padding: EdgeInsets.only(top: 5.0, right: 25.0),
              child: Text('Last updated on $lastUpdatedReadable',
                style: Theme.of(context).primaryTextTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportError({required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ErrorReportingDialog(),
        );
      },
      child: Container(
        color: Theme.of(context).canvasColor.withOpacity(0.01),
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report Error',
              style: Theme.of(context).primaryTextTheme.displayMedium,
            ),
            Container(
              padding: EdgeInsets.only(top: 5.0, right: 25.0),
              child: Text('Send a bug report',
                style: Theme.of(context).primaryTextTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _versionNumber({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text('Version',
              style: Theme.of(context).primaryTextTheme.displayMedium,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: Text(Constants.APP_VERSION,
              style: Theme.of(context).primaryTextTheme.displayMedium,
            ),
          ),
        ],
      ),
    );
  }
}