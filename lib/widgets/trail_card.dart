import 'package:flutter/material.dart';
import '../models/trail.dart';

/// A card that displays basic info about a Trail.
class TrailCard extends StatelessWidget {
  final Trail trail;
  const TrailCard(this.trail, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          trail.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${trail.location} · ${trail.difficulty} · ${trail.length.toStringAsFixed(1)} km',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to Trail detail screen
        },
      ),
    );
  }
}
