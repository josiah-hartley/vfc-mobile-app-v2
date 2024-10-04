// note: sql search uses 'LIKE %name%', so there's no need
// to add replacements for names that just add letters,
// like from 'steve' to 'steven' (but 'steve' to 'stephen' is necessary)
List<String> variations(String name) {
  final Map<String, List<String>> replacements = {
    'albert': ['al'],

    'alex': ['alec'],
    'alexander': ['alex', 'alec'],
    'alec': ['alex'],

    'alan': ['allan', 'allen'],
    'allan': ['alan', 'allen'],
    'allen': ['alan', 'allan'],

    'alfred': ['al'],

    'andrew': ['andy'],
    'andy': ['andrew'],

    'anthony': ['tony'],
    'tony': ['anthony'],

    'arnold': ['arnie'],
    'arnie': ['arnold'],

    'arthur': ['art'],

    'benjamin': ['ben'],

    'bradley': ['brad'],

    'bryan': ['brian'],
    'brian': ['bryan'],

    'charles': ['charlie', 'chuck', 'carlos'],
    'chuck': ['charles', 'charlie'],
    'charlie': ['charles', 'chuck'],
    'carlos': ['carl'],

    'clifford': ['cliff'],

    'daniel': ['dan'],
    'danny': ['dan'],

    'david': ['dave'],
    'dave': ['david'],

    'derek': ['derick', 'derrick'],

    'donald': ['don'],

    'douglas': ['doug'],

    'dwayne': ['duane'],
    'duane': ['dwayne'],

    'edward': ['ed', 'ted', 'eduardo'],
    'ted': ['ed'],
    'edwin': ['ed'],

    'ernest': ['ernie'],

    'eugene': ['gene'],

    'francis': ['frank'],
    'frank': ['francis'],

    'frasier': ['fraser'],

    'gerald': ['jerry', 'gerry'],
    'jerry': ['gerry', 'gerald'],
    'gerry': ['jerry', 'gerald'],

    'glenn': ['glen'],

    'gregory': ['greg'],
    'greggory': ['greg'],

    'harold': ['harry'],
    'harry': ['harold'],

    'herbert': ['herb'],

    'howard': ['howie'],
    'howie': ['howard'],

    'james': ['jim'],
    'jim': ['james'],
    'jimmy': ['jim', 'james'],

    'jeffrey': ['geoff', 'jeff'],
    'geoffrey': ['geoff', 'jeff'],
    'jeff': ['geoff'],

    'jon': ['john', 'jonathan'],
    'jonathan': ['jon', 'john'],
    'john': ['jon', 'jonathan', 'jack'],
    'jack': ['john'],
    'jonny': ['john', 'jon'],
    'jonnie': ['john', 'jon'],
    'johnny': ['john', 'jon'],

    'joseph': ['joe'],
    'joe': ['joseph'],
    'joey': ['joe', 'joseph'],

    'kenneth': ['ken'],
    'kenny': ['ken'],

    'larry': ['lawrence', 'laurence'],
    'lawrence': ['larry', 'laurence'],
    'laurence': ['larry', 'lawrence'],

    'leslie': ['les'],

    'lewis': ['lew'],

    'mark': ['marc'],
    'marc': ['mark'],

    'matthew': ['matt'],

    'mike': ['michael'],
    'michael': ['mike'],

    'nathan': ['nate'],
    'nate': ['nathan'],
    'nathaniel': ['nathan', 'nate'],
    'nathanael': ['nathan', 'nate'],

    'patrick': ['pat'],
    
    'peter': ['pete'],

    'philip': ['phil'],
    'phillip': ['phil'],

    'randal': ['randy'],
    'randy': ['randal'],
    'randall': ['randal', 'randy'],

    'raymond': ['ray'],

    'reginald': ['reggie'],
    'reggie': ['reginald'],

    'richard': ['rich', 'rick', 'dick'],
    'rich': ['rick', 'dick'],
    'rick': ['rich', 'dick'],
    'dick': ['rich, rick'],
    'richie': ['rich', 'rick', 'dick'],

    'robert': ['bob', 'rob', 'bert'],
    'bob': ['rob'],
    'robbie': ['bob', 'rob'],
    'roberto': ['bob', 'rob'],
    'robby': ['bob', 'rob'],
    'bert': ['bob', 'rob'],

    'ronald': ['ron'],

    'samuel': ['sam'],
    'sammy': ['sam'],

    'shawn': ['sean'],
    'sean': ['shawn'],

    'stanley': ['stan'],

    'steven': ['steve', 'stephen'],
    'stephen': ['steve'],
    'steve': ['stephen'],

    'stewart': ['stuart'],
    'stuart': ['stewart'],

    'timothy': ['tim'],

    'thomas': ['tom'],
    'tom': ['thomas'],

    'walter': ['walt'],
    
    'william': ['will', 'bill'],
    'will': ['bill'],
    'bill': ['will'],
    'willy': ['will', 'bill'],
    'willie': ['will', 'bill'],
  };
  return replacements[name] ?? [];
}