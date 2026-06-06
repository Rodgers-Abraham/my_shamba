import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/geography_parser.dart';
import '../bloc/farm_bloc.dart';
import '../bloc/farm_event.dart';
import '../bloc/farm_state.dart';
import '../widgets/main_navigation_shell.dart';
import '../../core/theme/app_theme.dart';

class FarmSetupScreen extends StatefulWidget {
  final String ownerId;
  const FarmSetupScreen({super.key, required this.ownerId});

  @override
  State<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends State<FarmSetupScreen> {
  Map<String, Map<String, Map<String, List<String>>>>? _hierarchy;
  
  String? _selectedCounty;
  String? _selectedSubCounty;
  String? _selectedConstituency;
  String? _selectedWard;

  @override
  void initState() {
    super.initState();
    _loadGeography();
  }

  Future<void> _loadGeography() async {
    final data = await GeographyParser.parsePoliticalUnits();
    setState(() {
      _hierarchy = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hierarchy == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final counties = _hierarchy!.keys.toList()..sort();
    
    List<String> subCounties = [];
    if (_selectedCounty != null) {
      subCounties = _hierarchy![_selectedCounty]!.keys.toList()..sort();
    }

    List<String> constituencies = [];
    if (_selectedCounty != null && _selectedSubCounty != null) {
      constituencies = _hierarchy![_selectedCounty]![_selectedSubCounty]!.keys.toList()..sort();
    }

    List<String> wards = [];
    if (_selectedCounty != null && _selectedSubCounty != null && _selectedConstituency != null) {
      wards = _hierarchy![_selectedCounty]![_selectedSubCounty]![_selectedConstituency]!..sort();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Farm Location Setup')),
      body: BlocListener<FarmBloc, FarmState>(
        listener: (context, state) {
          if (state is FarmSetupSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainNavigationShell(farmId: state.farm.id)),
            );
          } else if (state is FarmError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Where is your farm located?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'This helps us provide localized weather and agronomy hints.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'County'),
                initialValue: _selectedCounty,
                items: counties.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCounty = val;
                    _selectedSubCounty = null;
                    _selectedConstituency = null;
                    _selectedWard = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sub-County'),
                initialValue: _selectedSubCounty,
                items: subCounties.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: _selectedCounty == null ? null : (val) {
                  setState(() {
                    _selectedSubCounty = val;
                    _selectedConstituency = null;
                    _selectedWard = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Constituency'),
                initialValue: _selectedConstituency,
                items: constituencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: _selectedSubCounty == null ? null : (val) {
                  setState(() {
                    _selectedConstituency = val;
                    _selectedWard = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ward'),
                initialValue: _selectedWard,
                items: wards.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: _selectedConstituency == null ? null : (val) {
                  setState(() {
                    _selectedWard = val;
                  });
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: BlocBuilder<FarmBloc, FarmState>(
                  builder: (context, state) {
                    if (state is FarmLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: (_selectedWard == null)
                          ? null
                          : () {
                              context.read<FarmBloc>().add(SetupFarmEvent(
                                ownerId: widget.ownerId,
                                county: _selectedCounty!,
                                subCounty: _selectedSubCounty!,
                                constituency: _selectedConstituency!,
                                ward: _selectedWard!,
                              ));
                            },
                      child: const Text('Complete Setup'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
