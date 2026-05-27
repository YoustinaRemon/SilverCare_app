import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

const _companions = [
  {
    'id': '1',
    'name': 'Sarah Muller',
    'skills': 'Nursing, Cooking',
    'languages': 'English, German',
    'personality': 'Patient, Cheerful',
    'rating': 4.9,
    'avatar':
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
  },
  {
    'id': '2',
    'name': 'David Weber',
    'skills': 'Physiotherapy, Driving',
    'languages': 'German, French',
    'personality': 'Active, Attentive',
    'rating': 4.8,
    'avatar':
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
  },
  {
    'id': '3',
    'name': 'Fatima Ali',
    'skills': 'Dementia care, Reading',
    'languages': 'Arabic, English',
    'personality': 'Empathetic, Calm',
    'rating': 5.0,
    'avatar':
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&q=80',
  },
];

class CompanionsScreen extends StatefulWidget {
  const CompanionsScreen({super.key});

  @override
  State<CompanionsScreen> createState() => _CompanionsScreenState();
}

class _CompanionsScreenState extends State<CompanionsScreen> {
  final _db = Supabase.instance.client;

  Set<String> _booked = {};

  bool _loading = true;

  String? _bookingSuccess;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
    });

    final user = context.read<AuthService>().currentUser;

    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final data = await _db
          .from('companion_bookings')
          .select('companion_id')
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _booked =
              (data as List).map((b) => b['companion_id'] as String).toSet();

          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _book(String companionId, String name) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final user = authService.currentUser;

    if (user == null) return;

    try {
      await _db.from('companion_bookings').insert({
        'user_id': user.id,
        'companion_id': companionId,
        'status': 'pending',
        'scheduled_date': DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0],
      });

      setState(() {
        _booked.add(companionId);

        _bookingSuccess = 'has been booked!'.tr(args: [name]);
      });

      Future.delayed(
        const Duration(seconds: 3),
        () {
          if (mounted) {
            setState(() {
              _bookingSuccess = null;
            });
          }
        },
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Booking failed'.tr(args: ['$e']),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Companion'.tr()),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Find a Companion'.tr(),
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'We match you with trusted companions to visit and spend quality time.'
                      .tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedFg,
                  ),
                ),
                const SizedBox(height: 20),
                if (_bookingSuccess != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: .3),
                      ),
                    ),
                    child: Text(
                      _bookingSuccess!,
                      style: const TextStyle(
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ..._companions.map(
                  (c) => _CompanionCard(
                    companion: c,
                    isBooked: _booked.contains(c['id']),
                    onBook: () {
                      _book(
                        c['id'] as String,
                        c['name'] as String,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _CompanionCard extends StatelessWidget {
  final Map<String, dynamic> companion;

  final bool isBooked;

  final VoidCallback onBook;

  const _CompanionCard({
    required this.companion,
    required this.isBooked,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rating = companion['rating'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(companion['avatar'] as String),
                  onBackgroundImageError: (_, __) {},
                  backgroundColor: AppTheme.muted,
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companion['name'] as String,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppTheme.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rating',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companion['personality'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow(
              Icons.medical_information_rounded,
              companion['skills'] as String,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              Icons.translate_rounded,
              companion['languages'] as String,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isBooked
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.primary,
                      ),
                      label: Text(
                        'booked'.tr(),
                        style: const TextStyle(
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: onBook,
                      icon: const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                      ),
                      label: Text(
                        'Book Companion'.tr(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;

  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
