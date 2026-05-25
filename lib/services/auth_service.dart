import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;
  bool get isLoggedIn => currentUser != null;

  String? _role;
  String? get role => _role;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthService() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      _isLoading = true;
      notifyListeners();

      final session = data.session;
      if (session != null) {
        await _fetchRole(session.user.id);
      } else {
        _role = null;
      }

      _isLoading = false;
      notifyListeners();
    });

    // Trigger initial check
    Future.delayed(const Duration(milliseconds: 100), () {
      if (currentUser != null) {
        _fetchRole(currentUser!.id);
      } else {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchRole(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      _role = data['role'] ?? 'elderly';
    } catch (_) {
      _role = 'elderly';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signUp(String email, String password, String fullName) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _role = null;
    notifyListeners();
  }
}
