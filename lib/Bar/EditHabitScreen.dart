import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';


// HabitService để xử lý các thao tác CRUD
class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thêm thói quen mới
  Future<void> addHabit(HabitData habit) async {
    try {
      await _firestore.collection('habits').add(habit.toMap());
    } catch (e) {
      throw Exception('Không thể thêm thói quen: $e');
    }
  }

  // Cập nhật thói quen
  Future<void> updateHabit(String habitId, HabitData habit) async {
    try {
      await _firestore.collection('habits').doc(habitId).update(habit.toMap());
    } catch (e) {
      throw Exception('Không thể cập nhật thói quen: $e');
    }
  }

  // Xóa thói quen
  Future<void> deleteHabit(String habitId) async {
    try {
      await _firestore.collection('habits').doc(habitId).delete();
    } catch (e) {
      throw Exception('Không thể xóa thói quen: $e');
    }
  }

  // Lấy thông tin một thói quen
  Future<HabitData?> getHabit(String habitId) async {
    try {
      final doc = await _firestore.collection('habits').doc(habitId).get();
      if (doc.exists) {
        return HabitData.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể lấy thông tin thói quen: $e');
    }
  }
}

// Model để lưu trữ dữ liệu thói quen
class HabitData {
  final String? id;
  final String name;
  final String icon;
  final String color;
  final String goal;
  final String frequency;
  final List<bool> selectedDays;
  final List<String> timeOfDay;
  final bool hasReminders;
  final List<Map<String, dynamic>> reminderTimes;
  final DateTime endDate;
  final int timesPerDay;
  final int minutesPerDay;
  final String countType;

  HabitData({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.goal,
    required this.frequency,
    required this.selectedDays,
    required this.timeOfDay,
    required this.hasReminders,
    required this.reminderTimes,
    required this.endDate,
    required this.timesPerDay,
    required this.minutesPerDay,
    required this.countType,
  });

  // Chuyển đổi từ Map sang Object
  factory HabitData.fromMap(Map<String, dynamic> map) {
    return HabitData(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      goal: map['goal'],
      frequency: map['frequency'],
      selectedDays: List<bool>.from(map['selectedDays']),
      timeOfDay: List<String>.from(map['timeOfDay']),
      hasReminders: map['hasReminders'],
      reminderTimes: List<Map<String, dynamic>>.from(
          map['reminderTimes']?.map((x) => Map<String, dynamic>.from(x)) ?? []
      ),
      endDate: DateTime.parse(map['endDate']),
      timesPerDay: map['timesPerDay'],
      minutesPerDay: map['minutesPerDay'],
      countType: map['countType'],
    );
  }

  // Chuyển đổi Object sang Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'goal': goal,
      'frequency': frequency,
      'selectedDays': selectedDays,
      'timeOfDay': timeOfDay,
      'hasReminders': hasReminders,
      'reminderTimes': reminderTimes.map((time) => {
        'hour': time['hour'],
        'minute': time['minute'],
      }).toList(),
      'endDate': endDate.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'timesPerDay': timesPerDay,
      'minutesPerDay': minutesPerDay,
      'countType': countType,
    };
  }
}
class EditHabitScreen extends StatefulWidget {
  final String? initialHabitName;
  final String? habitId;
  final bool isNewHabit;
  const EditHabitScreen({
    Key? key,
    this.initialHabitName,
    this.habitId,
    this.isNewHabit = false,
  }) : super(key: key);

  @override
  _EditHabitScreenState createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final HabitService _habitService = HabitService();
  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _timesController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  TimeOfDay _morningTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _afternoonTime = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _eveningTime = TimeOfDay(hour: 17, minute: 0);

  String? _habitId;
  bool _isSaving = false;
  String countType = 'times';

  // Các biến state
  Color currentColor = Colors.blue;
  IconData currentIcon = Icons.emoji_emotions;
  bool hasGoal = true;
  bool hasReminders = true;
  List<bool> selectedDays = List.generate(7, (index) => true);
  String frequency = 'daily';
  List<String> timeOfDay = ['morning'];
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
  List<TimeOfDay> reminderTimes = [];

  // Màu sắc theme
  final backgroundColor = const Color(0xFF707070);
  final surfaceColor = const Color(0xFF1E1E1E);
  final primaryColor = Colors.blue;
  final accentColor = const Color(0xFF2196F3);

  Future<void> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      // Kiểm tra quyền thông báo
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();

      print('Quyền thông báo: ${granted ?? false}');

      // Nếu chưa được cấp quyền, mở settings để người dùng cấp quyền
      if (granted == false) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermissions();
    if (widget.initialHabitName != null) {
      if (widget.isNewHabit) {
        // Nếu là habit mới, chỉ điền tên
        _habitNameController.text = widget.initialHabitName!;
      } else {
        // Nếu là habit đã tồn tại, load toàn bộ dữ liệu
        _loadHabitData();
      }
    }
    _loadTimesFromFirebase();
  }
  Future<void> _loadTimesFromFirebase() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('times')
          .get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _morningTime = _parseTime(data?['morningTime'] ?? '09:00');
          _afternoonTime = _parseTime(data?['afternoonTime'] ?? '14:00');
          _eveningTime = _parseTime(data?['eveningTime'] ?? '20:00');
        });
      }
    } catch (e) {
      print("Error loading times from Firebase: $e");
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  Future<void> _loadHabitData() async {
    try {
      final habits = await FirebaseFirestore.instance
          .collection('habits')
          .where('name', isEqualTo: widget.initialHabitName)
          .get();

      if (habits.docs.isNotEmpty) {
        final habitDoc = habits.docs.first;
        _habitId = habitDoc.id;
        final habitData = HabitData.fromMap(habitDoc.data());

        setState(() {
          _habitNameController.text = habitData.name;
          _goalController.text = habitData.goal;
          currentColor = Color(int.parse(habitData.color, radix: 16));
          currentIcon = IconData(int.parse(habitData.icon, radix: 16));
          frequency = habitData.frequency;
          selectedDays = habitData.selectedDays;
          timeOfDay = habitData.timeOfDay;
          hasReminders = habitData.hasReminders;
          // Chuyển đổi reminderTimes từ Map sang TimeOfDay
          reminderTimes = habitData.reminderTimes.map((time) =>
              TimeOfDay(
                  hour: time['hour'] as int,
                  minute: time['minute'] as int
              )
          ).toList();
          selectedDate = habitData.endDate;
          countType = habitData.countType;

          if (countType == 'times') {
            _timesController.text = habitData.timesPerDay.toString();
          } else {
            _minutesController.text = habitData.minutesPerDay.toString();
          }
        });
      }
    } catch (e) {
      _showError('Không thể tải dữ liệu: $e');
    }
  }

  Future<void> scheduleNotification(String title, String body, TimeOfDay time) async {
    try {
      // Yêu cầu quyền thông báo
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      if (granted  ?? false) {
        // Tạo ID duy nhất cho mỗi thông báo
        final int notificationId = time.hour * 60 + time.minute;

        // Lấy thời gian hiện tại
        final now = DateTime.now();

        // Tạo thời gian thông báo cho ngày hôm nay
        var scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        // Nếu thời gian đã qua, đặt cho ngày mai
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(Duration(days: 1));
        }

        // Chuyển đổi sang timezone
        final scheduledDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

        // Cấu hình chi tiết thông báo
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'habit_reminder_channel', // ID kênh
          'Habit Reminders', // Tên kênh
          channelDescription: 'Thông báo nhắc nhở thói quen',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification'),
          enableVibration: true,
          playSound: true,
          showWhen: true,
          enableLights: true,

        );

        const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

        // Lên lịch thông báo lặp lại hàng ngày
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDateTime,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // Lặp lại hàng ngày
        );

        print('Đã lên lịch thông báo cho ${time.hour}:${time.minute}');
      }
      else {
        print('Chưa được cấp quyền thông báo');
        // Yêu cầu cấp quyền
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
    } catch (e) {
      print('Lỗi khi lên lịch thông báo: $e');
    }
  }

  Future<void> cancelNotifications() async {
    for (var reminder in reminderTimes) {
      final notificationId = reminder.hour * 60 + reminder.minute;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  Future<void> _saveHabit() async {
    if (!_validateInputs()) return;

    setState(() => _isSaving = true);

    try {
      final habitData = HabitData(
        id: _habitId,
        name: _habitNameController.text,
        icon: currentIcon.codePoint.toRadixString(16),
        color: currentColor.value.toRadixString(16),
        goal: _goalController.text,
        frequency: frequency,
        selectedDays: selectedDays,
        timeOfDay: timeOfDay,
        hasReminders: hasReminders,
        reminderTimes: reminderTimes.map((time) => {
          'hour': time.hour,
          'minute': time.minute,
        }).toList(),
        endDate: selectedDate,
        timesPerDay: int.tryParse(_timesController.text) ?? 0,
        minutesPerDay: int.tryParse(_minutesController.text) ?? 0,
        countType: countType,
      );

      if (_habitId != null) {
        await _habitService.updateHabit(_habitId!, habitData);
        _showSuccess('Đã cập nhật thói quen');
      } else {
        await _habitService.addHabit(habitData);
        _showSuccess('Đã tạo thói quen mới');
      }
      if (hasReminders) {
        await _scheduleNotifications();
      }

      Navigator.pop(context);
    } catch (e) {
      _showError('Có lỗi xảy ra: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }
  Future<void> _scheduleNotifications() async {
    await cancelNotifications(); // Hủy thông báo cũ trước khi tạo mới

    final now = DateTime.now(); // Lấy thời gian hiện tại

    // Nếu có thời gian tùy chỉnh trong reminderTimes
    if (reminderTimes.isNotEmpty) {
      for (var time in reminderTimes) {
        final title = 'Nhắc nhở: ${_habitNameController.text}';
        final body = 'Đã đến giờ thực hiện thói quen "${_habitNameController.text}"!';
        await scheduleNotification(title, body, time); // Lên lịch cho từng thời gian cụ thể
      }
      return; // Không cần xử lý thêm
    }

    // Xử lý theo buổi sáng, chiều, tối
    if (timeOfDay.isEmpty) {
      print('Không có buổi hoặc thời gian nào được chọn. Không tạo thông báo.');
      return; // Không lên lịch nếu không có thông tin
    }

    // Lên lịch theo ngày, tuần hoặc tháng
    if (frequency == 'weekly' || frequency == 'monthly') {
      for (int dayIndex = 0; dayIndex < selectedDays.length; dayIndex++) {
        if (now.weekday == (dayIndex + 1) && !selectedDays[dayIndex]) {
          print('Hôm nay là ngày không được chọn, không tạo thông báo.');
          continue; // Bỏ qua logic tạo thông báo cho ngày này
        }

        final nextDay = now.add(
          Duration(days: (dayIndex + 1 - now.weekday + 7) % 7),
        );
        if (now.weekday == (dayIndex + 1) && selectedDays[dayIndex]) {
          if (selectedDays[dayIndex]) {
            if (nextDay.isAfter(now) || nextDay.isAtSameMomentAs(now)) {
              for (var timePeriod in timeOfDay) {
                final title = 'Nhắc nhở: ${_habitNameController.text}';
                final body =
                    'weekly Đã đến giờ thực hiện thói quen "${_habitNameController
                    .text}" vào $timePeriod!';

                TimeOfDay scheduledTime;

                switch (timePeriod) {
                  case 'morning':
                    scheduledTime = _morningTime;
                    break;
                  case 'afternoon':
                    scheduledTime = _afternoonTime;
                    break;
                  case 'evening':
                    scheduledTime = _eveningTime;
                    break;
                  default:
                    print('Thời gian không hợp lệ cho $timePeriod.');
                    continue;
                }

                await scheduleNotification(title, body, scheduledTime);
              }
            }
          }
        }
      }
    } else if (frequency == 'daily') {
      for (var timePeriod in timeOfDay) {
        final title = 'Nhắc nhở: ${_habitNameController.text}';
        final body =
            'daily Đã đến giờ thực hiện thói quen "${_habitNameController.text}" vào $timePeriod!';

        TimeOfDay scheduledTime;

        switch (timePeriod) {
          case 'morning':
            scheduledTime = _morningTime;
            break;
          case 'afternoon':
            scheduledTime = _afternoonTime;
            break;
          case 'evening':
            scheduledTime = _eveningTime;
            break;
          default:
            print('Thời gian không hợp lệ cho $timePeriod.');
            continue;
        }

        await scheduleNotification(title, body, scheduledTime);
      }
    }
  }



  Future<void> _deleteHabit() async {
    if (_habitId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa thói quen này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _habitService.deleteHabit(_habitId!);
        await cancelNotifications();
        _showSuccess('Đã xóa thói quen');
        Navigator.pop(context);
      } catch (e) {
        _showError('Không thể xóa thói quen: $e');
      }
    }
  }

  bool _validateInputs() {
    if (_habitNameController.text.isEmpty) {
      _showError('Vui lòng nhập tên thói quen');
      return false;
    }

    if (_goalController.text.isEmpty) {
      _showError('Vui lòng nhập mục tiêu');
      return false;
    }

    if (countType == 'times' && _timesController.text.isEmpty) {
      _showError('Vui lòng nhập số lần trong ngày');
      return false;
    }

    if (countType == 'minutes' && _minutesController.text.isEmpty) {
      _showError('Vui lòng nhập số phút trong ngày');
      return false;
    }

    return true;
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _habitNameController.dispose();
    _goalController.dispose();
    _timesController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_habitId != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteHabit,
                ),
              TextButton(
                onPressed: _isSaving ? null : _saveHabit,
                child: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'LƯU',
                  style: GoogleFonts.inter(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            title: Text(
              _habitId != null ? 'Chỉnh sửa thói quen' : 'Thêm thói quen mới',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHabitNameInput(),
                  const SizedBox(height: 24),
                  _buildIconAndColorSection(),
                  const SizedBox(height: 24),
                  _buildDailyCountSection(),
                  const SizedBox(height: 24),
                  _buildGoalSection(),
                  const SizedBox(height: 24),
                  _buildFrequencySection(),
                  const SizedBox(height: 24),
                  _buildDaySelector(),
                  const SizedBox(height: 24),
                  _buildTimeOfDaySection(),
                  const SizedBox(height: 24),
                  _buildReminderSection(),
                  const SizedBox(height: 24),
                  _buildEndDateSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // [Các widget build methods giữ nguyên như cũ]
  Widget _buildHabitNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _habitNameController, // Sử dụng controller
        style: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white, // Màu chữ của text nhập vào
        ),

        decoration: InputDecoration(
          hintText: 'Tên thói quen',
          border: InputBorder.none,
          hintStyle: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  Future<void> _showIconPicker(BuildContext context) async {
    // Danh sách các biểu tượng
    List<IconData> iconList = [
      Icons.person,

      Icons.eco,
      Icons.directions_run,
      Icons.terrain,
      Icons.kitchen,
      Icons.directions_bike,
      Icons.videogame_asset,
      Icons.pool,
      Icons.group,
      Icons.notifications,
      Icons.description,
      Icons.delete,
      Icons.fitness_center,
      Icons.chat,
      Icons.emoji_emotions,
      Icons.child_care,
      Icons.warning,
      Icons.tag_faces,
    ];

    IconData? selectedIcon = await showDialog<IconData>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E), // Nền tối
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tiêu đề
                Text(
                  'Chọn biểu tượng',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Lưới biểu tượng
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Số biểu tượng mỗi hàng
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: iconList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, iconList[index]); // Trả về biểu tượng đã chọn
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue, // Màu nền biểu tượng khi hiển thị
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconList[index],
                          color: Colors.white, // Màu biểu tượng
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    // Nếu người dùng chọn biểu tượng, xử lý kết quả
    if (selectedIcon != null) {
      setState(() {
        // Lưu biểu tượng được chọn
        currentIcon = selectedIcon;
      });
    }
  }
  Future<void> _showColorPicker(BuildContext context) async {
    // Danh sách các màu sắc
    List<Color> colorList = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.cyan,
      Colors.pink,
      Colors.teal,
      Colors.lime,
      Colors.indigo,
      Colors.amber,
    ];

    Color? selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E), // Nền tối
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tiêu đề
                Text(
                  'Chọn màu sắc',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Lưới các màu sắc
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Số màu mỗi hàng
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: colorList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, colorList[index]); // Trả về màu đã chọn
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorList[index], // Màu sắc hiển thị
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white, // Đường viền
                            width: 2,
                          ),
                        ),
                        height: 40,
                        width: 40,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    // Nếu người dùng chọn màu, xử lý kết quả
    if (selectedColor != null) {
      setState(() {
        // Lưu màu đã chọn
        currentColor = selectedColor;
      });
    }
  }

  Widget _buildIconAndColorSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _showIconPicker(context); // Gọi hàm chọn biểu tượng
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentIcon, // Biểu tượng hiện tại
                      color: currentColor, // Màu biểu tượng hiện tại
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Biểu tượng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _showColorPicker(context); // Gọi hàm chọn màu sắc
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.color_lens,
                      color: currentColor, // Hiển thị màu hiện tại
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Màu sắc',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.white, // Màu chữ giữ nguyên
        ),
      ),
    );
  }

  Widget _buildGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mục tiêu'),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _goalController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nhập mục tiêu của bạn',
              border: InputBorder.none,
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildDailyCountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Số lần/phút trong ngày'),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Chọn loại đếm
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => countType = 'times'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: countType == 'times' ? currentColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Số lần',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => countType = 'minutes'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: countType == 'minutes' ? currentColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Số phút',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Nhập số lượng
              TextField(
                controller: countType == 'times' ? _timesController : _minutesController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: countType == 'times'
                      ? 'Nhập số lần trong ngày'
                      : 'Nhập số phút trong ngày',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: currentColor),
                  ),
                  suffixText: countType == 'times' ? 'lần' : 'phút',
                  suffixStyle: GoogleFonts.inter(
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tần suất'),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              Row(
                children: [
                  _buildFrequencyOption('Hàng ngày', 'daily'),
                  _buildFrequencyOption('Hàng tuần', 'weekly'),
                  _buildFrequencyOption('Hàng tháng', 'monthly'),
                ],
              ),
              if (frequency == 'weekly') ...[
                const SizedBox(height: 12),
                Text(
                  'Repeat ${selectedDays.where((day) => day).length} days a week',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    7,
                        (index) => GestureDetector(
                      onTap: () => setState(() => selectedDays[index] = !selectedDays[index]),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedDays[index] ? currentColor : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: selectedDays[index] ? Colors.white : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (frequency == 'monthly') ...[
                const SizedBox(height: 12),
                Text(
                  'Repeat ${selectedDays.where((day) => day).length} days a month',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    31,
                        (index) => GestureDetector(
                      onTap: () => setState(() => selectedDays[index % 7] = !selectedDays[index % 7]),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedDays[index % 7] ? currentColor : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: selectedDays[index % 7] ? Colors.white : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildTimeOfDaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thời gian trong ngày'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTimeChip('Sáng', 'morning'),   // Thêm sáng
            _buildTimeChip('Chiều', 'afternoon'), // Thêm chiều
            _buildTimeChip('Tối', 'evening'),    // Thêm tối
          ],
        ),
      ],
    );
  }


  Widget _buildEndDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ngày kết thúc'),
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: currentColor),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: surfaceColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }
  bool _isTimeExists(TimeOfDay newTime) {
    return reminderTimes.any((time) =>
    time.hour == newTime.hour && time.minute == newTime.minute
    );
  }
  void _sortReminderTimes() {
    reminderTimes.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }
  Future<void> _showTimePicker() async {
    if (reminderTimes.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 10 thời gian nhắc nhở')),
      );
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: surfaceColor,
              hourMinuteTextColor: Colors.white,
              dialBackgroundColor: backgroundColor,
              dialHandColor: currentColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (!_isTimeExists(picked)) {
          reminderTimes.add(picked); // Thêm thời gian người dùng chọn
          _sortReminderTimes(); // Sắp xếp danh sách
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thời gian này đã tồn tại')),
          );
        }
      });
    }
  }


  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    bool isColor = false,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isColor ? currentColor : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyOption(String label, String value) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => frequency = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: frequency == value ? currentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          7,
              (index) => _buildDayButton(index),
        ),
      ),
    );
  }

  Widget _buildDayButton(int index) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return GestureDetector(
      onTap: () => setState(() => selectedDays[index] = !selectedDays[index]),
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedDays[index] ? currentColor : Colors.transparent,
        ),
        child: Center(
          child: Text(
            days[index],
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, String value) {
    final isSelected = timeOfDay.contains(value);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            timeOfDay.remove(value);
          } else {
            timeOfDay.add(value);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? currentColor : surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Giao diện phần Nhắc nhở
  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề và Switch bật/tắt nhắc nhở
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nhắc nhở',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Switch(
              value: hasReminders,
              onChanged: (value) => setState(() => hasReminders = value),
              activeColor: currentColor,
            ),
          ],
        ),
        if (hasReminders) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Hiển thị thông báo nếu chưa chọn thời gian nhắc nhở
                if (reminderTimes.isEmpty && timeOfDay.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Bạn chưa chọn buổi nào (Sáng, Chiều, Tối) hoặc thêm thời gian nhắc nhở. Vui lòng chọn hoặc thêm thời gian để kích hoạt thông báo.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(color: Colors.grey),
                ],
                // Hiển thị danh sách thời gian nhắc nhở tùy chỉnh
                ...reminderTimes.map((time) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Icon(Icons.access_time, color: currentColor),
                  title: Text(
                    time.format(context),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        reminderTimes.remove(time);
                      });
                    },
                  ),
                )),
                const Divider(color: Colors.grey),
                // Hiển thị các tùy chọn sáng, chiều, tối
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Chọn buổi nhắc nhở:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildOptionButton(
                      icon: Icons.wb_sunny,
                      label: 'Sáng',
                      isColor: timeOfDay.contains('morning'),
                      onTap: () {
                        setState(() {
                          if (timeOfDay.contains('morning')) {
                            timeOfDay.remove('morning');
                          } else {
                            timeOfDay.add('morning');
                          }
                        });
                      },
                    ),
                    _buildOptionButton(
                      icon: Icons.wb_cloudy,
                      label: 'Chiều',
                      isColor: timeOfDay.contains('afternoon'),
                      onTap: () {
                        setState(() {
                          if (timeOfDay.contains('afternoon')) {
                            timeOfDay.remove('afternoon');
                          } else {
                            timeOfDay.add('afternoon');
                          }
                        });
                      },
                    ),
                    _buildOptionButton(
                      icon: Icons.nights_stay,
                      label: 'Tối',
                      isColor: timeOfDay.contains('evening'),
                      onTap: () {
                        setState(() {
                          if (timeOfDay.contains('evening')) {
                            timeOfDay.remove('evening');
                          } else {
                            timeOfDay.add('evening');
                          }
                        });
                      },
                    ),
                  ],
                ),
                const Divider(color: Colors.grey),
                // Nút thêm thời gian tùy chỉnh
                TextButton.icon(
                  onPressed: _showTimePicker,
                  icon: Icon(Icons.add, color: currentColor),
                  label: Text(
                    'Thêm thời gian nhắc nhở',
                    style: GoogleFonts.inter(
                      color: currentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }




}