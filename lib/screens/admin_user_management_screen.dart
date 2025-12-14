import 'package:flutter/material.dart';
// Asumsi UserManagementService sudah dibuat dan memiliki method getAllUsers/deleteUser
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

  // Asumsi _service.getAllUsers() mengembalikan Map: {'success': bool, 'data': List<Map<String, dynamic>>, 'message': String}
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
    content: Text("Apakah Anda yakin ingin menghapus user \"$userName\"?\n\nSemua data terkait akan ikut terhapus."),
    actions: [
     TextButton(
      onPressed: () => Navigator.pop(ctx, false),
      child: const Text("Batal"),
     ),
     ElevatedButton(
      onPressed: () => Navigator.pop(ctx, true),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text("Hapus"),
     ),
    ],
   ),
  );

  if (confirm != true) return;

  // Show loading
  showDialog(
   context: context,
   barrierDismissible: false,
   builder: (ctx) => const Center(child: CircularProgressIndicator()),
  );

  final result = await _service.deleteUser(userId);

  if (mounted) Navigator.pop(context); // Close loading

  if (result['success']) {
   if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
    );
    _loadUsers(); // Reload data
   }
  } else {
   if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text(result['messge']), backgroundColor: Colors.red),
    );
   }
  }
 }

 Color _getRoleColor(String role) {
  switch (role) {
   case 'admin':
    return Colors.red;
   case 'farmer':
    return Colors.green;
   default:
    return Colors.blue;
  }
 }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   backgroundColor: Theme.of(context).colorScheme.background,
   body: SafeArea(
    child: Column(
     children: [
      // Header
      Container(
       width: double.infinity,
       decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
         BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
       ),
       child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 25, left: 20, right: 20),
        child: Column(
         children: [
          const Text(
           "Kelola User",
           textAlign: TextAlign.center,
           style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
           ),
          ),
          const SizedBox(height: 4),
          Text(
           "Total: ${_users.length} user",
           style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
         ],
        ),
       ),
      ),

      const SizedBox(height: 20),

      // Content
      Expanded(
       child: _isLoading
         ? const Center(child: CircularProgressIndicator())
         : _errorMessage != null
           ? Center(
             child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               const Icon(Icons.error_outline, size: 64, color: Colors.red),
               const SizedBox(height: 16),
               Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
               const SizedBox(height: 16),
               ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh),
                label: const Text("Coba Lagi"),
               ),
              ],
             ),
            )
           : _users.isEmpty
             ? const Center(child: Text("Belum ada user"))
             : RefreshIndicator(
               onRefresh: _loadUsers,
               child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16),
                child: SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child: DataTable(
                  border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                  headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
                  dataRowMaxHeight: 60,
                  columns: const [
                   // 🔥 PERBAIKAN: Ganti 'ID' dengan 'No.'
                   DataColumn(label: Text("No.", style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text("Nama Lengkap", style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text("Telepon", style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text("Role", style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text("Verified", style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text("Alamat", style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  // 🔥 PERBAIKAN: Gunakan asMap().entries untuk mendapatkan index
                  rows: _users.asMap().entries.map((entry) {
                   final index = entry.key;
                   final user = entry.value;

                   return DataRow(
                    cells: [
                     // 🔥 Kolom No. Urut
                     DataCell(Text((index + 1).toString())),
                     DataCell(
                      SizedBox(
                       width: 150,
                       child: Text(
                        user['full_name'] ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                       ),
                      ),
                     ),
                     DataCell(
                      SizedBox(
                       width: 180,
                       child: Text(
                        user['email'] ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                       ),
                      ),
                     ),
                     DataCell(Text(user['phone'] ?? '-')),
                     DataCell(
                      Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                        color: _getRoleColor(user['role']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                       ),
                       child: Text(
                        user['role'].toString().toUpperCase(),
                        style: TextStyle(
                         fontWeight: FontWeight.bold,
                         color: _getRoleColor(user['role']),
                         fontSize: 11,
                        ),
                       ),
                      ),
                     ),
                     DataCell(
                      Icon(
                       user['verified'] == true ? Icons.check_circle : Icons.cancel,
                       color: user['verified'] == true ? Colors.green : Colors.grey,
                       size: 20,
                      ),
                     ),
                     DataCell(
                      SizedBox(
                       width: 120,
                       child: Text(
                        user['address'] ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                       ),
                      ),
                     ),
                     DataCell(
                      Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                        IconButton(
                         icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                         onPressed: () => _deleteUser(user['id'], user['full_name']),
                         tooltip: "Hapus User",
                        ),
                       ],
                      ),
                     ),
                    ],
                   );
                  }).toList(),
                 ),
                ),
               ),
              ),
      ),
     ],
    ),
   ),
  );
 }
}