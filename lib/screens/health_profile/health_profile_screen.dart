import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'health_profile_view.dart'; // ⬅️ استيراد وضع العرض
import 'health_profile_edit.dart'; // ⬅️ استيراد وضع التعديل

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
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
    _loadLocalData();
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

  Future<void> _loadLocalData() async {
    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      _ageCtrl.text = prefs.getString('hp_age') ?? '';
      _weightCtrl.text = prefs.getString('hp_weight') ?? '';
      _heightCtrl.text = prefs.getString('hp_height') ?? '';
      _bloodSugarCtrl.text = prefs.getString('hp_blood_sugar') ?? '';
      _bpSystolicCtrl.text = prefs.getString('hp_bp_sys') ?? '';
      _bpDiastolicCtrl.text = prefs.getString('hp_bp_dia') ?? '';
      _chronicCtrl.text = prefs.getString('hp_chronic') ?? '';
      _allergiesCtrl.text = prefs.getString('hp_allergies') ?? '';
      _notesCtrl.text = prefs.getString('hp_notes') ?? '';

      if (_ageCtrl.text.isEmpty &&
          _weightCtrl.text.isEmpty &&
          _chronicCtrl.text.isEmpty) {
        _isEditing = true;
      } else {
        _isEditing = false;
      }
    } catch (e) {
      debugPrint('Load Error: $e');
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveLocalData() async {
    setState(() => _saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('hp_age', _ageCtrl.text.trim());
      await prefs.setString('hp_weight', _weightCtrl.text.trim());
      await prefs.setString('hp_height', _heightCtrl.text.trim());
      await prefs.setString('hp_blood_sugar', _bloodSugarCtrl.text.trim());
      await prefs.setString('hp_bp_sys', _bpSystolicCtrl.text.trim());
      await prefs.setString('hp_bp_dia', _bpDiastolicCtrl.text.trim());
      await prefs.setString('hp_chronic', _chronicCtrl.text.trim());
      await prefs.setString('hp_allergies', _allergiesCtrl.text.trim());
      await prefs.setString('hp_notes', _notesCtrl.text.trim());

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
            content: Text('error_saving'.tr(args: ['$e'])),
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
              onPressed: _loadLocalData,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
              // ⬅️ نداء لملف التعديل
              ? HealthProfileEdit(
                  isSaving: _saving,
                  onSave: _saveLocalData,
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
              // ⬅️ نداء لملف العرض
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
