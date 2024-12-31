import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './article_detail_screen.dart';
class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allBlogs = [];
  List<Map<String, dynamic>> _filteredBlogs = [];
  List<Map<String, dynamic>> _popularBlogs = [];
  bool isShowingArticles = true;
  String _selectedCategory = 'Tất cả';
  bool _isLoading = true;

  final List<String> _categories = [
    'Tất cả',
    'Năng suất',
    'Nước',
    'Tập luyện'
  ];

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBlogs() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore
          .collection('blogs')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _allBlogs = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        // Lọc các bài viết phổ biến (dựa trên lượt xem)
        _popularBlogs = List.from(_allBlogs)
          ..sort((a, b) => (b['views'] ?? 0).compareTo(a['views'] ?? 0));
        _popularBlogs = _popularBlogs.take(5).toList();

        _filterBlogs(_selectedCategory);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  void _filterBlogs(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Tất cả') {
        _filteredBlogs = _allBlogs;
      } else {
        _filteredBlogs = _allBlogs
            .where((blog) => blog['category'] == category)
            .toList();
      }
    });
  }

  void _searchBlogs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterBlogs(_selectedCategory);
      } else {
        _filteredBlogs = _allBlogs.where((blog) {
          final title = blog['title'].toString().toLowerCase();
          final author = blog['author'].toString().toLowerCase();
          final content = blog['content'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return title.contains(searchLower) ||
              author.contains(searchLower) ||
              content.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _incrementViews(String docId) async {
    try {
      await _firestore.collection('blogs').doc(docId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  void _showArticleDetail(Map<String, dynamic> article) {
    _incrementViews(article['id']);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _buildMainContent(),
      ),
    );
  }
  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: isShowingArticles
              ? _buildArticlesContent()
              : _buildProgramsContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Khám phá',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildTabSwitch(),
          if (isShowingArticles) ...[
            SizedBox(height: 16),
            _buildSearchBar(),
            SizedBox(height: 16),
            _buildCategoryFilter(),
          ],
        ],
      ),
    );
  }

  Widget _buildTabSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildTabButton('Bài viết', isShowingArticles),
          _buildTabButton('Chương trình', !isShowingArticles),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isShowingArticles = text == 'Bài viết'),
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

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Tìm kiếm',
          hintStyle: TextStyle(color: Colors.grey),
          icon: Icon(Icons.search, color: Colors.grey),
        ),
        onChanged: _searchBlogs,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          return _buildFilterChip(category);
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String category) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(category),
        onSelected: (bool value) {
          _filterBlogs(category);
        },
        backgroundColor: Colors.grey[900],
        selectedColor: Colors.blue,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildArticlesContent() {
    return RefreshIndicator(
      onRefresh: _fetchBlogs,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Phổ Biến'),
            _buildArticleList(_popularBlogs),
            _buildSectionTitle('Mới Nhất'),
            _buildArticleList(_filteredBlogs),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildArticleList(List<Map<String, dynamic>> blogs) {
    if (blogs.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Không có bài viết nào',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: blogs.length,
        itemBuilder: (context, index) => _buildArticleCard(blogs[index]),
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return GestureDetector(
      onTap: () => _showArticleDetail(article),
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                article['imageUrl'] ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.error, size: 50),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'] ?? 'Không có tiêu đề',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article['author'] ?? 'Không có tác giả',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye, color: Colors.grey, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${article['views'] ?? 0}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsContent() {
    final programs = [
      {
        'title': 'Tăng Năng suất',
        'duration': '15 ngày',
        'color': Colors.teal,
        'icon': Icons.trending_up,
      },
      {
        'title': 'Học một Kỹ năng Mới',
        'duration': '15 ngày',
        'color': Colors.blue,
        'icon': Icons.school,
      },
      {
        'title': 'Thói quen Lành mạnh hơn',
        'duration': '15 ngày',
        'color': Colors.purple,
        'icon': Icons.favorite,
      },
      {
        'title': 'Sức khỏe Tinh thần',
        'duration': '15 ngày',
        'color': Colors.orange,
        'icon': Icons.psychology,
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Color(0xFF1E2746),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program['title'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          program['duration'] as String,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Bắt đầu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: Icon(
                  program['icon'] as IconData,
                  color: (program['color'] as Color).withOpacity(0.3),
                  size: 48,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
