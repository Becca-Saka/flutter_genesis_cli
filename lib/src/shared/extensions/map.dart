extension MapExtension on Map {
  Map get removeNullValues {
    return this.entries.fold<Map>({}, (result, entry) {
      if (entry.value is Map) {
        // result[entry.key] = (entry.value as Map).removeNullValues;
        // result[entry.key] = entry.value. removeNullValues(entry.value);
        var nestedMap = (entry.value as Map).removeNullValues;
        if (nestedMap.isNotEmpty) {
          result[entry.key] = nestedMap;
        }
      } else if (entry.value != null) {
        result[entry.key] = entry.value;
      }
      return result;
    });
  }
}
