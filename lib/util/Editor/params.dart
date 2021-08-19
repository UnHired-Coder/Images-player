import 'dart:collection';
import 'dart:convert';

import 'package:pdfconverter/util/Editor/outputFormat.dart';
abstract class Ignorable{
  bool get canIgnore;
}
abstract class EncodedValue implements Ignorable{
  String get key;
  Map<String, dynamic> get encodedValue;
}
abstract class Param implements Ignorable, EncodedValue{
  Param();
}


class ImageEditorParams implements Ignorable{
  ImageEditorParams();

  OutputFormat outputFormat = OutputFormat.jpeg(95);

  List<Param> get options {
    List<Param> result = [];
    for (final group in groupList) {
      for (final opt in group) {
        result.add(opt);
      }
    }
    return result;
  }

  List<ParamGroup> groupList = [];

  void reset() {
    groupList.clear();
  }

  void addOption(Param param, {bool newGroup = false}) {
    ParamGroup group;
    if (groupList.isEmpty || newGroup) {
      group = ParamGroup();
      groupList.add(group);
    } else {
      group = groupList.last;
    }

    group.addParam(param);
  }

  void addOptions(List<Param> options, {bool newGroup = true}) {
    ParamGroup group;
    if (groupList.isEmpty || newGroup) {
      group = ParamGroup();
      groupList.add(group);
    } else {
      group = groupList.last;
    }
    group.addParams(options);
  }

  List<Map<String, Object>> toJson() {
    List<Map<String, Object>> result = [];
    for (final option in options) {
      if (option.canIgnore) {
        continue;
      }
      result.add({
        "type": option.key,
        "value": option.encodedValue,
      });
    }
    return result;
  }

  @override
  bool get canIgnore {
    for (final opt in options) {
      if (!opt.canIgnore) {
        return false;
      }
    }
    return true;
  }

  String toString() {
    final m = <String, dynamic>{};
    m['options'] = toJson();
    m['fmt'] = outputFormat.toJson();
    return JsonEncoder.withIndent('  ').convert(m);
  }
}


class ParamGroup extends ListBase<Param> implements Ignorable{
  final List<Param> params =[];

  void addParam(Param param){
    this.params.add(param);
  }

  void addParams(List<Param> params){
    this.params.addAll(params);
  }

  @override
  bool get canIgnore {
    for(final param in params){
      if(!param.canIgnore)
         return false;
    }
    return true;
  }

  @override
  int get length => params.length;

  @override
  set length(int l){
    params.length = length;
  }

  @override
  Param operator [](int index) {
    return params[index];
  }

  @override
  void operator []=(int index, Param value) {
    params[index] = value;
  }
}