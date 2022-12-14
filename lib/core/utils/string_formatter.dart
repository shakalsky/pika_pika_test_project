class StringFormatter {
  static String getIdFromUrl(String url) {
    final list = url.split('/');
    final idPosition = list.indexOf('pokemon') + 1;
    return list[idPosition];
  }

  static String convertListToDBString(List<String> entites) {
    String resultString = '';
    for (final element in entites) {
      resultString += '$element-';
    }
    resultString = resultString.substring(0, resultString.length - 1);
    return resultString;
  }

  static List<String> convertStringDBToList(String dBstring) {
    List<String> entites;
    entites = dBstring.split('-');
    return entites;
  }

  static List<String> convertApiMaptoList(dynamic apiMap) {
    final resultList = <String>[];
    if (apiMap != null) {
      for (final type in apiMap) {
        resultList.add(type['type']['name']);
      }
    }
    return resultList;
  }
}
