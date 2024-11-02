import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:dynamodb/dynamodb.dart';

void main() {
  group('Converting', () {
    test('convert back and forth between JSON and DynamoDB Input/Output', () {
      final jsonPayload = {
        'foo': true,
        'bar': 'baz',
        'fizz': {
          'buzz1': Uint8List(1),
          'buzz2': ['stringyDingy'],
          'buzz3': [Uint8List(1)],
          'buzz4': [1, 2, 3],
          'buzz5': {'foo', 'bar', 'baz'},
        },
        'noCreativity': null
      };
      final fromJsonToAttributeValue = jsonPayload.fromJsonToAttributeValue();

      final midCheck = {
        'foo': {'BOOL': true},
        'bar': {'S': 'baz'},
        'fizz': {
          'M': {
            'buzz1': {'B': 'AA=='},
            'buzz2': {
              'L': [
                {'S': 'stringyDingy'}
              ]
            },
            'buzz3': {
              'BS': ['AA==']
            },
            'buzz4': {
              'NS': ['1', '2', '3']
            },
            'buzz5': {
              'SS': {'foo', 'bar', 'baz'}
            }
          }
        },
        'noCreativity': {'NULL': true}
      };

      expect(
          jsonDecode(jsonEncode(fromJsonToAttributeValue)), equals(midCheck));

      final fromAttributeValueToJson = fromJsonToAttributeValue.toJson();

      expect(fromAttributeValueToJson, equals(jsonPayload));
    });
  });
}