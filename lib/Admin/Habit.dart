import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitScreenAdmin extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  HabitScreenAdmin({required this.categoryId, required this.categoryTitle});

  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreenAdmin> {
  final CollectionReference _habitsCollection =
  FirebaseFirestore.instance.collection('habitCategories');

  List<String> habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final docSnapshot = await _habitsCollection.doc(widget.categoryId).get();
    final data = docSnapshot.data() as Map<String, dynamic>;
    setState(() {
      habits = List<String>.from(data['habits'] ?? []);
    });
  }

  Future<void> _addHabit(String habitName) async {
    habits.add(habitName);
    await _habitsCollection.doc(widget.categoryId).update({'habits': habits});
    _loadHabits();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thêm tên thói quen thành công!')),
    );
  }

  Future<void> _updateHabit(int index, String newHabitName) async {
    habits[index] = newHabitName;
    await _habitsCollection.doc(widget.categoryId).update({'habits': habits});
    _loadHabits();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sửa tên thói quen thành công!')),
    );
  }

  Future<void> _deleteHabit(int index) async {
    habits.removeAt(index);
    await _habitsCollection.doc(widget.categoryId).update({'habits': habits});
    _loadHabits();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xóa tên thói quen thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habits in ${widget.categoryTitle}'),
      ),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(habits[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    final controller = TextEditingController(text: habits[index]);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Edit Habit'),
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(hintText: 'Habit name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _updateHabit(index, controller.text);
                              Navigator.pop(context);
                            },
                            child: Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteHabit(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add Habit'),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Habit name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _addHabit(controller.text);
                    Navigator.pop(context);
                  },
                  child: Text('Add'),
                ),

              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
