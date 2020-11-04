import 'dart:convert';

import 'package:fast_i18n/src/model.dart';

/// parses the config.i18n.json file
/// returns an I18Config object
I18nConfig parseConfig(String content) {
  Map<String, dynamic> map = json.decode(content);
  String baseLocale = map['baseLocale'] ?? '';
  List<String> maps = (map['maps'] ?? []).cast<String>();
  return I18nConfig(baseLocale, maps);
}

/// parses a json of one locale
/// returns an I18nData object
I18nData parseJSON(
    I18nConfig config, String baseName, String locale, String content) {
  Map<String, dynamic> map = json.decode(content);
  Map<String, Value> destination = Map();
  _parseJSONObject(config.maps, map, destination, []);
  return I18nData(config, baseName, locale, ObjectNode(destination, false));
}

void _parseJSONObject(List<String> maps, Map<String, dynamic> curr,
    Map<String, Value> destination, List<String> stack) {
  curr.forEach((key, value) {
    if (value is String) {
      // key: 'value'
      destination[key] = TextNode(value);
    } else if (value is List) {
      // key: [ ...value ]
      List<Value> list = List();
      _parseJSONArray(maps, value, list, stack);
      destination[key] = ListNode(list);
    } else {
      // key: { ...value }
      List<String> nextStack = [...stack, key];
      String stackAsString = nextStack.join('.');
      bool mapMode = maps.contains(stackAsString);
      Map<String, Value> subDestination = Map();
      _parseJSONObject(maps, value, subDestination, nextStack);
      destination[key] = ObjectNode(subDestination, mapMode);
    }
  });
}

void _parseJSONArray(List<String> maps, List<dynamic> curr,
    List<Value> destination, List<String> stack) {
  for (dynamic value in curr) {
    if (value is String) {
      // key: 'value'
      destination.add(TextNode(value));
    } else if (value is List) {
      // key: [ ...value ]
      List<Value> list = List();
      _parseJSONArray(maps, value, list, stack);
      destination.add(ListNode(list));
    } else {
      // key: { ...value }
      String stackAsString = stack.join('.');
      bool mapMode = maps.contains(stackAsString);
      Map<String, Value> subDestination = Map();
      _parseJSONObject(maps, value, subDestination, stack);
      destination.add(ObjectNode(subDestination, mapMode));
    }
  }
}
