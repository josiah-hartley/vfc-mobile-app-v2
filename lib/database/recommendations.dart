import 'package:sqflite/sqflite.dart';
import 'package:voices_for_christ/data_models/message_class.dart';
import 'package:voices_for_christ/data_models/recommendation_class.dart';
import 'package:voices_for_christ/database/table_names.dart';

Future<void> updateRecommendationsBasedOnMessages({Database? db, List<Message?>? messages, bool subtract = false}) async {
  if (db == null || messages == null) {
    print('null Database object or Message list passed to updateRecommendationsBasedOnMessages()');
    return;
  }
  
  String update = subtract ? 'count=count-1' : 'count=count+1';
  try {
    await db.transaction((txn) async {
      Batch batch = txn.batch();

      for (Message? message in messages) {
        String values = '("${message?.speaker}", "speaker")';
        List<String>? tags = message?.taglist == '' ? [] : message?.taglist.split(',');
        tags?.forEach((tag) {
          if (tag.length > 0) {
            values += ', ("$tag", "tag")';
          }
        });

        batch.rawInsert('''
          INSERT INTO $recommendationsTable(label, type) VALUES $values
            ON CONFLICT(label) DO UPDATE SET $update
        ''');
      }

      await batch.commit();
    });
  } catch(error) {
    print('Error updating recommendations in database: $error');
  }
}

Future<List<Recommendation>> getRecommendations({Database? db, required int limit}) async {
  if (db == null) {
    print('null Database object passed to getRecommendations()');
    return [];
  }
  try {
    var result = await db.query(recommendationsTable, columns: ['label', 'type'], orderBy: 'count DESC', limit: limit);
    if (result.isNotEmpty) {
      List<Recommendation> recommendations = [];
      result.forEach((row) {
        recommendations.add(Recommendation.fromMap(row));
      });
      return recommendations;
    }
    return [];
  } catch(error) {
    print('Error getting recommendations from database: $error');
    return [];
  }
}