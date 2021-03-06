import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/theme/cubit/theme_cubit.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../helpers/hydrated_bloc.dart';

class MockWeather extends Mock implements Weather {
  MockWeather(this._condition);

  final WeatherCondition _condition;

  @override
  WeatherCondition get condition => _condition;
}

void main() {
  initHydratedBloc();
  group('ThemeCubit', () {
    late ThemeCubit themeCubit;

    setUp(() {
      themeCubit = ThemeCubit();
    });

    tearDown(() {
      themeCubit.close();
    });

    test('initial state is corrent', () {
      expect(themeCubit.state, ThemeCubit.defaultColor);
    });

    group('toJson/fromJson', () {
      test('work perperly', () {
        expect(themeCubit.fromJson(themeCubit.toJson(themeCubit.state)),
            themeCubit.state);
      });
    });

    group('updateTheme', () {
      final clearWeather = MockWeather(WeatherCondition.clear);
      final snowyWeather = MockWeather(WeatherCondition.snowy);
      final cloudyWeather = MockWeather(WeatherCondition.cloudy);
      final rainyWeather = MockWeather(WeatherCondition.rainy);
      final unknownWeather = MockWeather(WeatherCondition.unknown);
      blocTest<ThemeCubit, Color>(
          'emits correct color for WeatherCondition.clear',
          build: () => ThemeCubit(),
          act: (cubit) => cubit.updateTheme(clearWeather),
          expect: () => <Color>[Colors.orangeAccent]);

      blocTest<ThemeCubit, Color>(
          'emits correct color for WeatherCondition.snowy',
          build: () => ThemeCubit(),
          act: (cubit) => cubit.updateTheme(snowyWeather));

      blocTest<ThemeCubit, Color>(
          'emits correct color for WeatherCondition.cloudy',
          build: () => ThemeCubit(),
          act: (cubit) => cubit.updateTheme(cloudyWeather));

      blocTest<ThemeCubit, Color>(
          'emits correct color for WeatherCondition.rainy',
          build: () => ThemeCubit(),
          act: (cubit) => cubit.updateTheme(rainyWeather));

      blocTest<ThemeCubit, Color>(
          'emits correct color for WeatherCondition.snowy',
          build: () => ThemeCubit(),
          act: (cubit) => cubit.updateTheme(unknownWeather));
    });
  });
}
