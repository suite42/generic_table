extension Capitalize on String {

  String titleCase() {
    return replaceFirst(this[0], this[0].toUpperCase(),0);
  }

  String removePercentage() {
     String str = replaceFirst("%25", "",0);
     return str.replaceFirst("%25", "",str.length-3);
  }

  String encodeUrl() {
    String str = replaceAll("&", "%26");
    return str;
  }

}