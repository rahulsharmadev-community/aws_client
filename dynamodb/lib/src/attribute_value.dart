


import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_aws_api/shared.dart' as _s;

/// Represents the data for an attribute.
///
/// Each attribute value is described as a name-value pair. The name is the data
/// type, and the value is the data itself.
///
/// For more information, see <a
/// href="https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.NamingRulesDataTypes.html#HowItWorks.DataTypes">Data
/// Types</a> in the <i>Amazon DynamoDB Developer Guide</i>.
class AttributeValue {
  /// An attribute of type Binary. For example:
  ///
  /// <code>"B": "dGhpcyB0ZXh0IGlzIGJhc2U2NC1lbmNvZGVk"</code>
  final Uint8List? b;

  /// An attribute of type Boolean. For example:
  ///
  /// <code>"BOOL": true</code>
  final bool? boolValue;

  /// An attribute of type Binary Set. For example:
  ///
  /// <code>"BS": ["U3Vubnk=", "UmFpbnk=", "U25vd3k="]</code>
  final List<Uint8List>? bs;

  /// An attribute of type List. For example:
  ///
  /// <code>"L": [ {"S": "Cookies"} , {"S": "Coffee"}, {"N": "3.14159"}]</code>
  final List<AttributeValue>? l;

  /// An attribute of type Map. For example:
  ///
  /// <code>"M": {"Name": {"S": "Joe"}, "Age": {"N": "35"}}</code>
  final Map<String, AttributeValue>? m;

  /// An attribute of type Number. For example:
  ///
  /// <code>"N": "123.45"</code>
  ///
  /// Numbers are sent across the network to DynamoDB as strings, to maximize
  /// compatibility across languages and libraries. However, DynamoDB treats them
  /// as number type attributes for mathematical operations.
  final String? n;

  /// An attribute of type Number Set. For example:
  ///
  /// <code>"NS": ["42.2", "-19", "7.5", "3.14"]</code>
  ///
  /// Numbers are sent across the network to DynamoDB as strings, to maximize
  /// compatibility across languages and libraries. However, DynamoDB treats them
  /// as number type attributes for mathematical operations.
  final List<String>? ns;

  /// An attribute of type Null. For example:
  ///
  /// <code>"NULL": true</code>
  final bool? nullValue;

  /// An attribute of type String. For example:
  ///
  /// <code>"S": "Hello"</code>
  final String? s;

  /// An attribute of type String Set. For example:
  ///
  /// <code>"SS": ["Giraffe", "Hippo" ,"Zebra"]</code>
  final List<String>? ss;

  AttributeValue({
    this.b,
    this.boolValue,
    this.bs,
    this.l,
    this.m,
    this.n,
    this.ns,
    this.nullValue,
    this.s,
    this.ss,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      b: _s.decodeNullableUint8List(json['B'] as String?),
      boolValue: json['BOOL'] as bool?,
      bs: (json['BS'] as List?)
          ?.nonNulls
          .map((e) => _s.decodeUint8List(e as String))
          .toList(),
      l: (json['L'] as List?)
          ?.nonNulls
          .map((e) => AttributeValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      m: (json['M'] as Map<String, dynamic>?)?.map((k, e) =>
          MapEntry(k, AttributeValue.fromJson(e as Map<String, dynamic>))),
      n: json['N'] as String?,
      ns: (json['NS'] as List?)?.nonNulls.map((e) => e as String).toList(),
      nullValue: json['NULL'] as bool?,
      s: json['S'] as String?,
      ss: (json['SS'] as List?)?.nonNulls.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (b != null) 'B': base64Encode(b!),
      if (boolValue != null) 'BOOL': boolValue,
      if (bs != null) 'BS': bs!.map(base64Encode).toList(),
      if (l != null) 'L': l,
      if (m != null) 'M': m,
      if (n != null) 'N': n,
      if (ns != null) 'NS': ns,
      if (nullValue != null) 'NULL': nullValue,
      if (s != null) 'S': s,
      if (ss != null) 'SS': ss,
    };
  }
}

AttributeValue toAttributeValue(dynamic value) {
  if (value == null) {
    return AttributeValue(nullValue: true);
  } else if (value is AttributeValue) {
    return value;
  } else if (value is bool) {
    return AttributeValue(boolValue: value);
  } else if (value is String) {
    return AttributeValue(s: value);
  } else if (value is int || value is double) {
    return AttributeValue(n: value.toString());
  } else if (value is List<Uint8List>) {
    return AttributeValue(bs: value);
  } else if (value is Uint8List) {
    return AttributeValue(b: value);
  } else if (value is List<num>) {
    return AttributeValue(ns: value.map((e) => e.toString()).toList());
  } else if (value is Set<String>) {
    return AttributeValue(ss: value.toList());
  } else if (value is List) {
    return AttributeValue(l: value.map(toAttributeValue).toList().cast());
  } else if (value is Map<String, dynamic>) {
    return AttributeValue(
        m: value.map((k, v) => MapEntry(k, toAttributeValue(v))));
  } else {
    return toAttributeValue(value.toJson());
  }
}

dynamic toDartType(AttributeValue value) {
  if (value.nullValue ?? false) {
    return null;
  } else if (value.n != null) {
    return double.parse(value.n!);
  } else if (value.s != null) {
    return value.s;
  } else if (value.boolValue != null) {
    return value.boolValue;
  } else if (value.b != null) {
    return value.b;
  } else if (value.l != null) {
    return value.l!.map(toDartType).toList();
  } else if (value.m != null) {
    return value.m!.map((k, v) => MapEntry(k, toDartType(v)));
  } else if (value.ns != null) {
    return value.ns!.map(double.parse).toList();
  } else if (value.bs != null) {
    return value.bs;
  } else if (value.ss != null) {
    return value.ss!.toSet();
  }
}

extension AttributeTranslator on Map<String, AttributeValue>? {
  Map<String, dynamic>? toJson() {
    return this?.toJson();
  }
}

extension AttributeTranslatorNonNullable on Map<String, AttributeValue> {
  Map<String, dynamic> toJson() {
    return map((key, value) => MapEntry(key, toDartType(value)));
  }
}

extension DynamicTranslator on Map<String, dynamic>? {
  Map<String, AttributeValue>? fromJsonToAttributeValue() {
    return this?.fromJsonToAttributeValue();
  }
}

extension DynamicTranslatorNonNull on Map<String, dynamic> {
  Map<String, AttributeValue> fromJsonToAttributeValue() {
    return map((key, value) => MapEntry(key, toAttributeValue(value)));
  }
}
