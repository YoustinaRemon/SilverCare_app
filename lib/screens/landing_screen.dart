import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SilverCare', style: theme.textTheme.displayMedium),
                    OutlinedButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),

              // ── Hero Section ─────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 60),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primary.withValues(alpha: .07),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monitor_heart_rounded,
                              size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Smart today, better tomorrow',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 28),

                    // Headline
                    Text(
                      'We care beyond distance,\nacross borders.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        height: 1.2,
                        fontSize: size.width < 380 ? 28 : 34,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Bridging Egypt and Switzerland with technology, compassion and trust. AI-powered platform designed to support elderly people living alone or managing chronic conditions.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.mutedFg, height: 1.6),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 36),

                    // CTA Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('Create Your Profile'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Sign In'),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),
              ),

              // ── Features Section ─────────────────────────────────────────
              Container(
                color: theme.cardColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    Text('Our Main Features',
                        style: theme.textTheme.displayMedium),
                    const SizedBox(height: 8),
                    Text(
                      'We combine health, nutrition, emergency care and human companionship in one smart solution.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.mutedFg),
                    ),
                    const SizedBox(height: 32),
                    ..._features.asMap().entries.map((e) => _FeatureCard(
                          feature: e.value,
                          delay: (e.key * 100).ms,
                        )),
                  ],
                ),
              ),

              // ── Footer ───────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('SilverCare', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      '© 2024 SilverCare. All rights reserved.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _features = [
  _Feature(
    icon: Icons.smart_toy_rounded,
    title: 'AI Health Assistant',
    description:
        'Personalized health advice, medication reminders and daily check-ins.',
    color: AppTheme.primary,
  ),
  _Feature(
    icon: Icons.restaurant_rounded,
    title: 'Healthy Meal Service',
    description:
        'Nutritious meals tailored to your health condition, delivered to your door.',
    color: Color(0xFF4CAF50),
  ),
  _Feature(
    icon: Icons.local_hospital_rounded,
    title: 'Emergency Support',
    description:
        'Instant AI assessment and connect you to doctors or emergency services.',
    color: AppTheme.destructive,
  ),
  _Feature(
    icon: Icons.group_rounded,
    title: 'Companion Matching',
    description:
        'We match you with trusted companions to visit, help and spend quality time.',
    color: AppTheme.secondary,
  ),
];

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _Feature(
      {required this.icon,
      required this.title,
      required this.description,
      required this.color});
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final Duration delay;
  const _FeatureCard({required this.feature, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: feature.color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(feature.icon, color: feature.color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feature.title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(feature.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }
}
