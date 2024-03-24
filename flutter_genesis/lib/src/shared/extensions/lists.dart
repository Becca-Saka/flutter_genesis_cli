extension EnumListExtension on List<Enum> {
  List<String> get names => (this).map((e) => e.name).toList();
}

extension ListExtension on List {
  String get joined => join(',');
  String get spacedJoined => join(', ');
  List<T> getValuesAtIndexes<T>(List<int> indexes) {
    List<T> result = [];
    for (int index in indexes) {
      if (index >= 0 && index < this.length) {
        result.add(this[index]);
      }
    }
    return result;
  }
}
