import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/medication_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      await context.read<MedicationProvider>().load(user.id);
    }
    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  // ✅ FIX: إزالة .tr() من قيمة الـ status عشان متتبعتش قيمة مترجمة للـ DB
  Future<void> _logMedication(String medId, String status) async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    await context
        .read<MedicationProvider>()
        .logMedication(user.id, medId, status);
  }

  // ✅ NEW: دالة reset ترجع الدواء لحالة Pending
  Future<void> _resetMedication(String medId) async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    await context.read<MedicationProvider>().resetMedication(user.id, medId);
  }

  void _showAddMedicationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddMedicationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medProvider = context.watch<MedicationProvider>();
    final medications = medProvider.medications;
    final takenIds = medProvider.takenIds;
    final skippedIds = medProvider.skippedIds;

    return Scaffold(
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Medications'.tr(),
                      style: theme.textTheme.displayMedium),
                  const SizedBox(height: 4),
                  Text('Track and manage your daily medications'.tr(),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.mutedFg)),
                  const SizedBox(height: 20),
                  Row(children: [
                    _Chip('${takenIds.length} ${'Taken'.tr()}',
                        AppTheme.primary, Icons.check_circle_rounded),
                    const SizedBox(width: 8),
                    _Chip('${skippedIds.length} ${'Skipped'.tr()}',
                        AppTheme.destructive, Icons.cancel_rounded),
                    const SizedBox(width: 8),
                    _Chip(
                        '${medications.length - takenIds.length - skippedIds.length} ${'Pending'.tr()}',
                        AppTheme.amber,
                        Icons.access_time_rounded),
                  ]),
                  const SizedBox(height: 20),
                  // ✅ FIX: onTake و onSkip بيبعتوا قيم ثابتة مش مترجمة
                  // ✅ NEW: onReset callback مضاف
                  ...medications.map((med) => _MedCard(
                        med: med,
                        isTaken: takenIds.contains(med['id']),
                        isSkipped: skippedIds.contains(med['id']),
                        onTake: () => _logMedication(med['id'], 'taken'),
                        onSkip: () => _logMedication(med['id'], 'skipped'),
                        onReset: () => _resetMedication(med['id']),
                      )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicationSheet(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Add Medication'.tr()),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AddMedicationSheet
// ---------------------------------------------------------------------------

class _AddMedicationSheet extends StatefulWidget {
  const _AddMedicationSheet();

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
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
      // ✅ FIX: المفاتيح في الـ map ثابتة (مش مترجمة) عشان تتطابق مع الـ DB
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

// ---------------------------------------------------------------------------
// _AddField
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// _MedCard  ✅ FIX + NEW
// ---------------------------------------------------------------------------

class _MedCard extends StatelessWidget {
  final Map<String, dynamic> med;
  final bool isTaken;
  final bool isSkipped;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  // ✅ NEW: callback لإرجاع الدواء لحالة Pending
  final VoidCallback onReset;

  const _MedCard({
    required this.med,
    required this.isTaken,
    required this.isSkipped,
    required this.onTake,
    required this.onSkip,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor = AppTheme.amber;
    if (isTaken) statusColor = AppTheme.primary;
    if (isSkipped) statusColor = AppTheme.destructive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.medication_rounded,
                      color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med['name'] ?? '',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text('${med['dosage'] ?? ''} · ${med['frequency'] ?? ''}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppTheme.mutedFg)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.access_time_rounded,
                        size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(med['schedule_time'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),

            // ── Notes ──
            if (med['notes'] != null && med['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(med['notes'],
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppTheme.mutedFg)),
            ],

            const SizedBox(height: 12),

            // ── Actions ──
            if (!isTaken && !isSkipped)
              // ✅ FIX: ترتيب الأزرار واضح — Skip على الشمال، Take على اليمين
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSkip,
                    icon: const Icon(Icons.close, size: 16),
                    label: Text('Skip'.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.destructive,
                      side: const BorderSide(color: AppTheme.destructive),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTake,
                    icon: const Icon(Icons.check, size: 16),
                    label: Text('Taken'.tr()),
                  ),
                ),
              ])
            else
              // ✅ NEW: Status label + زرار Undo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(
                      isTaken
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: isTaken ? AppTheme.primary : AppTheme.destructive,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isTaken ? 'Marked as taken'.tr() : 'Skipped'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isTaken ? AppTheme.primary : AppTheme.destructive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                  // ✅ NEW: زرار Undo
                  TextButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.undo_rounded, size: 14),
                    label: Text('Undo'.tr()),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.mutedFg,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Chip
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _Chip(this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
