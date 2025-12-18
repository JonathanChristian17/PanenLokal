import 'package:flutter/material.dart';
import '../services/user_management_service.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final UserManagementService _service = UserManagementService();
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.getAllUsers();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _users = result['data'];
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }

  Future<void> _deleteUser(int userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text("Hapus user \"$userName\"?\nSemua data terkait akan ikut terhapus."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final result = await _service.deleteUser(userId);
    if (mounted) Navigator.pop(context);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
        );
        _loadUsers();
      }
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.red;
      case 'farmer': return Colors.green;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text(
                    "Kelola User",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                  const SizedBox(height: 4),
                  Text("Total: ${_users.length} user", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),

            // --- LIST USER ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorState()
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            // 🔥 KUNCI BIAR GAK TERTUTUP MENU:
                            padding: const EdgeInsets.only(
                              top: 16, 
                              left: 16, 
                              right: 16, 
                              bottom: 120, // Jarak ekstra di bagian paling bawah list
                            ),
                            itemCount: _users.length,
                            itemBuilder: (context, index) => _buildUserCard(_users[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(user['role']).withOpacity(0.1),
                  child: Text((user['full_name'] ?? "?")[0].toUpperCase(), 
                    style: TextStyle(color: _getRoleColor(user['role']), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['full_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user['email'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                if (user['verified'] == true) const Icon(Icons.verified, color: Colors.blue, size: 20),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteUser(user['id'], user['full_name']),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(user['phone'] ?? '-', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                _buildRoleBadge(user['role']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(user['address'] ?? '-', style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(role.toUpperCase(), style: TextStyle(color: _getRoleColor(role), fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          Text(_errorMessage!),
          TextButton(onPressed: _loadUsers, child: const Text("Coba Lagi")),
        ],
      ),
    );
  }
}