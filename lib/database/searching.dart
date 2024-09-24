import 'package:sqflite/sqflite.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/database/table_names.dart';

bool searchTermInQuotes(String searchTerm) {
  if (searchTerm.length < 1) {
    return false;
  }
  if ((searchTerm[0] == '"' || searchTerm[0] == "'") 
        && (searchTerm[searchTerm.length - 1] == '"' || searchTerm[searchTerm.length - 1] == "'")) {
    return true;
  }
  return false;
}

List<String> searchArguments(String searchTerm) {
  //List<String> searchWords = searchTerm.split(' ').where((w) => w.length > 1).toList();
  List<String> searchWords = [];
  if (searchTerm.length < 1) {
    return searchWords;
  }
  if (searchTermInQuotes(searchTerm)) {
    searchWords = [searchTerm.replaceAll('"', '').replaceAll("'", '')];
  } else {
    searchWords = searchTerm.split(' ').where((w) => w.length >= 1).toList();
  }
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

String getAdvancedSearchQuery({
  required List<String> topicSearchWords,  
  required List<String> speakerSearchWords,
  bool onlyReturnCount = false,
  bool onlyUnplayed = false, 
  bool mustContainAll = true, 
  int? start, 
  int? end,
  String? language,
  String? location,
  int? minLengthInMinutes,
  int? maxLengthInMinutes,
  bool onlyFavorites = false,
  bool onlyDownloaded = false,
}) {
  String query = '';
  if (onlyReturnCount) {
    query = 'SELECT COUNT(*) from $messageTable WHERE ';
  } else {
    query = 'SELECT * from $messageTable WHERE ';
  }

  if (topicSearchWords.length > 0) {
    query += '(';
    query += columnsLike(
      argList: topicSearchWords,
      comparisons: ['title'],
      mustContainAll: mustContainAll
    );
    query += ')';
    if (speakerSearchWords.length > 0) {
      query += ' AND ';
    }
  }
  if (speakerSearchWords.length > 0) {
    query += '(';
    query += columnsLike(
      argList: speakerSearchWords,
      comparisons: ['speaker'],
      mustContainAll: mustContainAll
    );
    query += ')';
  }

  if (onlyUnplayed == true) {
    query += ' AND isplayed = 0';
  }

  if (onlyFavorites == true) {
    query += ' AND isfavorite = 1';
  }

  if (onlyDownloaded == true) {
    query += ' AND isdownloaded = 1';
  }

  if (minLengthInMinutes != null && minLengthInMinutes > 0) {
    query += ' AND approximateminutes > ' + (minLengthInMinutes - 1).toString();
  }

  if (maxLengthInMinutes != null && maxLengthInMinutes > 0) {
    query += ' AND approximateminutes < ' + (maxLengthInMinutes + 1).toString();
  }

  if (!onlyReturnCount && start != null && end != null) {
    query += ' LIMIT ${(end - start).toString()} OFFSET ${start.toString()}';
  }

  return query;
}

Future<List<Message>> advancedSearch({
  required Database db,
  required String topicSearchTerm,  
  required String speakerSearchTerm,
  bool onlyUnplayed = false, 
  bool mustContainAll = true, 
  int? start, 
  int? end,
  String? language,
  String? location,
  int? minLengthInMinutes,
  int? maxLengthInMinutes,
  bool onlyFavorites = false,
  bool onlyDownloaded = false}) async {
    if (topicSearchTerm.length < 2 && speakerSearchTerm.length < 2) {
      return [];
    }
    List<String> topicSearchWords = searchArguments(topicSearchTerm);
    //print('topicSearchWords are ${topicSearchWords}');
    
    List<String> speakerSearchWords = searchArguments(speakerSearchTerm);
    //print('topicSearchWords are ${topicSearchWords} and speakerSearchWords are ${speakerSearchWords}');
    
    if (topicSearchWords.length < 1 && speakerSearchWords.length < 1) {
      return [];
    }

    String query = getAdvancedSearchQuery(
      topicSearchWords: topicSearchWords, 
      speakerSearchWords: speakerSearchWords,
      onlyReturnCount: false,
      onlyUnplayed: onlyUnplayed, 
      mustContainAll: mustContainAll, 
      start: start, 
      end: end,
      language: language,
      location: location,
      minLengthInMinutes: minLengthInMinutes,
      maxLengthInMinutes: maxLengthInMinutes,
      onlyFavorites: onlyFavorites,
      onlyDownloaded: onlyDownloaded);

    List<String> args = topicSearchWords;
    args.addAll(speakerSearchWords);
    print('query is ${query} and args are ${args}');

    try {
      var result = await db.rawQuery(query, args);

      if (result.isNotEmpty) {
        List<Message> messages = result.map((msgMap) => Message.fromMap(msgMap)).toList();
        print('Found ${messages.length} messages: ${messages}');
        return messages;
      }
      return [];
    } catch (error) {
      print('Error searching SQLite database: $error');
      return [];
    }
}

Future<int> advancedSearchCount({
  required Database db,
  required String topicSearchTerm,  
  required String speakerSearchTerm,
  bool onlyUnplayed = false, 
  bool mustContainAll = true, 
  int? start, 
  int? end,
  String? language,
  String? location,
  int? minLengthInMinutes,
  int? maxLengthInMinutes,
  bool onlyFavorites = false,
  bool onlyDownloaded = false}) async {
    if (topicSearchTerm.length < 2 && speakerSearchTerm.length < 2) {
      return 0;
    }
    List<String> topicSearchWords = searchArguments(topicSearchTerm);
    //print('topicSearchWords are ${topicSearchWords}');
    
    List<String> speakerSearchWords = searchArguments(speakerSearchTerm);
    //print('topicSearchWords are ${topicSearchWords} and speakerSearchWords are ${speakerSearchWords}');
    
    if (topicSearchWords.length < 1 && speakerSearchWords.length < 1) {
      return 0;
    }

    String query = getAdvancedSearchQuery(
      topicSearchWords: topicSearchWords, 
      speakerSearchWords: speakerSearchWords,
      onlyReturnCount: true,
      onlyUnplayed: onlyUnplayed, 
      mustContainAll: mustContainAll, 
      start: start, 
      end: end,
      language: language,
      location: location,
      minLengthInMinutes: minLengthInMinutes,
      maxLengthInMinutes: maxLengthInMinutes,
      onlyFavorites: onlyFavorites,
      onlyDownloaded: onlyDownloaded);

    List<String> args = topicSearchWords;
    args.addAll(speakerSearchWords);
    print('query is ${query} and args are ${args}');

    try {
      return Sqflite.firstIntValue(await db.rawQuery(query, args)) ?? 0;
    } catch (error) {
      print('Error searching SQLite database: $error');
      return 0;
    }
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