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
  if (searchTerm.length < 1) {
    return [];
  }
  // terms in quotes get separated out to be searched for exactly
  RegExp quotesMatch = RegExp(r'''[\"|'].+?[\"|']''');

  // strip out special characters
  RegExp specialCharsMatch = RegExp(r'[^a-zA-Z0-9 ]+');

  final termsInQuotes = quotesMatch.allMatches(searchTerm);
  String searchTermWithoutQuotes = searchTerm
                                      .replaceAll(quotesMatch, '')
                                      .replaceAll('"', '')
                                      .replaceAll("'", '')
                                      .replaceAll(specialCharsMatch, '');
  List<String> searchWords = searchTermWithoutQuotes.split(' ').where((w) => w.length >= 1).toList();
  
  for (Match m in termsInQuotes) {
    searchWords.add(m[0].toString()
                        .replaceAll('"', '')
                        .replaceAll("'", ''));
  }

  return (searchWords.map((w) => '%' + w + '%')).toList();
}

/*List<String> searchArguments(String searchTerm) {
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
}*/