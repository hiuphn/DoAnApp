import 'package:bai5/Admin/Blog.dart';
import 'package:flutter/material.dart';
import '../Bar/habit_screen.dart';
import '../Component/LoginFirebase.dart';
import 'Habit_categories.dart';
import 'admin_screen.dart';

class CustomDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey; // Để mở Drawer từ các trang khác

  CustomDrawer({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            title: Text('Trang Quản trị'),
            leading: Icon(Icons.home),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Bài viết'),
            leading: Icon(Icons.article),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BlogScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Quản lý danh mục thói quen'),
            leading: Icon(Icons.article),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitCategoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Bài viết'),
            leading: Icon(Icons.article),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HabitScreen()),
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
    );
  }
}
