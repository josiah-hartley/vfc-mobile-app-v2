import 'package:sqflite/sqflite.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/database/table_names.dart';

Future<void> createVirtualTable({required Database db}) async {
  String query = 'CREATE VIRTUAL TABLE movies USING FTS5(title, overview, year UNINDEXED)';
  try {
    await db.rawQuery(query);
  } catch (error) {
    print('Error adding virtual table to SQLite database: $error');
  }

  String insertQuery = "INSERT INTO movies ('title', 'overview', 'poster', 'year') VALUES ('Pulp Fiction', 'A burger-loving hit man...', '1994')";
  try {
    await db.rawQuery(insertQuery);
  } catch (error) {
    print('Error inserting movie to SQLite database: $error');
  }
}

Future<List<Map>> fullTextSearch({required Database db, String? searchTerm}) async {
  String query = "SELECT * FROM movies WHERE movies MATCH 'pulp'";
  try {
    var result = await db.rawQuery(query);

    if (result.isNotEmpty) {
      print(result);
      return result;
    }
    return [];
  } catch (error) {
    print('Error full-text searching SQLite database: $error');
    return [];
  }
}

List<String> searchArguments(String searchTerm) {
  List<String> searchWords = searchTerm.split(' ').where((w) => w.length > 1).toList();
  return (searchWords.map((w) => '%' + w + '%')).toList();
}

String queryWhere(String? searchArg, List<String> comparisons) {
  if (searchArg == null || searchArg == '' || comparisons.length < 1) {
    return '';
  }

  String query = '${comparisons[0]} LIKE ?';
  for (int i = 1; i < comparisons.length; i++) {
    query += ' OR ${comparisons[i]} LIKE ?';
  }
  return query;
}

String columnsLike({required List<String> argList, required List<String> comparisons, required bool mustContainAll}) {
  String andor = mustContainAll ? 'AND' : 'OR';
  String query = '(${queryWhere(argList[0], comparisons)})';

  for (int i = 1; i < argList.length; i++) {
    query += ' $andor (' + queryWhere(argList[i], comparisons) + ')';
  }

  return query;
}

Future<List<Message>> queryArgList({required Database db, required String table, required String searchTerm, List<String>? comparisons, bool? onlyUnplayed, bool mustContainAll = true, int? start, int? end}) async {
  List<String> argList = searchArguments(searchTerm);

  if (argList.length < 1 || comparisons == null || comparisons.length < 1) {
    return [];
  }

  String query = 'SELECT * from $table WHERE (';
  List<String> args = [];
  
  query += columnsLike(
    argList: argList,
    comparisons: comparisons,
    mustContainAll: true,
  );
  for (int i = 0; i < argList.length; i++) {
    args.addAll(List.filled(comparisons.length, argList[i]));
  }
  query += ')';

  if (mustContainAll == false) {
    query += ' OR (' + columnsLike(
      argList: argList,
      comparisons: comparisons,
      mustContainAll: false,
    );
    for (int i = 0; i < argList.length; i++) {
      args.addAll(List.filled(comparisons.length, argList[i]));
    }
    query += ')';
  }

  if (onlyUnplayed == true) {
     query += ' AND isplayed = 0';
  }

  if (start != null && end != null) {
    query += ' LIMIT ${(end - start).toString()} OFFSET ${start.toString()}';
  }
  
  try {
    var result = await db.rawQuery(query, args);

    if (result.isNotEmpty) {
      List<Message> messages = result.map((msgMap) => Message.fromMap(msgMap)).toList();
      return messages;
    }
    return [];
  } catch (error) {
    print('Error searching SQLite database: $error');
    return [];
  }
}

Future<int> queryCountArgList ({required Database db, required String table, required String searchTerm, List<String>? comparisons, bool onlyUnplayed = false, bool mustContainAll = true}) async {
  List<String> argList = searchArguments(searchTerm);

  if (argList.length < 1 || comparisons == null || comparisons.length < 1) {
    return 0;
  }

  String query = 'SELECT COUNT(*) from $table WHERE (';
  List<String> args = [];
  
  query += columnsLike(
    argList: argList,
    comparisons: comparisons,
    mustContainAll: true,
  );
  for (int i = 0; i < argList.length; i++) {
    args.addAll(List.filled(comparisons.length, argList[i]));
  }
  query += ')';

  if (mustContainAll == false) {
    query += ' OR (' + columnsLike(
      argList: argList,
      comparisons: comparisons,
      mustContainAll: false,
    );
    for (int i = 0; i < argList.length; i++) {
      args.addAll(List.filled(comparisons.length, argList[i]));
    }
    query += ')';
  }

  if (onlyUnplayed) {
     query += ' AND isplayed = 0';
  }
  
  try {
    return Sqflite.firstIntValue(await db.rawQuery(query, args)) ?? 0;
  } catch (error) {
    print('Error searching SQLite database: $error');
    return 0;
  }
}

Future<int> searchCountSpeakerTitle({required Database db, required String searchTerm, required bool mustContainAll}) async {
  List<String> comparisons = ['speaker', 'title', 'taglist'];
  return queryCountArgList(
    db: db,
    table: messageTable,
    searchTerm: searchTerm,
    comparisons: comparisons,
    mustContainAll: mustContainAll,
  );
}

Future<List<Message>> searchBySpeakerOrTitle({required Database db, required String searchTerm, required bool mustContainAll, int? start, int? end}) async {
  List<String> comparisons = ['speaker', 'title', 'taglist'];
  return queryArgList(
    db: db,
    table: messageTable,
    searchTerm: searchTerm,
    comparisons: comparisons,
    mustContainAll: mustContainAll,
    start: start,
    end: end,
  );
}

Future<List<Message>> searchByColumns({required Database db, required String searchTerm, List<String>? columns, bool? onlyUnplayed, required bool mustContainAll, int? start, int? end}) async {
  return queryArgList(
    db: db,
    table: messageTable,
    searchTerm: searchTerm,
    comparisons: columns,
    onlyUnplayed: onlyUnplayed ?? false,
    mustContainAll: mustContainAll,
    start: start,
    end: end,
  );
}

/*Future<List<Message>> searchBySpeaker(String searchTerm, [int start, int end]) async {
  Database db = await instance.database;
  List<String> args = searchArguments(searchTerm);
  String query = 'SELECT * from $_messageTable WHERE ' + queryWhere('speaker', args);
  
  if (start != null && end != null) {
    query += ' LIMIT ${(end - start).toString()} OFFSET ${start.toString()}';
  }
  
  try {
    //var result = await db.query(_messageTable, where: "speaker LIKE ?", whereArgs: ['%' + searchTerm + '%']);
    var result = await db.rawQuery(query, args);

    if (result.isNotEmpty) {
      List<Message> messages = result.map((msgMap) => Message.fromMap(msgMap)).toList();
      return messages;
    }
    return [];
  } catch (error) {
    print('Error searching SQLite database: $error');
    return [];
  }
}*/

/*Future<List<Message>> searchByTitle(String searchTerm, [int start, int end]) async {
  Database db = await instance.database;
  List<String> args = searchArguments(searchTerm);
  String query = 'SELECT * from $_messageTable WHERE ' + queryWhere('title', args);
  
  if (start != null && end != null) {
    query += ' LIMIT ${(end - start).toString()} OFFSET ${start.toString()}';
  }
  
  try {
    //var result = await db.query(_messageTable, where: "title LIKE ?", whereArgs: ['%' + searchTerm + '%']);
    var result = await db.rawQuery(query, args);

    if (result.isNotEmpty) {
      List<Message> messages = result.map((msgMap) => Message.fromMap(msgMap)).toList();
      return messages;
    }
    return [];
  } catch (error) {
    print('Error searching SQLite database: $error');
    return [];
  }
}*/

/*Future<List<Message>> searchBySpeakerOrTitle(String searchTerm, [int start, int end]) async {
  Database db = await instance.database;
  List<String> args = searchArguments(searchTerm);
  String query = 'SELECT * from $_messageTable WHERE ' 
    + queryWhere('speaker', args) + ' OR '
    + queryWhere('title', args) + ' OR '
    + queryWhere('taglist', args);
  List<String> args3 = List.from(args)..addAll(args)..addAll(args);

  if (start != null && end != null) {
    query += ' LIMIT ${(end - start).toString()} OFFSET ${start.toString()}';
  }
  
  try {
    /*var result = await db.query(_messageTable, 
      where: "speaker LIKE ? OR title LIKE ? OR taglist LIKE ?", 
      whereArgs: ['%' + searchTerm + '%', '%' + searchTerm + '%', '%' + searchTerm + '%']);*/
    var result = await db.rawQuery(query, args3);

    if (result.isNotEmpty) {
      List<Message> messages = result.map((msgMap) => Message.fromMap(msgMap)).toList();
      return messages;
    }
    return [];
  } catch (error) {
    print('Error searching SQLite database: $error');
    return [];
  }
}*/

/*Future<int> searchCountSpeakerTitle(String searchTerm) async {
  Database db = await instance.database;
  List<String> args = searchArguments(searchTerm);
  String query = 'SELECT COUNT(*) from $_messageTable WHERE ' 
    + queryWhere('speaker', args) + ' OR '
    + queryWhere('title', args) + ' OR '
    + queryWhere('taglist', args);
  List<String> args3 = List.from(args)..addAll(args)..addAll(args);
  
  try {
    return Sqflite.firstIntValue(await db.rawQuery(query, args3));
  } catch (error) {
    print('Error searching SQLite database: $error');
    return 0;
  }
}*/

/*Future<List<Message>> searchLimitOffset(String searchTerm, int start, int end) async {
  Database db = await instance.database;
  try {
    var result = await db.query(_messageTable, 
      where: "speaker LIKE ? OR title LIKE ? OR taglist LIKE ?", 
      whereArgs: ['%' + searchTerm + '%', '%' + searchTerm + '%', '%' + searchTerm + '%'],
      limit: end - start, offset: start);

    if (result.isNotEmpty) {
      List<Message> messages = result.map((msgMap) => Message.fromMap(msgMap)).toList();
      return messages;
    }
    return [];
  } catch (error) {
    print('Error searching SQLite database: $error');
    return [];
  }
}*/