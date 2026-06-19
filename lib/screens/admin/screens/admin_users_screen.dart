import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import "../../../widgets/silver_care_app_bar.dart";

import '../widgets/admin_user_card.dart';
import '../widgets/admin_user_search_bar.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _supabase = Supabase.instance.client;
  bool _loading = true;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();

    _searchController.addListener(() {
      _filterUsers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await _supabase
          .from('health_profiles')
          .select('*')
          .order('updated_at', ascending: false);

      if (mounted) {
        setState(() {
          _allUsers = List<Map<String, dynamic>>.from(data);
          _filteredUsers = _allUsers;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _allUsers);
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final name = (user['full_name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery) || email.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SilverCareAppBar(
        healthProfileRoute: '/admin-profile',
        showCompanions: false,
      ),
      body: Column(
        children: [
          AdminUserSearchBar(controller: _searchController),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchUsers,
                    child: _filteredUsers.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3),
                              Center(child: Text('No users found'.tr())),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return AdminUserCard(user: user);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
