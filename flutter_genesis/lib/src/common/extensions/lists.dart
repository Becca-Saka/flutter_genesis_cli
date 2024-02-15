extension EnumListExtension on List<Enum> {
  List<String> get names => (this).map((e) => e.name).toList();
}

extension ListExtension on List {
  String get joined => join(',');
}
