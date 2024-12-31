import 'package:bai5/Component/LoginFirebase.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomeScreen(),
    Profile( 
      name: 'Tên người dùng', 
      email: 'email@example.com', 
      phoneNumber: '0123456789', 
      avatarUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR29KtAIO05Rdx76fpeUTLVsjaD5g9GgS8XCQ&s',
    ),
    LoginScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Đăng xuất',
          ),
        ],
      ),
    );
  }
}
