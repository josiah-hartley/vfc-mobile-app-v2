import 'package:sqflite/sqflite.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/database/table_names.dart';

Future<List<int>> getDownloadsCount({Database? db}) async {
  // returns [total, played]
  if (db == null) {
    print('null Database object passed to getDownloadsCount()');
    return [0, 0];
  }
  try {
    int total =  Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) from $messageTable WHERE isdownloaded = 1')) ?? 0;
    int played =  Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) from $messageTable WHERE isdownloaded = 1 AND isplayed = 1')) ?? 0;
    return [total, played];
  } catch (error) {
    print('Error getting downloads count: $error');
    return [0, 0];
  }
}

Future<List<Message>> queryDownloads({Database? db, int? start, int? end, String? orderBy, bool ascending = true}) async {
  if (db == null) {
    print('null Database object passed to queryDownloads()');
    return [];
  }
  String query = 'SELECT * from $messageTable WHERE isdownloaded = 1';

  if (orderBy != null) {
    query += ' ORDER BY ' + orderBy;
    ascending ? query += ' ASC' : query += ' DESC';
  }

  if (start != null && end != null) {
    query += ' LIMIT ${(end - start).toString()} OFFSET ${start.toString()}';
  }
  
  try {
    var result = await db.rawQuery(query);

    if (result.isNotEmpty) {
      List<Message> messages = result.map((msgMap) => Message.fromMap(msgMap)).toList();
      return messages;
    }
    return [];
  } catch (error) {
    print('Error loading downloads: $error');
    return [];
  }
}

Future<List<Message>> queryAllPlayedDownloads({Database? db}) async {
  if (db == null) {
    print('null Database object passed to queryAllPlayedDownloads()');
    return [];
  }
  try {
    List<Map<String,dynamic>> msgList = await db.query(messageTable, 
      where: 'isdownloaded = 1 AND isplayed = 1',
    );
  
    if (msgList.length > 0) {
      return msgList.map((m) => Message.fromMap(m)).toList();
    }
    return [];
  } catch(error) {
    print('Error querying all played messages: $error');
    return [];
  }
}

Future<List<Message>> getDownloadQueueFromDB(Database db) async {
  try {
    var result = await db.rawQuery('''
      SELECT * FROM $messageTable
      INNER JOIN $downloads 
      ON $messageTable.id = $downloads.messageid 
      ORDER BY $downloads.initiated
    ''');

    if (result.isNotEmpty) {
      List<Message> messages = result.map((msgMap) => Message.fromMap(msgMap)).toList();
      return messages;
    }
    return [];
  } catch(error) {
    print('Error getting messages in download queue: $error');
    return [];
  }
}

Future<void> addMessagesToDownloadQueueDB(Database db, List<Message?> messages) async {
  int time = DateTime.now().millisecondsSinceEpoch;
  try {
    await db.transaction((txn) async {
      Batch batch = txn.batch();

      for (Message? message in messages) {
        batch.insert(downloads, {
          'messageid': message?.id,
          'initiated': time,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit();
    });
  } catch(error) {
    print('Error adding messages to download queue in database');
  }
}

Future<void> removeMessagesFromDownloadQueueDB(Database db, List<Message> messages) async {
  try {
    await db.transaction((txn) async {
      Batch batch = txn.batch();

      for (Message message in messages) {
        batch.delete(downloads, where: "messageid = ?", whereArgs: [message.id]);
      }

      await batch.commit();
    });
  } catch(error) {
    print('Error removing messages from download queue in database');
  }
}