import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey; // Để mở Drawer từ các trang khác

  CustomAppBar({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Quản lý Bài viết', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.blueAccent,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();  // Mở Drawer từ AppBar
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Định nghĩa chiều cao của AppBar
}
