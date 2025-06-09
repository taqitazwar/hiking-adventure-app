// lib/screens/trails_list_screen.dart

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
  String _sortBy = 'Length ↑';

  static const _sortOptions = <String>[
    'Length ↑',
    'Length ↓',
    'Time ↑',
    'Time ↓',
  ];

  @override
  Widget build(BuildContext context) {
    final stream = TrailService().getTrails();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Trails'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortBy,
              items: _sortOptions
                  .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _sortBy = v);
              },
              icon: const Icon(Icons.sort, color: Colors.white),
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Trail>>(
        stream: stream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final trails = snap.data ?? [];

          // Apply client-side sort
          switch (_sortBy) {
            case 'Length ↑':
              trails.sort((a, b) => a.length.compareTo(b.length));
              break;
            case 'Length ↓':
              trails.sort((a, b) => b.length.compareTo(a.length));
              break;
            case 'Time ↑':
              trails.sort((a, b) => a.time.compareTo(b.time));
              break;
            case 'Time ↓':
              trails.sort((a, b) => b.time.compareTo(a.time));
              break;
          }

          if (trails.isEmpty) {
            return const Center(child: Text('No trails found.'));
          }
          return ListView.builder(
            itemCount: trails.length,
            itemBuilder: (ctx, i) => TrailCard(trails[i]),
          );
        },
      ),
    );
  }
}
