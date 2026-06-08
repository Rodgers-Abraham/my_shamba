import 'package:flutter/material.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../injection_container.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class WeatherWidget extends StatefulWidget {
  final String ward;

  const WeatherWidget({super.key, required this.ward});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  WeatherEntity? _weather;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() => _isLoading = true);
    final repo = sl<WeatherRepository>();
    final result = await repo.getWeather(widget.ward);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        result.fold(
          (failure) => _error = failure.message,
          (weather) => _weather = weather,
        );
      });
    }
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code >= 1 && code <= 3) return Icons.cloud_queue_rounded;
    if (code >= 45 && code <= 48) return Icons.water;
    if (code >= 51 && code <= 67) return Icons.water_drop;
    if (code >= 71 && code <= 82) return Icons.ac_unit;
    if (code >= 95) return Icons.thunderstorm;
    return Icons.cloud;
  }

  String _getWeatherCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1) return 'Mainly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code >= 45 && code <= 48) return 'Fog';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 82) return 'Snow';
    if (code >= 95) return 'Thunderstorm';
    return 'Cloudy';
  }

  void _showWeeklyForecast(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '7-Day Forecast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _weather!.dailyForecast.length,
                  itemBuilder: (context, index) {
                    final daily = _weather!.dailyForecast[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              index == 0 ? 'Today' : DateFormat('EEEE').format(daily.date),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(_getWeatherIcon(daily.weatherCode), color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  _getWeatherCondition(daily.weatherCode),
                                  style: const TextStyle(color: AppTheme.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${daily.maxTemp.round()}° / ${daily.minTemp.round()}°',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _weather == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
        child: Text('Could not load weather: $_error', style: TextStyle(color: Colors.red.shade700)),
      );
    }

    return GestureDetector(
      onTap: () => _showWeeklyForecast(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withAlpha(200), Colors.lightBlue.withAlpha(150)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha(70),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.ward,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getWeatherCondition(_weather!.weatherCode),
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_weather!.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _getWeatherIcon(_weather!.weatherCode),
                  size: 72,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.white.withAlpha(50),
            ),
            const SizedBox(height: 16),
            // 24-Hour Forecast
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _weather!.hourlyForecast.length,
                itemBuilder: (context, index) {
                  final hourly = _weather!.hourlyForecast[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          index == 0 ? 'Now' : DateFormat('HH:mm').format(hourly.time),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        Icon(
                          _getWeatherIcon(hourly.weatherCode),
                          color: Colors.white,
                          size: 24,
                        ),
                        Text(
                          '${hourly.temperature.round()}°',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _weather!.actionHint,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
