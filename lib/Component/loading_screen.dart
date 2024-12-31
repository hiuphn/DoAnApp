import 'package:flutter/material.dart';
import 'package:bai5/Component/LoginFirebase.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Chào mừng đến với Ứng dụng của chúng tôi!',
      'description': 'Những tính năng tuyệt vời của ứng dụng.',
      'imageUrl': 'assets/images/nen.jpg',
      'backgroundColor': '#F0F4F8',
      'textColor': '#D9EAFD',
      'icon': Icons.waving_hand

    },
    {
      'title': 'Dễ dàng sử dụng',
      'description': 'Giao diện thân thiện, dễ dàng thao tác.',
      'imageUrl': 'assets/images/nen.jpg', // URL ảnh GIF
      'backgroundColor': '#E8F5E9',
      'textColor': '#118B50',
      'icon': Icons.touch_app,
    },
    {
      'title': 'Kết nối mọi lúc mọi nơi',
      'description': 'Luôn kết nối và cập nhật thông tin mới nhất.',
      'imageUrl': 'assets/images/nen.jpg', // URL ảnh GIF
      'backgroundColor': '#FFF3E0',
      'textColor': '#E65100',
      'icon': Icons.network_check,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_onboardingData[index]);
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _currentPage == _onboardingData.length - 1
                ? ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(int.parse(_onboardingData[_currentPage]['textColor']!.substring(1, 7), radix: 16) + 0xFF000000),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Bắt đầu'),
            )
                : SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: data['imageUrl'].startsWith('assets/')
              ? AssetImage(data['imageUrl']) as ImageProvider
              : NetworkImage(data['imageUrl']),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          if (data['decorationUrl'] != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: 0.3,
                child: data['decorationUrl'].startsWith('assets/')
                    ? Image.asset(
                  data['decorationUrl'],
                  width: 200,
                  errorBuilder: (context, error, stackTrace) {
                    print('Lỗi tải ảnh trang trí: $error');
                    return Icon(Icons.error, size: 50, color: Colors.red);
                  },
                )
                    : Image.network(
                  data['decorationUrl'],
                  width: 200,
                  errorBuilder: (context, error, stackTrace) {
                    print('Lỗi tải ảnh trang trí: $error');
                    return Icon(Icons.error, size: 50, color: Colors.red);
                  },
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data['icon'],
                size: 60,
                color: Color(int.parse(data['textColor']!.substring(1, 7), radix: 16) + 0xFF000000),
              ),
              SizedBox(height: 20),
              // Loại bỏ Image.asset/Image.network ở đây vì đã làm nền
              SizedBox(height: 30),
              Text(
                data['title']!,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse(data['textColor']!.substring(1, 7), radix: 16) + 0xFF000000),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                data['description']!,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(int.parse(data['textColor']!.substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _onboardingData.length; i++) {
      indicators.add(
        Container(
          width: 10,
          height: 10,
          margin: EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i
                ? Color(int.parse(_onboardingData[i]['textColor']!.substring(1, 7), radix: 16) + 0xFF000000)
                : Colors.grey,
          ),
        ),
      );
    }
    return indicators;
  }
}
