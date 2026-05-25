import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationProvider extends ChangeNotifier {
  final _db = Supabase.instance.client;

  static const _defaults = [
    {
      'id': 'd1',
      'name': 'Metformin',
      'dosage': '500mg',
      'frequency': 'Twice daily',
      'schedule_time': '08:00',
      'notes': 'Take with meals'
    },
    {
      'id': 'd2',
      'name': 'Lisinopril (Blood Pressure)',
      'dosage': '10mg',
      'frequency': 'Once daily',
      'schedule_time': '09:00',
      'notes': 'Check BP weekly'
    },
    {
      'id': 'd3',
      'name': 'Vitamin D3',
      'dosage': '1000 IU',
      'frequency': 'Once daily',
      'schedule_time': '09:00',
      'notes': 'Take with fatty food'
    },
    {
      'id': 'd4',
      'name': 'Aspirin',
      'dosage': '81mg',
      'frequency': 'Once daily',
      'schedule_time': '20:00',
      'notes': 'Take with a full glass of water'
    },
    {
      'id': 'd5',
      'name': 'Insulin Glargine',
      'dosage': '15 units',
      'frequency': 'Once daily',
      'schedule_time': '21:00',
      'notes': 'Subcutaneous injection'
    },
  ];

  List<Map<String, dynamic>> _medications = List.from(_defaults);
  Set<String> _takenIds = {};
  Set<String> _skippedIds = {};
  bool _loading = false;

  List<Map<String, dynamic>> get medications => _medications;
  Set<String> get takenIds => _takenIds;
  Set<String> get skippedIds => _skippedIds;
  bool get loading => _loading;

  Future<void> load(String userId) async {
    _loading = true;
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final prefs = await SharedPreferences.getInstance();

      final localTaken = prefs.getStringList('local_taken_$today') ?? [];
      final localSkipped = prefs.getStringList('local_skipped_$today') ?? [];

      final localCustomMedsStr = prefs.getString('local_custom_meds_$userId');
      List<Map<String, dynamic>> localCustomMeds = [];
      if (localCustomMedsStr != null) {
        final decoded = jsonDecode(localCustomMedsStr) as List;
        localCustomMeds = decoded.cast<Map<String, dynamic>>();
      }

      final results = await Future.wait([
        _db.from('medications').select().eq('user_id', userId),
        _db
            .from('medication_logs')
            .select()
            .eq('user_id', userId)
            .gte('taken_at', today),
      ]);

      final userMeds = (results[0] as List).cast<Map<String, dynamic>>();
      final logs = (results[1] as List).cast<Map<String, dynamic>>();

      _medications = [..._defaults, ...localCustomMeds, ...userMeds];

      _takenIds = logs
          .where((l) => l['status'] == 'taken')
          .map((l) => l['medication_id'] as String)
          .toSet();
      _takenIds.addAll(localTaken);

      _skippedIds = logs
          .where((l) => l['status'] == 'skipped')
          .map((l) => l['medication_id'] as String)
          .toSet();
      _skippedIds.addAll(localSkipped);
    } catch (e) {
      debugPrint("🚨 Error Loading Medications: $e");
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> logMedication(String userId, String medId, String status) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final prefs = await SharedPreferences.getInstance();

    if (status == 'taken') {
      _takenIds.add(medId);
      _skippedIds.remove(medId);
    } else {
      _skippedIds.add(medId);
      _takenIds.remove(medId);
    }
    notifyListeners();

    if (medId.startsWith('d') || medId.startsWith('local_')) {
      await _saveLocalLogs(prefs, today);
      return;
    }

    try {
      await _db.from('medication_logs').upsert({
        'user_id': userId,
        'medication_id': medId,
        'status': status,
        'taken_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("🚨 Error Logging Medication: $e");
    }
  }

  Future<void> resetMedication(String userId, String medId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final prefs = await SharedPreferences.getInstance();

    _takenIds.remove(medId);
    _skippedIds.remove(medId);
    notifyListeners();

    if (medId.startsWith('d') || medId.startsWith('local_')) {
      await _saveLocalLogs(prefs, today);
      return;
    }

    try {
      await _db
          .from('medication_logs')
          .delete()
          .eq('user_id', userId)
          .eq('medication_id', medId)
          .gte('taken_at', today);
    } catch (e) {
      debugPrint("🚨 Error Resetting Medication: $e");
    }
  }

  Future<void> addMedication(String userId, Map<String, dynamic> med) async {
    final newLocalId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final newMed = {
      'id': newLocalId,
      'user_id': userId,
      ...med,
    };

    _medications.add(newMed);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final localCustomMedsStr = prefs.getString('local_custom_meds_$userId');

    List<dynamic> localCustomMeds = [];
    if (localCustomMedsStr != null) {
      localCustomMeds = jsonDecode(localCustomMedsStr);
    }

    localCustomMeds.add(newMed);
    await prefs.setString(
        'local_custom_meds_$userId', jsonEncode(localCustomMeds));
  }

  Future<void> _saveLocalLogs(SharedPreferences prefs, String today) async {
    final localTaken = _takenIds
        .where((id) => id.startsWith('d') || id.startsWith('local_'))
        .toList();
    final localSkipped = _skippedIds
        .where((id) => id.startsWith('d') || id.startsWith('local_'))
        .toList();
    await prefs.setStringList('local_taken_$today', localTaken);
    await prefs.setStringList('local_skipped_$today', localSkipped);
  }
}
