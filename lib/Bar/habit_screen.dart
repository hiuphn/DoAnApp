import 'package:flutter/material.dart';

class HabitScreen extends StatelessWidget {
  final List<HabitCategory> categories = [
    HabitCategory(
      title: 'Thói quen thịnh hành',
      subtitle: 'Hãy bước đi đúng hướng',
      color: Colors.teal,
      icon: Icons.trending_up,
      habits: [
        'Đọc sách 30 phút mỗi ngày',
        'Tập thể dục buổi sáng',
        'Uống 2L nước mỗi ngày',
        'Thiền 10 phút',
      ],
    ),
    HabitCategory(
      title: 'Ở nhà',
      subtitle: 'Sử dụng thời gian này để làm điều gì đó mới mẻ',
      color: Colors.blue,
      icon: Icons.home,
      habits: [
        'Dọn dẹp phòng',
        'Nấu ăn tại nhà',
        'Học một kỹ năng mới',
        'Chăm sóc cây cảnh',
      ],
    ),
    HabitCategory(
      title: 'Sức khỏe & Phòng ngừa',
      subtitle: 'Bảo vệ bản thân và những người khác',
      color: Colors.purple,
      icon: Icons.health_and_safety,
      habits: [
        'Rửa tay thường xuyên',
        'Đeo khẩu trang khi ra ngoài',
        'Kiểm tra nhiệt độ',
        'Tập yoga',
      ],
    ),
    // Thêm nhiều category khác...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Khám phá Thói quen',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm thói quen...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Categories List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(categories[index]);
              },
            ),
          ),

          // Bottom Button
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                'Tạo Thói quen Mới',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(HabitCategory category) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            category.icon,
            color: category.color,
            size: 24,
          ),
        ),
        title: Text(
          category.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          category.subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        children: category.habits.map((habit) {
          return ListTile(
            leading: Icon(
              Icons.circle_outlined,
              color: category.color,
              size: 20,
            ),
            title: Text(
              habit,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            onTap: () {
              // Xử lý khi chọn thói quen
            },
          );
        }).toList(),
      ),
    );
  }
}

class HabitCategory {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final List<String> habits;

  HabitCategory({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.habits,
  });
}
