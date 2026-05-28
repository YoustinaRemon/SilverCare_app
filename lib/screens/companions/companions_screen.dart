import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';

const _mockCompanions = [
  {
    'id': 'mock_1',
    'name': 'Sarah Muller',
    'skills': ['Nursing', 'Cooking', 'First Aid'],
    'languages': ['English', 'German'],
    'personality': 'Patient & Cheerful',
    'rating': 4.9,
    'reviews': 124,
    'avatar':
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
  },
  {
    'id': 'mock_2',
    'name': 'David Weber',
    'skills': ['Physiotherapy', 'Driving'],
    'languages': ['German', 'French'],
    'personality': 'Active & Attentive',
    'rating': 4.7,
    'reviews': 89,
    'avatar':
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
  },
  {
    'id': 'mock_3',
    'name': 'Fatima Ali',
    'skills': ['Dementia Care', 'Reading', 'Storytelling'],
    'languages': ['Arabic', 'English'],
    'personality': 'Empathetic & Calm',
    'rating': 5.0,
    'reviews': 210,
    'avatar':
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&q=80',
  },
  {
    'id': 'mock_4',
    'name': 'James Miller',
    'skills': ['Mobility Assistance', 'Errands'],
    'languages': ['English', 'Spanish'],
    'personality': 'Strong & Reliable',
    'rating': 4.6,
    'reviews': 45,
    'avatar':
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
  },
  {
    'id': 'mock_5',
    'name': 'Aisha Rahman',
    'skills': ['Meal Prep', 'Medication Reminder'],
    'languages': ['English', 'Urdu'],
    'personality': 'Caring & Organized',
    'rating': 4.8,
    'reviews': 156,
    'avatar':
        'https://images.unsplash.com/photo-1531123897727-8f129e1bf98c?w=200&q=80',
  },
  {
    'id': 'mock_6',
    'name': 'Lucas Silva',
    'skills': ['Physical Therapy', 'Fitness'],
    'languages': ['English', 'Portuguese'],
    'personality': 'Energetic & Motivating',
    'rating': 4.9,
    'reviews': 178,
    'avatar':
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&q=80',
  },
];

class CompanionsScreen extends StatefulWidget {
  const CompanionsScreen({super.key});

  @override
  State<CompanionsScreen> createState() => _CompanionsScreenState();
}

class _CompanionsScreenState extends State<CompanionsScreen> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _displayList = [];
  Set<String> _booked = {};
  bool _loading = true;
  String? _bookingSuccess;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      Set<String> bookedIds = {};

      List<Map<String, dynamic>> combinedList =
          List<Map<String, dynamic>>.from(_mockCompanions);

      try {
        final dbCompanions = await _supabase.from('companions').select();
        for (var c in dbCompanions) {
          combinedList.add({
            'id': c['id'].toString(),
            'name': c['name'] ?? 'Unknown',
            'skills': c['skills'] ?? [],
            'languages': c['languages'] ?? [],
            'personality': c['personality'] ?? 'Friendly',
            'rating': c['rating'] ?? 5.0,
            'reviews': c['reviews'] ?? 0,
            'avatar': c['avatar'] ??
                'https://cdn-icons-png.flaticon.com/512/847/847969.png',
          });
        }
      } catch (e) {
        debugPrint('No companions table yet or error fetching: $e');
      }

      if (userId != null) {
        final myBookings = await _supabase
            .from('companion_bookings')
            .select('companion_id')
            .eq('user_id', userId);

        for (var b in myBookings) {
          if (b['companion_id'] != null) {
            bookedIds.add(b['companion_id'].toString());
          }
        }
      }

      if (mounted) {
        setState(() {
          _displayList = combinedList;
          _booked = bookedIds;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _book(String compId, String compName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _booked.add(compId);
      _bookingSuccess = 'has been booked!'.tr(args: [compName]);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _bookingSuccess = null);
    });

    try {
      await _supabase.from('companion_bookings').insert({
        'user_id': userId,
        'companion_id': compId,
        'companion_name': compName,
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('Booking error: $e');
      if (mounted) {
        setState(() => _booked.remove(compId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book: $e')),
        );
      }
    }
  }

  Future<void> _undo(String compId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _booked.remove(compId);
    });

    try {
      await _supabase
          .from('companion_bookings')
          .delete()
          .eq('user_id', userId)
          .eq('companion_id', compId);
    } catch (e) {
      debugPrint('Undo error: $e');
      if (mounted) setState(() => _booked.add(compId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Find Companion'.tr())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Available Companions'.tr(),
                    style: theme.textTheme.displayMedium
                        ?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Choose the perfect match for your needs'.tr(),
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                if (_bookingSuccess != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_bookingSuccess!,
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),

                // هنا بنعرض القايمة المدمجة (الوهمي + الحقيقي)
                ..._displayList.map((c) => _CompanionCard(
                      companion: c,
                      isBooked: _booked.contains(c['id'].toString()),
                      onBook: () =>
                          _book(c['id'].toString(), c['name'].toString()),
                      onUndo: () => _undo(c['id'].toString()),
                    )),
              ],
            ),
    );
  }
}

class _CompanionCard extends StatelessWidget {
  final Map<String, dynamic> companion;
  final bool isBooked;
  final VoidCallback onBook;
  final VoidCallback onUndo;

  const _CompanionCard({
    required this.companion,
    required this.isBooked,
    required this.onBook,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> skills = List<String>.from(companion['skills'] ?? []);
    final List<String> languages =
        List<String>.from(companion['languages'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(companion['avatar'] as String),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companion['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companion['personality'] as String,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${companion['rating']} (${companion['reviews']} reviews)',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            if (skills.isNotEmpty) ...[
              Text('Skills'.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills
                    .map((skill) => _buildChip(skill, AppTheme.primary))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (languages.isNotEmpty) ...[
              Text('Languages'.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: languages
                    .map((lang) => _buildChip(lang, Colors.teal))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: isBooked
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.check_circle),
                            label: Text('Booked Successfully'.tr()),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: onUndo,
                          icon: const Icon(Icons.undo_rounded),
                          tooltip: 'Cancel Booking'.tr(),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppTheme.destructive.withValues(alpha: 0.1),
                            foregroundColor: AppTheme.destructive,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: onBook,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text('Book Companion'.tr()),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
