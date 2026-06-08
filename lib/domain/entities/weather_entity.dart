import 'package:equatable/equatable.dart';

class HourlyForecast extends Equatable {
  final DateTime time;
  final double temperature;
  final int weatherCode;

  const HourlyForecast({required this.time, required this.temperature, required this.weatherCode});

  @override
  List<Object?> get props => [time, temperature, weatherCode];
}

class DailyForecast extends Equatable {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  const DailyForecast({required this.date, required this.maxTemp, required this.minTemp, required this.weatherCode});

  @override
  List<Object?> get props => [date, maxTemp, minTemp, weatherCode];
}

class WeatherEntity extends Equatable {
  final double temperature;
  final int rainfallProbability;
  final int humidity;
  final double windSpeed;
  final String actionHint;
  final int weatherCode;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  const WeatherEntity({
    required this.temperature,
    required this.rainfallProbability,
    required this.humidity,
    required this.windSpeed,
    required this.actionHint,
    this.weatherCode = 0,
    this.hourlyForecast = const [],
    this.dailyForecast = const [],
  });

  @override
  List<Object?> get props => [temperature, rainfallProbability, humidity, windSpeed, actionHint, weatherCode, hourlyForecast, dailyForecast];
}
