import 'dart:io';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:voices_for_christ/helpers/constants.dart' as Constants;
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/database/local_db.dart';
import 'package:voices_for_christ/helpers/logger.dart' as Logger;

Future getMessageDataFromCloud({Function? onCompleted}) async {
  // see when database was last updated
  final dio = Dio();
  final db = MessageDB.instance;
  int lastUpdated = await db.getLastUpdatedDate();
  DateTime d = DateTime.fromMillisecondsSinceEpoch(lastUpdated);
  print('Starting to get messages from cloud; last updated at ${lastUpdated}.');
  Logger.logEvent(event: 'Starting to get messages from cloud; last updated at ${lastUpdated}.');
  
  String url = '${Constants.UPDATE_MESSAGE_API_URL}?startingYear=${d.year}&startingMonth=${d.month}';
  //String url = '${Constants.UPDATE_MESSAGE_API_URL}?startingYear=2024&startingMonth=8';

  DateTime startTime = DateTime.now();
  int staleDays = Constants.DAYS_TO_MANUALLY_CHECK_CLOUD;
  if (startTime.difference(d).inDays <= staleDays) {
    print('Already checked for updates within the last ${staleDays} days');
    Logger.logEvent(event: 'Already checked for updates within the last ${staleDays} days');
    return;
  }
  // get all messages since last update
  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> msgMap = response.data["messages"];
      print(msgMap);
      Logger.logEvent(event: 'Loaded ${msgMap.length} messages from cloud');

      // Add data in batches
      List<Message> msgList = [];

      for (var m in msgMap.entries) {
        m.value['id'] = int.parse(m.key);
        Message msg = Message.fromCloudMap(m.value);

        msgList.add(msg);
      }
      print(msgList);
      Duration loadingFromCloud = DateTime.now().difference(startTime);
      print('Loading messages from the cloud took ${loadingFromCloud.inMilliseconds} ms');
      await db.batchAddToDB(messageList: msgList, replace: true);

      // save current time as last updated time
      db.setLastUpdatedDate(DateTime.now().millisecondsSinceEpoch);
      
      if (onCompleted != null) {
        onCompleted();
      }

      Duration duration = DateTime.now().difference(startTime);
      Logger.logEvent(event: 'Loading messages from the cloud and adding them to the database took ${duration.inMilliseconds} ms');
      print('Loading messages from the cloud and adding them to the database took ${duration.inMilliseconds} ms');
    } else {
      throw HttpException('Server error: failed to load messages from AWS');
    }
  } catch (error) {
    throw error;
  }
}