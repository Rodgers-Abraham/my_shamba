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
            'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m,relative_humidity_2m,precipitation_probability,wind_speed_10m,weather_code&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=7'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final hourlyData = data['hourly'];
        final dailyData = data['daily'];

        final temp = (current['temperature_2m'] as num).toDouble();
        final humidity = (current['relative_humidity_2m'] as num).toInt();
        final rainProb = current['precipitation_probability'] ?? 0;
        final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
        final weatherCode = current['weather_code'] ?? 0;

        List<HourlyForecast> hourly = [];
        if (hourlyData != null) {
          final times = hourlyData['time'] as List;
          final temps = hourlyData['temperature_2m'] as List;
          final codes = hourlyData['weather_code'] as List;
          
          // Get next 24 hours starting from current time
          final now = DateTime.now();
          int startIndex = 0;
          for (int i = 0; i < times.length; i++) {
             if (DateTime.parse(times[i]).isAfter(now)) {
                 startIndex = i > 0 ? i - 1 : i;
                 break;
             }
          }

          for (int i = startIndex; i < startIndex + 24 && i < times.length; i++) {
            hourly.add(HourlyForecast(
              time: DateTime.parse(times[i]),
              temperature: (temps[i] as num).toDouble(),
              weatherCode: codes[i] as int,
            ));
          }
        }

        List<DailyForecast> daily = [];
        if (dailyData != null) {
          final dates = dailyData['time'] as List;
          final maxTemps = dailyData['temperature_2m_max'] as List;
          final minTemps = dailyData['temperature_2m_min'] as List;
          final codes = dailyData['weather_code'] as List;

          for (int i = 0; i < dates.length; i++) {
            daily.add(DailyForecast(
              date: DateTime.parse(dates[i]),
              maxTemp: (maxTemps[i] as num).toDouble(),
              minTemp: (minTemps[i] as num).toDouble(),
              weatherCode: codes[i] as int,
            ));
          }
        }

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
          weatherCode: weatherCode as int,
          hourlyForecast: hourly,
          dailyForecast: daily,
        ));
      } else {
        return Left(ServerFailure('Failed to fetch weather data.'));
      }
    } catch (e) {
      return Left(ServerFailure('Network connection error: ${e.toString()}'));
    }
  }
}
