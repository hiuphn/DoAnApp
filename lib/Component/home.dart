import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Bar/EditHabitScreen.dart';

// Model HabitData
class HabitData {
  final String name;
  final String icon;
  final String color;
  final String goal;
  final String frequency;
  final List<bool> selectedDays;
  final List<String> timeOfDay;
  final bool hasReminders;
  final List<Map<String, dynamic>> reminderTimes; // Thay đổi kiểu dữ liệu ở đây
  final DateTime startDate; // Thêm startDate
  final DateTime endDate;
  final int timesPerDay;
  final int minutesPerDay;
  final String countType;

  HabitData({
    required this.name,
    required this.icon,
    required this.color,
    required this.goal,
    required this.frequency,
    required this.selectedDays,
    required this.timeOfDay,
    required this.hasReminders,
    required this.reminderTimes,
    required this.startDate, // Thêm
    required this.endDate,
    required this.timesPerDay,
    required this.minutesPerDay,
    required this.countType,
  });

  factory HabitData.fromMap(Map<String, dynamic> data) {
    return HabitData(
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      color: data['color'] ?? '',
      goal: data['goal'] ?? '',
      frequency: data['frequency'] ?? '',
      selectedDays: List<bool>.from(data['selectedDays'] ?? []),
      timeOfDay: List<String>.from(data['timeOfDay'] ?? []),
      hasReminders: data['hasReminders'] ?? false,
      reminderTimes: (data['reminderTimes'] as List?)
          ?.map((time) => Map<String, dynamic>.from(time))
          .toList() ?? [], // Sửa cách chuyển đổi dữ liệu
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'])
          : DateTime.now(),
      endDate: data['endDate'] != null
          ? DateTime.parse(data['endDate'])
          : DateTime.now(),
      timesPerDay: data['timesPerDay'] ?? 0,
      minutesPerDay: data['minutesPerDay'] ?? 0,
      countType: data['countType'] ?? 'times',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'goal': goal,
      'frequency': frequency,
      'selectedDays': selectedDays,
      'timeOfDay': timeOfDay,
      'hasReminders': hasReminders,
      'reminderTimes': reminderTimes,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'timesPerDay': timesPerDay,
      'minutesPerDay': minutesPerDay,
      'countType': countType,
    };
  }
}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  late ScrollController _scrollController;
  List<HabitData> _habits = [];
  String _selectedTimeSegment = 'all';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _scrollController = ScrollController();
    _loadHabits();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    try {
      final snapshot = await _firestore.collection('habits').get();
      final selectedDate = _selectedDate;
      setState(() {
        _habits = snapshot.docs
            .map((doc) => HabitData.fromMap(doc.data()))
            .where((habit) =>
        habit.startDate.isBefore(selectedDate.add(Duration(days: 1))) &&
            habit.endDate.isAfter(selectedDate.subtract(Duration(days: 1))))
            .toList();
      });
    } catch (e) {
      print('Error loading habits: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách thói quen: $e')),
      );
    }
  }

  void _changeMonth(int monthChange) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + monthChange,
        1,
      );
    });
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        day,
      );
    });
    _loadHabits();
    _scrollToSelectedDay();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _scrollToSelectedDay();
  }

  void _scrollToSelectedDay() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final dayIndex = _selectedDate.difference(firstDayOfMonth).inDays;
    final scrollPosition = dayIndex * 50.0;

    _scrollController.animateTo(
      scrollPosition,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildTimeSegments() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeSegmentButton('all', 'Tất cả'),
          _buildTimeSegmentButton('morning', 'Sáng'),
          _buildTimeSegmentButton('afternoon', 'Chiều'),
          _buildTimeSegmentButton('evening', 'Tối'),
        ],
      ),
    );
  }

  Widget _buildTimeSegmentButton(String segment, String label) {
    final isSelected = _selectedTimeSegment == segment;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeSegment = segment),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isSelected ? Colors.white : Colors.grey,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => _changeMonth(-1),
            ),
            Text(
              DateFormat('MMMM yyyy', 'vi').format(_selectedDate),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
        Container(
          height: 80,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final currentDate = firstDayOfMonth.add(Duration(days: index));
              final dayOfWeek = DateFormat('E', 'vi').format(currentDate);
              final dayOfMonth = currentDate.day;
              final isSelected = currentDate.day == _selectedDate.day;

              return GestureDetector(
                onTap: () => _selectDay(dayOfMonth),
                child: Container(
                  width: 50,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayOfWeek,
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$dayOfMonth',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Trong class _HomeScreenState, sửa lại phương thức _buildHabitsList():
  Widget _buildHabitsList() {
    if (_habits.isEmpty) {
      return Center(
        child: Text(
          'Chưa có thói quen nào',
          style: GoogleFonts.inter(color: Colors.grey),
        ),
      );
    }

    final filteredHabits = _selectedTimeSegment == 'all'
        ? _habits
        : _habits.where((habit) => habit.timeOfDay.contains(_selectedTimeSegment)).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = filteredHabits[index];
        return Dismissible(
          key: Key(habit.name), // Sử dụng một key duy nhất
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Color(0xFF1E1E1E),
                  title: Text(
                    'Xác nhận xóa',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Text(
                    'Bạn có chắc muốn xóa thói quen này?',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Hủy', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Xóa', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) async {
            try {
              // Xóa thói quen khỏi Firestore
              await _firestore
                  .collection('habits')
                  .where('name', isEqualTo: habit.name)
                  .get()
                  .then((snapshot) {
                for (DocumentSnapshot doc in snapshot.docs) {
                  doc.reference.delete();
                }
              });

              setState(() {
                _habits.remove(habit);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa thói quen')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi khi xóa thói quen: $e')),
              );
            }
          },
          child: GestureDetector(
            onTap: () {
              // Mở màn hình chỉnh sửa khi nhấn vào
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(
                    initialHabitName: habit.name,
                    isNewHabit: false,
                  ),
                ),
              ).then((_) => _loadHabits()); // Reload sau khi chỉnh sửa
            },
            child: TaskItem(
              icon: IconData(
                int.parse(habit.icon, radix: 16),
                fontFamily: 'MaterialIcons',
              ),
              color: Color(int.parse(habit.color, radix: 16)),
              title: habit.name,
              isNew: true,
              count: habit.countType == 'times'
                  ? '0/${habit.timesPerDay} lần'
                  : '0/${habit.minutesPerDay} phút',
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Hôm Nay',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.today, color: Colors.white),
            onPressed: _goToToday,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHabits,
        child: ListView(
          children: [
            _buildCalendarStrip(),
            _buildTimeSegments(),
            _buildHabitsList(),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Navigate to EditHabitScreen
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => EditHabitScreen()),
      //     ).then((_) => _loadHabits());
      //   },
      //   child: Icon(Icons.add),
      //   backgroundColor: Colors.blue,
      // ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final bool isNew;
  final String? count;
  final String? duration;


  const TaskItem({
    Key? key,
    required this.icon,
    required this.color,
    required this.title,
    required this.isNew,
    this.count,
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isNew)
                  Text(
                    'Mới',
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            count ?? duration ?? '',
            style: GoogleFonts.inter(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
