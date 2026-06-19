import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_theme.dart';

class HealthProfileEdit extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  final String? avatarUrl;
  final bool isUploadingImage;
  final VoidCallback onPickImage;

  final TextEditingController fullNameCtrl;
  final TextEditingController phoneCtrl;

  final TextEditingController emergencyContact1Ctrl;
  final TextEditingController emergencyContact2Ctrl;

  final TextEditingController ageCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;
  final TextEditingController bloodSugarCtrl;
  final TextEditingController bpSystolicCtrl;
  final TextEditingController bpDiastolicCtrl;
  final TextEditingController chronicCtrl;
  final TextEditingController allergiesCtrl;
  final TextEditingController notesCtrl;

  const HealthProfileEdit({
    super.key,
    required this.isSaving,
    required this.onSave,
    required this.avatarUrl,
    required this.isUploadingImage,
    required this.onPickImage,
    required this.fullNameCtrl,
    required this.phoneCtrl,
    required this.emergencyContact1Ctrl, // 🌟
    required this.emergencyContact2Ctrl, // 🌟
    required this.ageCtrl,
    required this.weightCtrl,
    required this.heightCtrl,
    required this.bloodSugarCtrl,
    required this.bpSystolicCtrl,
    required this.bpDiastolicCtrl,
    required this.chronicCtrl,
    required this.allergiesCtrl,
    required this.notesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
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
            'Keep your health data up to date for personalized AI advice.'.tr(),
            style:
                theme.textTheme.bodyMedium?.copyWith(color: AppTheme.mutedFg),
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primary.withValues(alpha: .1),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: isUploadingImage
                      ? const CircularProgressIndicator()
                      : (avatarUrl == null
                          ? const Icon(Icons.person,
                              size: 50, color: AppTheme.primary)
                          : null),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onPickImage,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary,
                      child:
                          Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _Section('Basic Information'.tr()),
          _Field('Full Name'.tr(), fullNameCtrl, hint: 'e.g. Fadi Emad'),
          const SizedBox(height: 12),
          _Field('Phone Number'.tr(), phoneCtrl,
              hint: 'e.g. 01000000000', type: TextInputType.phone),
          const SizedBox(height: 20),
          _Section('Emergency Contacts (Family)'.tr()),
          _Field('Primary Contact'.tr(), emergencyContact1Ctrl,
              hint: 'e.g. 01000000000', type: TextInputType.phone),
          const SizedBox(height: 12),
          _Field('Secondary Contact (Optional)'.tr(), emergencyContact2Ctrl,
              hint: 'e.g. 01100000000', type: TextInputType.phone),
          const SizedBox(height: 20),
          _Section('Body Metrics'.tr()),
          Row(children: [
            Expanded(
                child: _Field('Age'.tr(), ageCtrl,
                    suffix: 'yrs'.tr(), type: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(
                child: _Field('Weight'.tr(), weightCtrl,
                    suffix: 'kg'.tr(), type: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(
                child: _Field('Height'.tr(), heightCtrl,
                    suffix: 'cm'.tr(), type: TextInputType.number)),
          ]),
          const SizedBox(height: 20),
          _Section('Vital Signs'.tr()),
          _Field('Blood Sugar'.tr(), bloodSugarCtrl,
              suffix: 'mg_dl'.tr(), type: TextInputType.number),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _Field('BP Systolic'.tr(), bpSystolicCtrl,
                    suffix: 'mmhg'.tr(), type: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(
                child: _Field('BP Diastolic'.tr(), bpDiastolicCtrl,
                    suffix: 'mmhg'.tr(), type: TextInputType.number)),
          ]),
          const SizedBox(height: 20),
          _Section('Medical History'.tr()),
          _Field('Chronic Diseases'.tr(), chronicCtrl,
              hint: 'chronic_hint'.tr(), maxLines: 2),
          const SizedBox(height: 12),
          _Field('Allergies'.tr(), allergiesCtrl,
              hint: 'allergies_hint'.tr(), maxLines: 2),
          const SizedBox(height: 12),
          _Field('Notes'.tr(), notesCtrl, hint: 'notes_hint'.tr(), maxLines: 3),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Save Health Profile'.tr()),
            ),
          ),
        ],
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
