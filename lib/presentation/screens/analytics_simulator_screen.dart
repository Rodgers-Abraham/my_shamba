import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';

class AnalyticsSimulatorScreen extends StatefulWidget {
  const AnalyticsSimulatorScreen({super.key});

  @override
  State<AnalyticsSimulatorScreen> createState() => _AnalyticsSimulatorScreenState();
}

class _AnalyticsSimulatorScreenState extends State<AnalyticsSimulatorScreen> {
  // Simulator State
  double _feedAmountKg = 5.0;
  double _waterVolumeL = 40.0;
  bool _showRainfallOverlay = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Intelligent Analytics & Simulator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yield vs Weather Correlation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Overlay rainfall data to understand how weather impacts your milk production.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            
            _buildCorrelationChart(),
            
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Overlay Rainfall Data'),
              subtitle: const Text('Shows blue bars behind the yield line'),
              value: _showRainfallOverlay,
              activeThumbColor: AppTheme.primary,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _showRainfallOverlay = val);
              },
            ),

            const Divider(height: 48),

            const Text('Predictive Yield Simulator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Adjust inputs to forecast expected daily yield and profit margins.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 24),

            _buildSimulatorCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text('${v.toInt()}L', style: const TextStyle(fontSize: 10)))),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(days[value.toInt()], style: const TextStyle(fontSize: 10)));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 15), FlSpot(1, 16), FlSpot(2, 14), FlSpot(3, 18), FlSpot(4, 20), FlSpot(5, 19), FlSpot(6, 22),
              ],
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: _showRainfallOverlay 
                ? BarAreaData(
                    show: true,
                    color: Colors.blue.withValues(alpha: 0.3),
                    cutOffY: 0,
                    applyCutOffY: true,
                  ) 
                : BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatorCard() {
    double projectedYield = (_feedAmountKg * 2.5) + (_waterVolumeL * 0.1);
    double projectedProfit = (projectedYield * 50) - (_feedAmountKg * 40); // 50 KES/L milk, 40 KES/kg feed

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withValues(alpha: 0.9), AppTheme.accent.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Projected Daily Yield', style: TextStyle(color: Colors.white, fontSize: 16)),
              Text('${projectedYield.toStringAsFixed(1)} L', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Est. Net Profit', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
              Text('KES ${projectedProfit.toStringAsFixed(0)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          
          _buildSlider('Dairy Meal Feed (Kg)', _feedAmountKg, 1.0, 10.0, (val) {
            setState(() => _feedAmountKg = val);
            HapticFeedback.selectionClick();
          }),
          const SizedBox(height: 16),
          _buildSlider('Water Volume (Liters)', _waterVolumeL, 10.0, 100.0, (val) {
            setState(() => _waterVolumeL = val);
            HapticFeedback.selectionClick();
          }),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white38,
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
            trackHeight: 6.0,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
