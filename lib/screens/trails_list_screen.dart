import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../services/trail_service.dart';
import '../widgets/trail_card.dart';

class TrailsListScreen extends StatefulWidget {
  const TrailsListScreen({super.key});
  @override
  State<TrailsListScreen> createState() => _TrailsListScreenState();
}

class _TrailsListScreenState extends State<TrailsListScreen> {
  String? _filterDifficulty;
  String _sortBy = 'length'; // or 'time'

  @override
  Widget build(BuildContext context) {
    // Stream with optional where/orderBy
    final stream = TrailService()
        .getTrailsFiltered(
          difficulty: _filterDifficulty,
          sortBy: _sortBy,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('All Trails')),
      body: Column(
        children: [
          // Filters row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Difficulty filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterDifficulty,
                    hint: const Text('All Difficulties'),
                    items: [
                      'Easy',
                      'Moderate',
                      'Difficult',
                    ].map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList()
                      ..insert(
                          0,
                          const DropdownMenuItem(
                              value: null, child: Text('All'))),
                    onChanged: (v) =>
                        setState(() => _filterDifficulty = v),
                  ),
                ),
                const SizedBox(width: 16),
                // Sort control
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(labelText: 'Sort by'),
                    items: const [
                      DropdownMenuItem(
                          value: 'length', child: Text('Length')),
                      DropdownMenuItem(value: 'time', child: Text('Time')),
                    ],
                    onChanged: (v) =>
                        setState(() => _sortBy = v!),
                  ),
                ),
              ],
            ),
          ),

          // List of trails
          Expanded(
            child: StreamBuilder<List<Trail>>(
              stream: stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final trails = snap.data!;
                if (trails.isEmpty) {
                  return const Center(child: Text('No trails found.'));
                }
                return ListView.builder(
                  itemCount: trails.length,
                  itemBuilder: (_, i) => TrailCard(trails[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
