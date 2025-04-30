// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _animateLogo();
    _checkLoginStatus();
  }
  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // để logo fade in

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'];

        if (role == 'business') {
          Navigator.pushReplacementNamed(context, '/coupon');
        } else if (role == 'traveler') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          Navigator.pushReplacementNamed(context, '/signin'); // Nếu role lỗi
        }
      } else {
        Navigator.pushReplacementNamed(context, '/signin'); // Không tìm thấy user
      }
    } else {
      // Chưa đăng nhập
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  void _animateLogo() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _opacity = 1;
    });
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          child: Image.asset(
            'assets\\splash_screen.png',
            height: 150,
          ),
        ),
      ),
    );
  }
}
