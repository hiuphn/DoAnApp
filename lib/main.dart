import 'package:bai5/Bar/ExploreScreen.dart';
import 'package:bai5/Component/home.dart';
import 'package:bai5/Component/loading_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Admin/Blog.dart';
import 'Admin/Habit.dart';
import 'Admin/Habit_categories.dart';
import 'Admin/admin_screen.dart';
import 'Bar/EditHabitScreen.dart';
import 'Component/LoginFirebase.dart';
import 'Component/dashboard_screen.dart';
import 'Component/profile_screen.dart';
import 'Component/BaseScreen.dart';
import 'Settings/setting_screen.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Khai báo Local Notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo timezone
  tz.initializeTimeZones();
  // Cấu hình thông báo
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Thông báo được nhấn: ${response.payload}');
    },
  );
  // Tạo notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'habit_reminders',
    'Habit Reminders',
    description: 'Notifications for habit reminders',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
  );

  // Tạo notification channel trong hệ thống
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);



  runApp(const MyApp());
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
          avatarUrl:
          'file:///C:/Users/Administrator/OneDrive/Pictures/Author.jpg',
        ),
      },
    );
  }
}
