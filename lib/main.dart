import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';

import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/landing_screen/landing_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/medications/medications_screen.dart';
import 'screens/emergency/emergency_screen.dart';
import 'screens/meals/meals_screen.dart';
import 'screens/companions/companions_screen.dart';
import 'screens/ai_assistant/ai_assistant_screen.dart';
import 'screens/health_profile/health_profile_screen.dart';
import 'widgets/app_shell.dart';
import 'providers/medication_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    final authService = AuthService();

    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
          Locale('fr'),
          Locale('de'),
          Locale('it'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: SilverCareApp(authService: authService),
      ),
    );
  } catch (e) {
    debugPrint("====================================");
    debugPrint("🚨 ERROR IN INITIALIZATION 🚨");
    debugPrint(e.toString());
    debugPrint("====================================");

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    "Initialization Error",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    e.toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "check .env in pubspec.yaml",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SilverCareApp extends StatelessWidget {
  final AuthService authService;

  const SilverCareApp({super.key, required this.authService});

  GoRouter get _router => GoRouter(
        initialLocation: '/',
        refreshListenable: authService,
        redirect: (context, state) {
          final loggedIn = authService.isLoggedIn;
          final isAuthRoute = state.matchedLocation == '/login' ||
              state.matchedLocation == '/register';
          final isLanding = state.matchedLocation == '/';

          if (!loggedIn && !isAuthRoute && !isLanding) {
            return '/';
          }
          if (loggedIn && (isAuthRoute || isLanding)) {
            return '/dashboard';
          }
          return null;
        },
        routes: [
          GoRoute(path: '/', builder: (_, __) => const LandingScreen()),
          GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
          GoRoute(
              path: '/register', builder: (_, __) => const RegisterScreen()),
          ShellRoute(
            builder: (context, state, child) => AppShell(child: child),
            routes: [
              GoRoute(
                  path: '/dashboard',
                  builder: (_, __) => const DashboardScreen()),
              GoRoute(
                  path: '/health-profile',
                  builder: (_, __) => const HealthProfileScreen()),
              GoRoute(
                  path: '/medications',
                  builder: (_, __) => const MedicationsScreen()),
              GoRoute(
                  path: '/emergency',
                  builder: (_, __) => const EmergencyScreen()),
              GoRoute(path: '/meals', builder: (_, __) => const MealsScreen()),
              GoRoute(
                  path: '/companions',
                  builder: (_, __) => const CompanionsScreen()),
              GoRoute(
                  path: '/ai-assistant',
                  builder: (_, __) => const AIAssistantScreen()),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'SilverCare',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
