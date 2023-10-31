extension Capitalize on String {

  String titleCase() {
    return replaceFirst(this[0], this[0].toUpperCase(),0);
  }

  String removePercentage() {
     String str = replaceFirst("%", "",0);
     return str.replaceFirst("%", "",str.length-1);
  }

}