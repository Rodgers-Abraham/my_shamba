import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/ledger_entry_entity.dart';
import '../bloc/ledger_bloc.dart';
import '../widgets/add_ledger_entry_dialog.dart';

class LedgerScreen extends StatefulWidget {
  final String farmId;
  const LedgerScreen({super.key, required this.farmId});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LedgerBloc>().add(LoadEntries(widget.farmId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Cash Ledger & Finance')),
      body: BlocListener<LedgerBloc, LedgerState>(
        listener: (context, state) {
          if (state is LedgerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<LedgerBloc, LedgerState>(
          builder: (context, state) {
            if (state is LedgerLoading) return const Center(child: CircularProgressIndicator());
            
            if (state is LedgerLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryHeader(state.entries),
                    const SizedBox(height: 24),
                    const Text('Seasonal Analytics (Rolling 12 Months)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTrendChart(),
                    const SizedBox(height: 24),
                    const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.entries.length,
                      itemBuilder: (context, index) {
                        final entry = state.entries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: entry.category == 'Income' 
                                  ? AppTheme.success.withOpacity(0.1) 
                                  : Colors.red.withOpacity(0.1),
                              child: Icon(
                                entry.category == 'Income' ? Icons.arrow_downward : Icons.arrow_upward,
                                color: entry.category == 'Income' ? AppTheme.success : Colors.red,
                              ),
                            ),
                            title: Text(entry.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${entry.date.toString().substring(0, 10)}${entry.associatedParty != null ? ' • ${entry.associatedParty}' : ''}'),
                            trailing: Text(
                              '${entry.category == 'Income' ? '+' : '-'} KES ${entry.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: entry.category == 'Income' ? AppTheme.success : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No ledger entries found.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showAddEntryDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryHeader(List<LedgerEntryEntity> entries) {
    double income = entries.where((e) => e.category == 'Income').fold(0, (sum, e) => sum + e.amount);
    double expense = entries.where((e) => e.category == 'Expense').fold(0, (sum, e) => sum + e.amount);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _buildMetricCard('Money In', income, AppTheme.success, Icons.account_balance_wallet)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Money Out', expense, Colors.red, Icons.money_off)),
      ],
    );
  }

  Widget _buildMetricCard(String label, double value, Color color, IconData icon) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text('KES ${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      );

  Widget _buildTrendChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 16, top: 16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Text(months[value.toInt()], style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade200)),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 30), FlSpot(1, 40), FlSpot(2, 35), FlSpot(3, 50), FlSpot(4, 45), FlSpot(5, 60),
              ],
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppTheme.primary.withOpacity(0.1)),
            ),
            LineChartBarData(
              spots: const [
                FlSpot(0, 20), FlSpot(1, 25), FlSpot(2, 40), FlSpot(3, 30), FlSpot(4, 25), FlSpot(5, 35),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddLedgerEntryDialog(farmId: widget.farmId),
    );
  }
}
