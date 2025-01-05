import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../Component/LoginFirebase.dart';

class SettingsScreen123 extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}
enum ShareType { messenger, zalo }
class _SettingsScreenState extends State<SettingsScreen123> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  TimeOfDay _morningTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _afternoonTime = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _eveningTime = TimeOfDay(hour: 17, minute: 0);
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadTimesFromFirebase();
  }

  // Lưu thời gian vào Firebase
  Future<void> _saveTimeToFirebase(String key, TimeOfDay time) async {
    try {
      await _firestore.collection('settings').doc('times').set({
        key: '${time.hour}:${time.minute}',
      }, SetOptions(merge: true));
      print("$key saved: ${time.hour}:${time.minute}");
    } catch (e) {
      print("Error saving $key: $e");
    }
  }

  // Tải thời gian từ Firebase
  Future<void> _loadTimesFromFirebase() async {
    try {
      final doc = await _firestore.collection('settings').doc('times').get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _morningTime = _parseTime(data?['morningTime'] ?? '00:00');
          _afternoonTime = _parseTime(data?['afternoonTime'] ?? '12:00');
          _eveningTime = _parseTime(data?['eveningTime'] ?? '17:00');
          isLoading = false;
        });
      } else {
        print("No times data found in Firebase.");
        setState(() {
          isLoading = false; // Dữ liệu trống, vẫn phải thoát trạng thái loading
        });
      }
    } catch (e) {
      print("Error loading times from Firebase: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Chuyển chuỗi giờ thành TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Hàm lấy tất cả thói quen từ Firestore
  Future<List<QueryDocumentSnapshot>> getAllHabits() async {
    try {
      final querySnapshot = await _firestore.collection('habits').get();
      return querySnapshot.docs; // Trả về danh sách các thói quen
    } catch (e) {
      print('Lỗi khi lấy danh sách thói quen: $e');
      return [];
    }
  }

  Future<void> checkPendingNotifications() async {
    final pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('Danh sách thông báo còn lại: ${pendingNotificationRequests.length}');
    for (var notification in pendingNotificationRequests) {
      print(
          'ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
  }

  // Hàm tắt thông báo cho tất cả thói quen
  Future<void> disableAllHabitNotifications() async {
    try {
      // Hủy toàn bộ thông báo trước
      await flutterLocalNotificationsPlugin.cancelAll();
      print('Đã hủy toàn bộ thông báo.');

      // Lấy tất cả các thói quen
      final habits = await getAllHabits();

      for (var habit in habits) {
        final habitData = habit.data() as Map<String, dynamic>;

        // Lấy ID của thói quen
        final habitId = habit.id;

        // Cập nhật hasReminders thành false
        await FirebaseFirestore.instance
            .collection('habits')
            .doc(habitId)
            .update({'hasReminders': false});

        print('Đã tắt thông báo cho thói quen: $habitId');
      }

      // Hủy tất cả thông báo còn lại
      await flutterLocalNotificationsPlugin.cancelAll();
      print('Tất cả thông báo đã được tắt.');

      // Kiểm tra danh sách thông báo còn lại
      await checkPendingNotifications();
    } catch (e) {
      print('Lỗi khi tắt thông báo: $e');
    }
  }
  // Hàm gửi email phản hồi
  void _sendFeedbackWithGmail(BuildContext context) {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'phamhuynhngochieu123@gmail.com',
      query: 'subject=Feedback on App&body=Your feedback here...',
    );

    _launchURL(emailUri.toString());
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
  // Hàm hiển thị các tùy chọn chia sẻ
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blue),
              title: const Text(
                'Chia sẻ qua Messenger',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                _shareApp(context, ShareType.messenger);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text(
                'Chia sẻ qua Zalo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                _shareApp(context, ShareType.zalo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.red),
              title: const Text(
                'Hủy',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  // Hàm chia sẻ ứng dụng
  Future<void> _shareApp(BuildContext context, ShareType type) async {
    const String appLink = 'https://example.com'; // Thay bằng link app thực tế
    final String message = 'Hãy tải ứng dụng của tôi tại: $appLink';
    try {
      await Share.share(message, subject: 'Chia sẻ ứng dụng');
    } catch (e) {
      _showSnackBar(context, 'Lỗi khi chia sẻ: $e');
      print('Lỗi : $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Cài Đặt',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        children: [
          _buildSectionHeader('THỜI GIAN TRONG NGÀY'),
          _buildTimeSettingOption(
              'Sáng', _morningTime, Icons.wb_sunny, Colors.orange, (time) {
            setState(() {
              _morningTime = time;
            });
            _saveTimeToFirebase('morningTime', time);
          }),
          _buildTimeSettingOption(
              'Chiều', _afternoonTime, Icons.cloud, Colors.blueAccent, (time) {
            setState(() {
              _afternoonTime = time;
            });
            _saveTimeToFirebase('afternoonTime', time);
          }),
          _buildTimeSettingOption(
              'Tối', _eveningTime, Icons.nights_stay, Colors.yellow, (time) {
            setState(() {
              _eveningTime = time;
            });
            _saveTimeToFirebase('eveningTime', time);
          }),
          _buildSectionHeader('CHUNG'),
          ListTile(
            leading: Icon(Icons.notifications_off, color: Colors.red),
            title: Text(
              'Tắt tất cả thông báo',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              await disableAllHabitNotifications();
              await checkPendingNotifications(); // Kiểm tra thông báo sau khi tắt
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã tắt tất cả thông báo nhắc nhở')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.green),
            title: Text(
              'Kiểm tra thông báo đang hoạt động',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              await checkPendingNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã kiểm tra danh sách thông báo')),
              );
            },
          ),
          _buildSwitchOption('Chế độ nghỉ', true, Icons.beach_access),
          Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.help, color: Colors.blueAccent),
            title: Text(
              'Trợ giúp',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Trợ giúp', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  content: Text(
                    'Nếu bạn gặp vấn đề, vui lòng liên hệ với đội hỗ trợ qua email supporttime@gmail.com hoặc gọi đến hotline: 19006868.',
                    style: GoogleFonts.inter(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Đóng', style: GoogleFonts.inter()),
                    ),
                  ],
                ),
              );
            },
          ),

          Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.feedback, color: Colors.blueAccent),
            title: Text(
              'Gửi phản hồi',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _sendFeedbackWithGmail(context), // Gọi hàm gửi phản hồi
          ),
          ListTile(
            leading: Icon(Icons.share, color: Colors.blueAccent),
            title: Text(
              'Chia sẻ ứng dụng',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              _showShareOptions(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Đăng xuất',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      )

    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeSettingOption(String title, TimeOfDay time, IconData icon,
      Color iconColor, Function(TimeOfDay) onTimeChanged) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        time.format(context),
        style: GoogleFonts.inter(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      onTap: () async {
        TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: Color(0xFF1E1E1E),
              ),
              child: child!,
            );
          },
        );
        if (selectedTime != null) {
          onTimeChanged(selectedTime);
        }
      },
    );
  }

  Widget _buildGeneralOption(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
        subtitle,
        style: GoogleFonts.inter(
          color: Colors.grey,
          fontSize: 14,
        ),
      )
          : null,
      onTap: () {
        // Handle tap
      },
    );
  }

  Widget _buildSwitchOption(String title, bool value, IconData icon) {
    return SwitchListTile(
      activeColor: Colors.blue,
      value: value,
      onChanged: (bool newValue) {
        // Handle switch state change
      },
      title: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
