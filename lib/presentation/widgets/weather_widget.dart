import 'package:flutter/material.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../injection_container.dart';
import '../../core/theme/app_theme.dart';

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
  String _viewMode = 'Daily'; // Hourly, Daily, Weekly

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _weather == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
        child: Text('Could not load weather: $_error', style: TextStyle(color: Colors.red.shade700)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weather in ${widget.ward}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'As of ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              _buildConditionIcon(),
            ],
          ),
          const SizedBox(height: 12),
          // Toggle Buttons
          Center(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Hourly', label: Text('Hourly')),
                ButtonSegment(value: 'Daily', label: Text('Daily')),
                ButtonSegment(value: 'Weekly', label: Text('Weekly')),
              ],
              selected: {_viewMode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _viewMode = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTheme.primary.withOpacity(0.2),
                selectedForegroundColor: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(
                _weather!.temperature > 28 ? Icons.thermostat : Icons.ac_unit, 
                '${_weather!.temperature}°C',
                _weather!.temperature > 28 ? "High" : (_weather!.temperature < 15 ? "Low" : "Optimal")
              ),
              _buildMetric(
                Icons.air, 
                '${_weather!.windSpeed} km/h',
                _weather!.windSpeed > 20 ? "High Winds" : "Calm"
              ),
              _buildMetric(
                Icons.umbrella, 
                '${_weather!.rainfallProbability}%',
                _weather!.rainfallProbability > 50 ? "Rain Alert" : "Dry"
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.tips_and_updates, color: AppTheme.success, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _viewMode == 'Weekly' ? 'Weekly forecast: Expect consistent rains.' : _weather!.actionHint,
                  style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionIcon() {
    if (_weather!.rainfallProbability > 50) return const Icon(Icons.cloudy_snowing, color: Colors.blue);
    if (_weather!.temperature > 28) return const Icon(Icons.wb_sunny, color: Colors.orange);
    return const Icon(Icons.wb_cloudy_outlined, color: Colors.blueGrey);
  }

  Widget _buildMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }
}
