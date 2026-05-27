import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ⬅️ للحفظ الدائم
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
  Set<String> _booked = {};
  bool _loading = true;
  String? _bookingSuccess;

  @override
  void initState() {
    super.initState();
    _loadBookedCompanions();
  }

  // تحميل الحجوزات القديمة من الموبايل
  Future<void> _loadBookedCompanions() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('booked_ids') ?? [];
    setState(() {
      _booked = saved.toSet();
      _loading = false;
    });
  }

  // حفظ الحجوزات في الموبايل
  Future<void> _saveBookedCompanions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('booked_ids', _booked.toList());
  }

  void _book(String id, String name) {
    setState(() {
      _booked.add(id);
      _bookingSuccess = 'has been booked!'.tr(args: [name]);
    });
    _saveBookedCompanions();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _bookingSuccess = null);
    });
  }

  void _undo(String id) {
    setState(() {
      _booked.remove(id);
    });
    _saveBookedCompanions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Companion'.tr())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Find a Companion'.tr(),
                    style: theme.textTheme.displayMedium),
                const SizedBox(height: 20),
                if (_bookingSuccess != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_bookingSuccess!,
                        style: const TextStyle(color: AppTheme.primary)),
                  ),
                ..._companions.map((c) => _CompanionCard(
                      companion: c,
                      isBooked: _booked.contains(c['id']),
                      onBook: () =>
                          _book(c['id'] as String, c['name'] as String),
                      onUndo: () => _undo(c['id'] as String),
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
                    backgroundImage:
                        NetworkImage(companion['avatar'] as String)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(companion['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(companion['personality'],
                          style: const TextStyle(color: AppTheme.mutedFg)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isBooked
                  ? Row(
                      children: [
                        Expanded(
                            child: OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.check),
                                label: Text('Booked'.tr()))),
                        const SizedBox(width: 8),
                        // زرار الـ Undo
                        IconButton.filledTonal(
                          onPressed: onUndo,
                          icon: const Icon(Icons.undo_rounded),
                          tooltip: 'Undo'.tr(),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: onBook,
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text('Book Companion'.tr()),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
