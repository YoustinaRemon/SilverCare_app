import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _db = Supabase.instance.client;

  bool _loading = true;
  bool _saving = false;
  bool _saved = false;

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
    _load();
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

  Future<void> _load() async {
    setState(() => _loading = true);

    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final data = await _db
          .from('health_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && mounted) {
        _ageCtrl.text = '${data['age'] ?? ''}';
        _weightCtrl.text = '${data['weight_kg'] ?? ''}';
        _heightCtrl.text = '${data['height_cm'] ?? ''}';
        _bloodSugarCtrl.text = '${data['blood_sugar'] ?? ''}';
        _bpSystolicCtrl.text = '${data['blood_pressure_systolic'] ?? ''}';
        _bpDiastolicCtrl.text = '${data['blood_pressure_diastolic'] ?? ''}';
        _chronicCtrl.text = data['chronic_diseases'] ?? '';
        _allergiesCtrl.text = data['allergies'] ?? '';
        _notesCtrl.text = data['notes'] ?? '';
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      setState(() => _saving = false);
      return;
    }

    try {
      await _db.from('health_profiles').upsert({
        'id': user.id,
        'age': int.tryParse(_ageCtrl.text),
        'weight_kg': double.tryParse(_weightCtrl.text),
        'height_cm': double.tryParse(_heightCtrl.text),
        'blood_sugar': double.tryParse(_bloodSugarCtrl.text),
        'blood_pressure_systolic': int.tryParse(_bpSystolicCtrl.text),
        'blood_pressure_diastolic': int.tryParse(_bpDiastolicCtrl.text),
        'chronic_diseases': _chronicCtrl.text.trim(),
        'allergies': _allergiesCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() {
          _saving = false;
          _saved = true;
        });
      }

      Future.delayed(
        const Duration(seconds: 2),
        () => mounted ? setState(() => _saved = false) : null,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_saving'.tr(args: ['$e']))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Profile'.tr()),
        actions: [
          if (_saved)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle_rounded, color: AppTheme.primary),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Health Profile'.tr(),
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep your health data up to date for personalized AI advice.'
                        .tr(),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.mutedFg),
                  ),
                  const SizedBox(height: 24),
                  _Section('Basic Information'.tr()),
                  Row(children: [
                    Expanded(
                      child: _Field('Age'.tr(), _ageCtrl,
                          suffix: 'yrs'.tr(), type: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field('Weight'.tr(), _weightCtrl,
                          suffix: 'kg'.tr(), type: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field('Height'.tr(), _heightCtrl,
                          suffix: 'cm'.tr(), type: TextInputType.number),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _Section('Vital Signs'.tr()),
                  _Field('Blood Sugar'.tr(), _bloodSugarCtrl,
                      suffix: 'mg_dl'.tr(), type: TextInputType.number),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _Field('BP Systolic'.tr(), _bpSystolicCtrl,
                          suffix: 'mmhg'.tr(), type: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field('BP Diastolic'.tr(), _bpDiastolicCtrl,
                          suffix: 'mmhg'.tr(), type: TextInputType.number),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _Section('Medical History'.tr()),
                  _Field(
                    'Chronic Diseases'.tr(),
                    _chronicCtrl,
                    hint: 'chronic_hint'.tr(),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    'Allergies'.tr(),
                    _allergiesCtrl,
                    hint: 'allergies_hint'.tr(),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    'Notes'.tr(),
                    _notesCtrl,
                    hint: 'notes_hint'.tr(),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Save Health Profile'.tr()),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String? suffix, hint;
  final TextInputType type;
  final int maxLines;

  const _Field(
    this.label,
    this.ctrl, {
    this.suffix,
    this.hint,
    this.type = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
      ),
    );
  }
}
