import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/error/failures.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final http.Client client;

  WeatherRepositoryImpl({required this.client});

  @override
  Future<Either<Failure, WeatherEntity>> getWeather(String ward) async {
    const double lat = -1.286389;
    const double long = 36.817223;

    try {
      final response = await client.get(
        Uri.parse(
            'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m,relative_humidity_2m,precipitation_probability,wind_speed_10m'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];

        final temp = (current['temperature_2m'] as num).toDouble();
        final humidity = (current['relative_humidity_2m'] as num).toInt();
        final rainProb = current['precipitation_probability'] ?? 0;
        final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;

        String hint = "Conditions are stable.";
        if (windSpeed > 25.0) {
          hint = "High winds: Secure loose structures and greenhouse plastics.";
        } else if (humidity > 80) {
          hint = "High humidity alert: Monitor crop leaves for fungal blight.";
        } else if (temp > 30 && rainProb < 20) {
          hint = "Dry and hot: Ensure adequate hydration for livestock.";
        } else if (rainProb > 60) {
          hint = "High rain probability: Delay chemical spraying.";
        } else if (temp < 15) {
          hint = "Low temperatures: Provide warm bedding for young livestock.";
        }

        return Right(WeatherEntity(
          temperature: temp,
          rainfallProbability: rainProb as int,
          humidity: humidity,
          windSpeed: windSpeed,
          actionHint: hint,
        ));
      } else {
        return Left(ServerFailure('Failed to fetch weather data.'));
      }
    } catch (e) {
      return Left(ServerFailure('Network connection error: ${e.toString()}'));
    }
  }
}
