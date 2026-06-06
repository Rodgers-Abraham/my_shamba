import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final double temperature;
  final int rainfallProbability;
  final int humidity;
  final double windSpeed;
  final String actionHint;

  const WeatherEntity({
    required this.temperature,
    required this.rainfallProbability,
    required this.humidity,
    required this.windSpeed,
    required this.actionHint,
  });

  @override
  List<Object?> get props => [temperature, rainfallProbability, humidity, windSpeed, actionHint];
}
