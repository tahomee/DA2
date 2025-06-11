import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DANH SÁCH TÀI KHOẢN',
        style: TextStyle(
          color: Color(0xFF3B6332),
          fontSize: 20.0,
          fontWeight: FontWeight.w800,
        ),),

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('Không có người dùng.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final name = user['username'] ?? 'Không tên';
              final email = user['email'] ?? '';
              final role = user['role'] ?? 'unknown';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Color.fromARGB(128, 255, 209, 102),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(name),
                  subtitle: Text(email),
                  trailing: Text(
                    role,
                    style: TextStyle(
                      color: role == 'admin' ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Điều hướng tới trang chi tiết người dùng nếu muốn
                    // Navigator.push(...);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
