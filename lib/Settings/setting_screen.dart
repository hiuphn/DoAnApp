import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen123 extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen123> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          _buildGeneralOption('Đơn vị đo lường', 'Hệ mét', Icons.straighten),
          _buildSwitchOption('Thông báo', true, Icons.volume_up),
          _buildSwitchOption('Chế độ nghỉ', true, Icons.beach_access),
          Divider(color: Colors.grey),
          _buildGeneralOption('Đăng nhập với tài khoản web', '', Icons.account_circle),
          _buildGeneralOption('Trợ giúp', '', Icons.help),
          Divider(color: Colors.grey),
          _buildGeneralOption('Gửi phản hồi', '', Icons.feedback),
          _buildGeneralOption('Chia sẻ ứng dụng', '', Icons.share),
        ],
      ),
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
