// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   String? _errorMessage;
//   bool _isLoading = false;
//
//   Future<void> _login() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     final String apiUrl = 'http://192.168.1.56:8080/api/login'; // Sử dụng 10.0.2.2 cho Android emulator
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'username': _usernameController.text,
//           'password': _passwordController.text,
//         }),
//       );
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = jsonDecode(response.body);
//         if (responseData['status'] == 'success') {
//           setState(() {
//             _errorMessage = null;
//             _isLoading = false;
//             Navigator.pushNamed(context, '/profile');
//           });
//
//           // Show success dialog
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text('Success'),
//                 content: Text('Login successful'),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       // Navigate to the next screen or handle successful login
//                     },
//                     child: Text('OK'),
//                   ),
//                 ],
//               );
//             },
//           );
//         } else {
//           setState(() {
//             _errorMessage = responseData['message'];
//             _isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           _errorMessage = 'Server error: ${response.statusCode}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to connect to the server: $e';
//         _isLoading = false;
//       });
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blueGrey[50],
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Logo
//               CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.blueAccent,
//                 child: Icon(
//                   Icons.person,
//                   color: Colors.white,
//                   size: 50,
//                 ),
//               ),
//               SizedBox(height: 30),
//
//               // Title
//               Text(
//                 'Welcome Back!',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'Log in to your account',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//               SizedBox(height: 30),
//
//               // Username TextField
//               TextField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.person),
//                   labelText: 'Username',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//
//               // Password TextField
//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.lock),
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//
//               // Error Message
//               if (_errorMessage != null)
//                 Text(
//                   _errorMessage!,
//                   style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                 ),
//               SizedBox(height: 10),
//
//               // Login Button
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _login,
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: _isLoading
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text(
//                   'Log In',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
