import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/hike_log.dart';
import '../models/trail.dart';
import '../services/hike_log_service.dart';
import '../services/trail_service.dart';

class HikeLogFormScreen extends StatefulWidget {
  final HikeLog? existing; // null = new, non-null = edit
  const HikeLogFormScreen({super.key, this.existing});

  @override
  State<HikeLogFormScreen> createState() => _HikeLogFormScreenState();
}

class _HikeLogFormScreenState extends State<HikeLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Trail? _selectedTrail;
  DateTime _date = DateTime.now();
  final _notesCtrl = TextEditingController();
  int _rating = 3;
  File? _photoFile;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _date = e.date;
      _notesCtrl.text = e.notes;
      _rating = e.rating;
      // TODO: optionally display existing photoUrl
    }
  }

  Future<void> _pickPhoto() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) setState(() => _photoFile = File(result.path));
  }

  Future<String?> _uploadPhoto(String logId) async {
    if (_photoFile == null) return widget.existing?.photoUrl;
    setState(() => _uploading = true);
    final ref = FirebaseStorage.instance
        .ref('users/${HikeLogService().uid}/hike_photos/$logId.jpg');
    await ref.putFile(_photoFile!);
    final url = await ref.getDownloadURL();
    setState(() => _uploading = false);
    return url;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedTrail == null) return;
    final service = HikeLogService();
    final isNew = widget.existing == null;

    // Build a base log (old photoUrl is kept if editing)
    HikeLog log = HikeLog(
      id: widget.existing?.id ?? '',
      trailId: _selectedTrail!.id,
      date: _date,
      notes: _notesCtrl.text,
      rating: _rating,
      photoUrl: widget.existing?.photoUrl,
    );

    String id = log.id;
    if (isNew) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(service.uid)
          .collection('my_completed_hikes')
          .add(log.toFirestore());
      id = doc.id;
    } else {
      await service.updateLog(log);
    }

    // Upload new photo (if any) and update the log with that URL
    final uploadedUrl = await _uploadPhoto(id);
    if (uploadedUrl != null) {
      final updatedLog = HikeLog(
        id: id,
        trailId: log.trailId,
        date: log.date,
        notes: log.notes,
        rating: log.rating,
        photoUrl: uploadedUrl,
      );
      await service.updateLog(updatedLog);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.existing == null ? 'New Hike Log' : 'Edit Hike Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Trail dropdown
              StreamBuilder<List<Trail>>(
                stream: TrailService().getTrails(),
                builder: (ctx, snap) {
                  final trails = snap.data ?? [];
                  return DropdownButtonFormField<Trail>(
                    value: _selectedTrail,
                    hint: const Text('Select Trail'),
                    items: trails
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.name),
                            ))
                        .toList(),
                    onChanged: (t) => setState(() => _selectedTrail = t),
                    validator: (t) => t == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              // Date picker
              ListTile(
                title: Text(
                    'Date: ${_date.toLocal().toIso8601String().split('T').first}'),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _date = d);
                },
              ),
              const SizedBox(height: 16),
              // Notes
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLength: 200,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Rating stars
              Row(
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                    ),
                    onPressed: () => setState(() => _rating = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Photo picker & preview
              if (_photoFile != null)
                Image.file(_photoFile!, height: 150, fit: BoxFit.cover),
              TextButton.icon(
                icon: const Icon(Icons.photo),
                label: Text(_photoFile == null ? 'Pick Photo' : 'Change Photo'),
                onPressed: _pickPhoto,
              ),
              const SizedBox(height: 24),
              // Save button
              _uploading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
