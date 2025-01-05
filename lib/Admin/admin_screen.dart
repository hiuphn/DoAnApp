import 'package:bai5/Component/LoginFirebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Blog.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Quản Trị'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Admin"),
              accountEmail: Text("admin@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.admin_panel_settings),
              ),
            ),
            ListTile(
              title: Text('Bài viết'),
              leading: Icon(Icons.article),
              onTap: () {
                // Điều hướng tới trang BlogScreen khi người dùng chọn
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlogScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Người dùng'),
              leading: Icon(Icons.people),
              onTap: () {
                // Điều hướng tới trang UserManagementScreen khi người dùng chọn
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserManagementScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Cài đặt'),
              leading: Icon(Icons.settings),
              onTap: () {
                // Điều hướng tới trang SettingsScreen khi người dùng chọn
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Đăng xuất'),
              leading: Icon(Icons.logout),
              onTap: () {
                // Điều hướng tới trang SettingsScreen khi người dùng chọn
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Chọn một mục từ thanh bên để điều hướng.'),
      ),
    );
  }
}

// UserManagementScreen (Giả sử bạn đã tạo sẵn màn hình Quản lý người dùng)
class UserManagementScreen extends StatelessWidget {
  final CollectionReference usersRef =
  FirebaseFirestore.instance.collection('users');

  // Hàm chặn người dùng
  Future<void> _blockUser(String userId) async {
    await usersRef.doc(userId).update({'blocked': true});
  }

  // Hàm mở chặn người dùng
  Future<void> _unblockUser(String userId) async {
    await usersRef.doc(userId).update({'blocked': false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý người dùng'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Không có dữ liệu.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id;
              final email = user['email'] ?? 'Không có email';
              final isBlocked = user['blocked'] ?? false;

              return ListTile(
                title: Text(email),
                subtitle: Text(isBlocked ? 'Đã chặn' : 'Hoạt động'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nút chặn người dùng
                    IconButton(
                      icon: Icon(Icons.block, color: isBlocked ? Colors.grey : Colors.red),
                      onPressed: isBlocked
                          ? null // Nếu đã chặn, không cho chặn nữa
                          : () {
                        _blockUser(userId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã chặn người dùng: $email')),
                        );
                      },
                    ),
                    // Nút mở chặn người dùng
                    IconButton(
                      icon: Icon(Icons.check_circle, color: isBlocked ? Colors.green : Colors.grey),
                      onPressed: isBlocked
                          ? () {
                        _unblockUser(userId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã mở chặn người dùng: $email')),
                        );
                      }
                          : null, // Nếu chưa chặn, không cho mở chặn
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}



// SettingsScreen (Giả sử bạn đã tạo sẵn màn hình Cài đặt)
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: Center(
        child: Text('Đây là trang Cài đặt'),
      ),
    );
  }
}
