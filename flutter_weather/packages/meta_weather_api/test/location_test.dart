import 'package:json_annotation/json_annotation.dart';
import 'package:meta_weather_api/meta_weather_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('throws CheckedFromJsonException when enum is unknwon', () {
        expect(
            () => Location.fromJson(<String, dynamic>{
                  'title': 'mock-title',
                  'location_type': 'unknown',
                  'latt_long': '-34.75,83.28',
                  'woeid': '44418'
                }),
            throwsA(isA<CheckedFromJsonException>()));
      });
    });
  });
}
