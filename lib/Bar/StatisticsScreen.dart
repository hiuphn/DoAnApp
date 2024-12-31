import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isShowingSummary = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Thống kê', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabSelector(),
          Expanded(
            child: isShowingSummary
                ? _buildSummaryContent()
                : _buildHabitsContent(),
          ),
          _buildDetailStatsButton(),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            _buildTab('Tóm tắt', isShowingSummary),
            _buildTab('Thói quen', !isShowingSummary),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isShowingSummary = text == 'Tóm tắt';
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Chuỗi liên tiếp
          _buildStreakSection(),
          SizedBox(height: 20),

          // Phần Calendar
          _buildCalendarSection(),
          SizedBox(height: 20),

          // Phần Achievement Boxes
          _buildAchievementBoxes(),
          SizedBox(height: 20),

          // Phần Progress Section
          _buildProgressSection(),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chuỗi liên tiếp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text(
                      'Hiển thị Thêm',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  '0 ngày',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Chuỗi liên tiếp Hiện tại',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Hãy hoàn thành tất cả các thói quen của bạn trong hôm nay để bắt đầu một chuỗi liên tiếp.\n',
                        ),
                        TextSpan(
                          text: '1 ngày',
                          style: TextStyle(color: Colors.green),
                        ),
                        TextSpan(text: ' nữa là đạt được '),
                        WidgetSpan(
                          child: Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                        ),
                        TextSpan(text: ' tiếp theo'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final dates = ['18', '19', '20', '21', '22', '23', '24'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          return _buildDayColumn(
            days[index],
            dates[index],
            isSelected: index == 4,
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(String day, String date, {bool isSelected = false}) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.green : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBoxes() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildAchievementBox(
              'Ngày Lý tưởng',
              Icons.star,
              Colors.amber,
              false,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildAchievementBox(
              'Ba ngày Đỉnh cao',
              Icons.whatshot,
              Colors.orange,
              true,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildAchievementBox(
              'Tuần Hoàn hảo',
              Icons.emoji_events,
              Colors.purple,
              true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBox(
      String title,
      IconData icon,
      Color color,
      bool isLocked,
      ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLocked ? Icons.lock : icon,
            color: isLocked ? Colors.grey : color,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Năng suất',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Hiển thị Thêm',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  value: 0.5,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              Text(
                '50%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsContent() {
    final habits = [
      {'icon': Icons.alarm, 'title': 'Thức dậy sớm', 'color': Colors.green},
      {'icon': Icons.star, 'title': 'Luyện tập kỹ năng mới', 'color': Colors.amber},
      {'icon': Icons.access_time, 'title': 'Dành thời gian cho\nbản thân', 'color': Colors.blue},
      {'icon': Icons.fitness_center, 'title': 'Tập luyện', 'color': Colors.orange},
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (habit['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(habit['icon'] as IconData, color: habit['color'] as Color),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  habit['title'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
  Widget _buildDetailStatsButton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Xử lý khi nhấn button
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nhận Thống kê Chi tiết',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.star, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

}
