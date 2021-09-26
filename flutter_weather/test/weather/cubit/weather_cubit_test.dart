// ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

import '../../helpers/hydrated_bloc.dart';

const weatherLocation = 'London';
const weatherCondition = weather_repository.WeatherCondition.rainy;
const weatherTemperature = 9.8;

class MockWeatherRepository extends Mock
    implements weather_repository.WeatherRepository {}

class MockWeather extends Mock implements weather_repository.Weather {}

void main() {
  group('WeatherCubit', () {
    late weather_repository.Weather weather;
    late weather_repository.WeatherRepository weatherRepository;
    late WeatherCubit weatherCubit;

    setUpAll(initHydratedBloc);

    setUp(() {
      weather = MockWeather();
      weatherRepository = MockWeatherRepository();
      when(() => weather.condition).thenReturn(weatherCondition);
      when(() => weather.location).thenReturn(weatherLocation);
      when(() => weather.temperature).thenReturn(weatherTemperature);
      when(() => weatherRepository.getWeather(any()))
          .thenAnswer((_) async => weather);
      weatherCubit = WeatherCubit(weatherRepository);
    });

    tearDown(() {
      weatherCubit.close();
    });

    test('initial state is correct', () {
      expect(weatherCubit.state, WeatherState());
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        expect(
          weatherCubit.fromJson(weatherCubit.toJson(weatherCubit.state)),
          weatherCubit.state,
        );
      });
    });

    group('fetchWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is null',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(null),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is empty',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(''),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>('calls getWeather with correct city',
          build: () => weatherCubit,
          act: (cubit) => cubit.fetchWeather(weatherLocation),
          verify: (_) {
            verify(() => weatherRepository.getWeather(weatherLocation))
                .called(1);
          });
      blocTest<WeatherCubit, WeatherState>(
          'emits [loading, failure] when getWeather throws',
          build: () {
            when(() => weatherRepository.getWeather(any()))
                .thenThrow(Exception('oops'));
            return weatherCubit;
          },
          act: (cubit) => cubit.fetchWeather(weatherLocation),
          expect: () => <WeatherState>[
                WeatherState(status: WeatherStatus.loading),
                WeatherState(status: WeatherStatus.failure),
              ]);
      blocTest<WeatherCubit, WeatherState>(
          'emits [loading, success] when getWeather returns (celsius)',
          build: () => weatherCubit,
          act: (cubit) => cubit.fetchWeather(weatherLocation),
          expect: () => <dynamic>[
                WeatherState(status: WeatherStatus.loading),
                isA<WeatherState>()
                    .having((w) => w.status, 'status', WeatherStatus.success)
                    .having(
                        (w) => w.weather,
                        'weather',
                        isA<Weather>()
                            .having(
                                (w) => w.lastUpdated, 'lastUpdated', isNotNull)
                            .having((w) => w.condition, 'condition',
                                weatherCondition)
                            .having((w) => w.temperature, 'temperature',
                                Temperature(value: weatherTemperature))
                            .having(
                                (w) => w.location, 'location', weatherLocation))
              ]);
    });
  });
}

extension on double {
  double toFahrenheit() => ((this * 9 / 5) + 32);
  double toCelsius() => ((this - 32) * 5 / 9);
}
