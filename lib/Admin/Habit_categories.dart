import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Bar/habit_screen.dart';
import 'Habit.dart';
// Import file chứa HabitCategoryRepository


class HabitCategory {
  final String id;
  final String title;
  final String subtitle;

  HabitCategory({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
    };
  }

  static HabitCategory fromMap(String id, Map<String, dynamic> map) {
    return HabitCategory(
      id: id,
      title: map['title'],
      subtitle: map['subtitle'],
    );
  }
}

class HabitCategoryRepository {
  final CollectionReference _categoriesCollection =
  FirebaseFirestore.instance.collection('habitCategories');

  Future<List<HabitCategory>> getCategories() async {
    final snapshot = await _categoriesCollection.get();
    return snapshot.docs
        .map((doc) =>
        HabitCategory.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Thêm một danh mục mới
  Future<void> addCategory(String title, String subtitle) async {
    await _categoriesCollection.add({'title': title, 'subtitle': subtitle});
  }

  // Cập nhật danh mục hiện có
  Future<void> updateCategory(String id, String title, String subtitle) async {
    await _categoriesCollection.doc(id).update({'title': title, 'subtitle': subtitle});
  }

  // Xóa một danh mục
  Future<void> deleteCategory(String id) async {
    await _categoriesCollection.doc(id).delete();
  }
}

class HabitCategoryScreen extends StatefulWidget {

  @override
  _HabitCategoryScreenState createState() => _HabitCategoryScreenState();
}

class _HabitCategoryScreenState extends State<HabitCategoryScreen> {
  final HabitCategoryRepository _repository = HabitCategoryRepository();
  List<HabitCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    final categories = await _repository.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _addCategory() async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm Danh Mục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: subtitleController,
              decoration: InputDecoration(labelText: 'Phụ đề'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await _repository.addCategory(
                titleController.text,
                subtitleController.text,
              );
              Navigator.pop(context);
              _loadCategories();
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thêm danh mục thói quen thành công!')),
    );
  }

  Future<void> _editCategory(HabitCategory category) async {
    final titleController = TextEditingController(text: category.title);
    final subtitleController = TextEditingController(text: category.subtitle);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh Sửa Danh Mục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: subtitleController,
              decoration: InputDecoration(labelText: 'Phụ đề'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await _repository.updateCategory(
                category.id,
                titleController.text,
                subtitleController.text,
              );
              Navigator.pop(context);
              _loadCategories();
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('sửa danh mục thói quen thành công!')),
    );
  }

  Future<void> _deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    _loadCategories();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xóa danh mục thói quen thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Danh Mục Thói Quen'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            title: Text(category.title),
            subtitle: Text(category.subtitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editCategory(category),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(category.id),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitScreenAdmin(
                    categoryId: category.id, // ID của danh mục
                    categoryTitle: category.title, // Tên của danh mục
                  ),
                ),
              );
            },

          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
