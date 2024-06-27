import 'package:sqflite/sqflite.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/database/table_names.dart';

Future<int> addToDB(Database db, Message msg) async {
  return await db.insert(messageTable, msg.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> batchAddToDB(Database db, List<Message> msgList) async {
  await db.transaction((txn) async {
    Batch batch = txn.batch();

    for (Message msg in msgList) {
      batch.insert(messageTable, msg.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  });
}

Future<Message?> queryOne(Database db, int id) async {
  List<Map<String,dynamic>> msgList = await db.query(messageTable, where: 'id = ?', whereArgs: [id]);
  
  if (msgList.length > 0) {
    return Message.fromMap(msgList.first);
  }
  return null;
}

Future<List<Message>> queryMultipleMessages({Database? db, List<int>? ids}) async {
  if (db == null) {
    print('null Database object passed to messages.queryMultipleMessages()');
    return [];
  }
  
  if (ids == null || ids.length < 1) {
    return [];
  }
  String idList = ids.join(',');
  try {
    var result = await db.rawQuery('''
      SELECT * FROM $messageTable
        WHERE id IN ($idList)
        ORDER BY instr('$idList', ',' || id || ',')
    ''');
    print('RESULT IS ${result}');
    
    if (result.isNotEmpty) {
      return result.map((msgMap) => Message.fromMap(msgMap)).toList();
    }
    return [];
  } catch(error) {
    print('Error querying messages: $error');
    return [];
  }
}

Future<List<Message>> queryRecentlyPlayedMessages({Database? db, required int start, required int end}) async {
  if (db == null) {
    print('null Database object passed to messages.queryRecentlyPlayedMessages()');
    return [];
  }
  
  try {
    List<Map<String,dynamic>> msgList = await db.query(messageTable, 
      where: 'lastplayeddate != 0', 
      orderBy: 'lastplayeddate DESC',
      limit: end - start,
      offset: start,
    );
  
    if (msgList.length > 0) {
      return msgList.map((m) => Message.fromMap(m)).toList();
    }
    return [];
  } catch(error) {
    print('Error querying recently played messages: $error');
    return [];
  }
}

Future<int> getTotalTimeListened({Database? db}) async {
  if (db == null) {
    print('null Database object passed to messages.getTotalTimeListened()');
    return 0;
  }
  try {
    return Sqflite.firstIntValue(await db.rawQuery('''
      SELECT SUM(approximateminutes)
      FROM $messageTable
      WHERE lastplayeddate != 0
    ''')) ?? 0;
  } catch (error) {
    print('Error getting total time listened: $error');
    return 0;
  }
}

Future<int> update(Database db, Message msg) async {
  return await db.update(messageTable, msg.toMap(), where: 'id = ?', whereArgs: [msg.id]);
}

Future<int> delete(Database db, int id) async {
  return await db.delete(messageTable, where: 'id = ?', whereArgs: [id]);
}