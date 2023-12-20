class FilterListModel {
  FilterListModel({required this.filterData});

  List<Filter> filterData;

  List<List<String>> filtersList () {
    List<List<String>> localList = [];
    for(final data in filterData!) {
      localList.add([data.key!,data.filterType!,data.value!]);
    }
    return localList;
  }
  List<List<String>> fullFiltersList () {
    List<List<String>> localList = [];
    for(final data in filterData!) {
      localList.add([data.key,data.filterType,data.value,data.name]);
    }
    return localList;
  }
}

class Filter {
  Filter({required this.key,required this.filterType,required this.value,required this.name});

  String key;
  String filterType;
  String value;
  String name;

}