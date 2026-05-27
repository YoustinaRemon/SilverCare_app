import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../providers/medication_provider.dart';

class AddMedicationSheet extends StatefulWidget {
  const AddMedicationSheet({super.key});

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _freqCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '08:00');
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _freqCtrl.dispose();
    _timeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeCtrl.text = '$hour:$minute';
      });
    }
  }

  Future<void> _saveMedication() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter medication name'.tr())),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = context.read<AuthService>().currentUser;

    if (user != null) {
      await context.read<MedicationProvider>().addMedication(user.id, {
        'name': name,
        'dosage': _dosageCtrl.text.trim(),
        'frequency': _freqCtrl.text.trim(),
        'schedule_time': _timeCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      });
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: kToolbarHeight),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add New Medication'.tr(),
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _AddField('Medication Name *'.tr(), _nameCtrl),
            _AddField('Dosage (e.g. 500mg)'.tr(), _dosageCtrl),
            _AddField('Frequency (e.g. Twice daily)'.tr(), _freqCtrl),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _timeCtrl,
                readOnly: true,
                onTap: _pickTime,
                decoration: InputDecoration(
                  labelText: 'Schedule Time'.tr(),
                  suffixIcon: const Icon(Icons.access_time_rounded,
                      color: AppTheme.primary),
                ),
              ),
            ),
            _AddField('Notes (Optional)'.tr(), _notesCtrl),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveMedication,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Save Medication'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  const _AddField(this.label, this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
