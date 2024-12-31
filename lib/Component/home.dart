import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Hôm Nay', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar strip
          Container(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(10, (index) {
                return Container(
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][index % 7],
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${index + 2}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Time segments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Tối', style: TextStyle(color: Colors.grey)),
              Text('Tất cả', style: TextStyle(color: Colors.grey)),
              Text('Sáng', style: TextStyle(color: Colors.white)),
              Text('Chiều', style: TextStyle(color: Colors.grey)),
              Text('Tối', style: TextStyle(color: Colors.grey)),
            ],
          ),

          SizedBox(height: 20),
          Text('Sáng', style: TextStyle(color: Colors.grey)),

          // Task items
          TaskItem(
            icon: Icons.access_time,
            color: Colors.green,
            title: 'Thức dậy sớm',
            isNew: true,
            count: '0/1 lần',
          ),

          Text('Thời gian bất kỳ', style: TextStyle(color: Colors.grey)),

          TaskItem(
            icon: Icons.star,
            color: Colors.yellow,
            title: 'Luyện tập kỹ năng mới',
            isNew: true,
            duration: '30ph',
          ),

          TaskItem(
            icon: Icons.watch_later,
            color: Colors.blue,
            title: 'Dành thời gian cho bản thân',
            isNew: true,
            duration: '30ph',
          ),

          TaskItem(
            icon: Icons.fitness_center,
            color: Colors.orange,
            title: 'Tập luyện',
            isNew: true,
            count: '0/1 lần',
          ),
        ],
      ),

      // Bottom navigation

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

  TaskItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.isNew,
    this.count,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white)),
                if (isNew) Text('Mới', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            count ?? duration ?? '',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
