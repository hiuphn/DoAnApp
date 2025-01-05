import 'package:bai5/Admin/admin_screen.dart';
import 'package:bai5/Component/dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bai5/Component/home.dart';
import '../Admin/Blog.dart';
import 'BaseScreen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscureText = true;
  bool _isRegistering = false; // Track if user is registering

  // Function to handle login or register
  Future<void> _submitForm() async {
    if (_isRegistering) {
      await _register();
    } else {
      await _login();
    }
  }

  // Login function
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!isValidInput(email, password)) return;

    setState(() => _isLoading = true);

    try {
      // Xử lý tài khoản admin
      if (email == 'admin@gmail.com' && password == '123aA@') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập với quyền Admin!')),
        );
        _navigateToAdminScreen(); // Chuyển đến trang quản trị
        return;
      }

      // Đăng nhập Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kiểm tra trạng thái blocked trong Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final isBlocked = userDoc.data()?['blocked'] ?? false;

        if (isBlocked) {
          // Nếu tài khoản bị chặn, đăng xuất ngay lập tức
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tài khoản của bạn đã bị chặn. Vui lòng liên hệ quản trị viên.')),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // Nếu đăng nhập thành công và không bị chặn
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thành công!')),
      );
      _navigateToHomeScreen(); // Chuyển đến trang chính
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi đăng nhập
      _handleAuthError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // Register function
  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!isValidInput(email, password)) return;

    setState(() => _isLoading = true);

    try {
      // Tạo tài khoản trong Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin người dùng sau khi đăng ký
      User? user = userCredential.user;

      if (user != null) {
        // Lưu thêm thông tin người dùng vào Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'blocked': false, // Trạng thái mặc định là không bị chặn
          'createdAt': FieldValue.serverTimestamp(), // Thời gian đăng ký
        });

        setState(() => _errorMessage = null);

        // Hiển thị thông báo đăng ký thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng kí thành công! Hãy đăng nhập')),
        );

        // Điều hướng về trang đăng nhập
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi khi đăng ký tài khoản
      _handleAuthError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // Validate input
  bool isValidInput(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Email và mật khẩu không được để trống.");
      return false;
    }
    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      setState(() => _errorMessage = "Định dạng email không hợp lệ.");
      return false;
    }
    return true;
  }

  // Handle Firebase Auth errors
  void _handleAuthError(FirebaseAuthException e) {
    String message = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    if (e.code == 'user-not-found') {
      message = 'Không tìm thấy người dùng với email này.';
    } else if (e.code == 'wrong-password') {
      message = 'Mật khẩu không chính xác.';
    } else if (e.code == 'invalid-email') {
      message = 'Email không hợp lệ.';
    } else if (e.code == 'user-disabled') {
      message = 'Tài khoản của bạn đã bị vô hiệu hóa.';
    } else if (e.code == 'email-already-in-use') {
      message = 'Email đã được sử dụng.';
    } else if (e.code == 'weak-password') {
      message = 'Mật khẩu quá yếu.';
    }
    setState(() => _errorMessage = message);
  }

  // Navigate to home screen
  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BaseScreen()),
    );
  }
  void _navigateToAdminScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminScreen()),
    );
  }
  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E2B3B),
              Color(0xFF2C3E50),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60),
                      // Logo và Branding
                      Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),

                      // Title
                      Text(
                        _isRegistering ? 'Tạo tài khoản mới' : 'Chào mừng trở lại',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          _isRegistering ? 'Vui lòng nhập thông tin' : 'Đăng nhập để tiếp tục',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      SizedBox(height: 48),

                      // Form fields
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Email của bạn',
                        prefix: Icons.email_outlined,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Mật khẩu',
                        prefix: Icons.lock_outline,
                        isPassword: true,
                      ),

                      if (_errorMessage != null) ...[
                        SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      ],

                      SizedBox(height: 24),
                      // Submit button
                      _buildSubmitButton(),

                      Spacer(),
                      // Footer
                      Center(
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isRegistering
                                      ? 'Đã có tài khoản? '
                                      : 'Chưa có tài khoản? ',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isRegistering = !_isRegistering;
                                      _errorMessage = null; // Clear error when switching
                                    });
                                  },
                                  child: Text(
                                    _isRegistering ? 'Đăng nhập' : 'Đăng ký ngay',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Text field widget
  Widget _buildTextField({
  required TextEditingController controller,
    required String hint,
    required IconData prefix,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(prefix, color: Colors.white54),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
        ),
      ),
    );
  }

  // Submit button widget
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3498DB),
            Color(0xFF2980B9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          _isRegistering ? 'ĐĂNG KÝ' : 'ĐĂNG NHẬP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

