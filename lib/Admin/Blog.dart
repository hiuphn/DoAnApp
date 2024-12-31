import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_screen.dart';
import 'CustomDrawer.dart';  // Import CustomDrawer
import 'CustomAppBar.dart';  // Import CustomAppBar

class BlogScreen extends StatefulWidget {
  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _blogs = [];
  String _selectedCategory = 'Tất cả';
  List<String> _categories = ['Tất cả', 'Năng suất', 'Nước', 'Tập luyện'];

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _imageUrlController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _fetchBlogs() async {
    try {
      final snapshot = await _firestore
          .collection('blogs')
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        _blogs = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  Future<void> _addBlogs() async {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || author.isEmpty || imageUrl.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    try {
      await _firestore.collection('blogs').add({
        'title': title,
        'author': author,
        'imageUrl': imageUrl,
        'content': content,
        'category': _selectedCategory,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'views': 0,
      });

      _clearInputs();
      _fetchBlogs();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm bài viết thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm bài viết: $e')),
      );
    }
  }

  void _clearInputs() {
    _titleController.clear();
    _authorController.clear();
    _imageUrlController.clear();
    _contentController.clear();
    setState(() {
      _selectedCategory = 'Tất cả';
    });
  }

  Future<void> _updateBlogs(String docId) async {
    try {
      await _firestore.collection('blogs').doc(docId).update({
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _fetchBlogs();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật bài viết thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật bài viết: $e')),
      );
    }
  }

  Future<void> _deleteBlogs(String docId) async {
    try {
      await _firestore.collection('blogs').doc(docId).delete();
      _fetchBlogs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa bài viết thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa bài viết: $e')),
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> article) {
    _titleController.text = article['title'] ?? '';
    _authorController.text = article['author'] ?? '';
    _imageUrlController.text = article['imageUrl'] ?? '';
    _contentController.text = article['content'] ?? '';
    setState(() {
      _selectedCategory = article['category'] ?? 'Tất cả';
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa bài viết', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
              ),
              TextField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Tác giả'),
              ),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'URL ảnh'),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Nội dung'),
                maxLines: 5,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Danh mục'),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _updateBlogs(article['id']);
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey), // Sử dụng CustomAppBar
      drawer: CustomDrawer(scaffoldKey: _scaffoldKey), // Sử dụng CustomDrawer
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form thêm bài viết
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(_titleController, 'Tiêu đề'),
                    SizedBox(height: 12),
                    _buildTextField(_authorController, 'Tác giả'),
                    SizedBox(height: 12),
                    _buildTextField(_imageUrlController, 'URL hình ảnh'),
                    SizedBox(height: 12),
                    _buildTextField(_contentController, 'Nội dung', maxLines: 3),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addBlogs,
                      child: Text('Thêm bài viết'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Danh sách bài viết
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListView.builder(
                  itemCount: _blogs.length,
                  itemBuilder: (context, index) {
                    final article = _blogs[index];
                    return ListTile(
                      leading: article['imageUrl'] != null
                          ? Image.network(
                        article['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, color: Colors.red);
                        },
                      )
                          : Icon(Icons.image_not_supported),
                      title: Text(
                        article['title'] ?? 'Không có tiêu đề',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article['author'] ?? 'Không có tác giả'),
                          Text(
                            'Danh mục: ${article['category'] ?? 'Không có danh mục'}',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(article),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Xác nhận xóa'),
                                content: Text('Bạn có chắc muốn xóa bài viết này?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteBlogs(article['id']);
                                    },
                                    child: Text('Xóa'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int? maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      maxLines: maxLines,
    );
  }
}
