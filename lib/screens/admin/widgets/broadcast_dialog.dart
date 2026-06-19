import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../theme/app_theme.dart';

Future<void> showBroadcastDialog(
    BuildContext context, SupabaseClient supabase) async {
  final TextEditingController msgCtrl = TextEditingController();
  bool isSending = false;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.campaign_rounded, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Broadcast Alert'.tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Send a general notification to all registered patients. This will appear instantly on their dashboard.'
                      .tr(),
                  style: const TextStyle(color: AppTheme.mutedFg, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: msgCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Severe heatwave expected tomorrow. Please stay hydrated...'
                            .tr(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSending ? null : () => Navigator.pop(context),
                child: Text('Cancel'.tr(),
                    style: const TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isSending
                    ? null
                    : () async {
                        final msg = msgCtrl.text.trim();
                        if (msg.isEmpty) return;

                        setDialogState(() => isSending = true);
                        try {
                          await supabase
                              .from('broadcast_alerts')
                              .insert({'message': msg});
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Alert sent successfully to all patients!'
                                        .tr()),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSending = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppTheme.destructive),
                            );
                          }
                        }
                      },
                child: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Send Alert'.tr()),
              ),
            ],
          );
        },
      );
    },
  );
}
