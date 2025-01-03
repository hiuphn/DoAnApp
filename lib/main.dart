import 'package:bai5/Bar/ExploreScreen.dart';
import 'package:bai5/Component/home.dart';
import 'package:bai5/Component/loading_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Admin/Blog.dart';
import 'Admin/Habit.dart';
import 'Admin/Habit_categories.dart';
import 'Admin/admin_screen.dart';
import 'Bar/EditHabitScreen.dart';
import 'Component/LoginFirebase.dart';
import 'Component/dashboard_screen.dart';
import 'Component/profile_screen.dart';
import 'Component/BaseScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BaseScreen(),
      routes: {
        '/profile': (context) => Profile(
          name: 'Phạm Huỳnh Ngọc Hiếu',
          email: 'hieu@gmail.com',
          phoneNumber: '0123456789',
          avatarUrl: 'file:///C:/Users/Administrator/OneDrive/Pictures/Author.jpg',
        ),
      },
    );
  }
}
