import 'package:bai5/Component/LoginFirebase.dart';
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

// BlogScreen (Giả sử bạn đã tạo sẵn màn hình Blog)
// class BlogScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Quản lý bài viết'),
//       ),
//       body: Center(
//         child: Text('Đây là trang Quản lý bài viết'),
//       ),
//     );
//   }
// }

// UserManagementScreen (Giả sử bạn đã tạo sẵn màn hình Quản lý người dùng)
class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý người dùng'),
      ),
      body: Center(
        child: Text('Đây là trang Quản lý người dùng'),
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
