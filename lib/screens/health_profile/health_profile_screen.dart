import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'health_profile_view.dart';
import 'health_profile_edit.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  bool _saving = false;
  bool _isEditing = false;

  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bloodSugarCtrl = TextEditingController();
  final _bpSystolicCtrl = TextEditingController();
  final _bpDiastolicCtrl = TextEditingController();
  final _chronicCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    for (final c in [
      _ageCtrl,
      _weightCtrl,
      _heightCtrl,
      _bloodSugarCtrl,
      _bpSystolicCtrl,
      _bpDiastolicCtrl,
      _chronicCtrl,
      _allergiesCtrl,
      _notesCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _loading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from('health_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        final fullName = user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            'Unknown User';

        if (data != null) {
          _ageCtrl.text = data['age'] ?? '';
          _weightCtrl.text = data['weight_kg'] ?? '';
          _heightCtrl.text = data['height_cm'] ?? '';
          _bloodSugarCtrl.text = data['blood_sugar'] ?? '';
          _bpSystolicCtrl.text = data['blood_pressure_systolic'] ?? '';
          _bpDiastolicCtrl.text = data['blood_pressure_diastolic'] ?? '';
          _chronicCtrl.text = data['chronic_diseases'] ?? '';
          _allergiesCtrl.text = data['allergies'] ?? '';

          _notesCtrl.text = data['medical_notes'] ?? '';
          _isEditing = false;
        } else {
          _isEditing = true;
        }
      }
    } catch (e) {
      debugPrint('Load Error: $e');
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveProfileData() async {
    setState(() => _saving = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw 'User not logged in';

      final fullName = user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          'Unknown User';

      await _supabase.from('health_profiles').upsert({
        'id': user.id,
        'age': _ageCtrl.text.trim(),
        'weight_kg': _weightCtrl.text.trim(),
        'height_cm': _heightCtrl.text.trim(),
        'blood_sugar': _bloodSugarCtrl.text.trim(),
        'blood_pressure_systolic': _bpSystolicCtrl.text.trim(),
        'blood_pressure_diastolic': _bpDiastolicCtrl.text.trim(),
        'chronic_diseases': _chronicCtrl.text.trim(),
        'allergies': _allergiesCtrl.text.trim(),
        'medical_notes': _notesCtrl.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        'full_name': fullName,
        'email': user.email,
      });

      if (mounted) {
        setState(() {
          _saving = false;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppTheme.destructive,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final userName = user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        'User';
    final userEmail = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile'.tr() : 'Health Profile'.tr()),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing && _ageCtrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _loadProfileData,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
              ? HealthProfileEdit(
                  isSaving: _saving,
                  onSave: _saveProfileData,
                  ageCtrl: _ageCtrl,
                  weightCtrl: _weightCtrl,
                  heightCtrl: _heightCtrl,
                  bloodSugarCtrl: _bloodSugarCtrl,
                  bpSystolicCtrl: _bpSystolicCtrl,
                  bpDiastolicCtrl: _bpDiastolicCtrl,
                  chronicCtrl: _chronicCtrl,
                  allergiesCtrl: _allergiesCtrl,
                  notesCtrl: _notesCtrl,
                )
              : HealthProfileView(
                  userName: userName,
                  userEmail: userEmail,
                  ageCtrl: _ageCtrl,
                  weightCtrl: _weightCtrl,
                  heightCtrl: _heightCtrl,
                  bloodSugarCtrl: _bloodSugarCtrl,
                  bpSystolicCtrl: _bpSystolicCtrl,
                  bpDiastolicCtrl: _bpDiastolicCtrl,
                  chronicCtrl: _chronicCtrl,
                  allergiesCtrl: _allergiesCtrl,
                  notesCtrl: _notesCtrl,
                ),
    );
  }
}
