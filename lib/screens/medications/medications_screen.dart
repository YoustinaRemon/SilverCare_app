import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/medication_provider.dart';

import '../../widgets/status_chip.dart';
import '../../widgets/medication_card.dart';
import '../../widgets/add_medication_sheet.dart';

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

  Future<void> _logMedication(String medId, String status) async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    await context
        .read<MedicationProvider>()
        .logMedication(user.id, medId, status);
  }

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
      builder: (context) => const AddMedicationSheet(),
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
                    StatusChip(
                      label: '${takenIds.length} ${'Taken'.tr()}',
                      color: AppTheme.primary,
                      icon: Icons.check_circle_rounded,
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: '${skippedIds.length} ${'Skipped'.tr()}',
                      color: AppTheme.destructive,
                      icon: Icons.cancel_rounded,
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label:
                          '${medications.length - takenIds.length - skippedIds.length} ${'Pending'.tr()}',
                      color: AppTheme.amber,
                      icon: Icons.access_time_rounded,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  ...medications.map((med) => MedicationCard(
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
