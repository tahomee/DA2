import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Mật khẩu không khớp.';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // (Tuỳ chọn) cập nhật tên hiển thị
      await _auth.currentUser?.updateDisplayName(_userNameController.text.trim());
      await _auth.currentUser?.sendEmailVerification();
      // Sau khi đăng ký thành công, quay lại màn hình login
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/splash_screen.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  'ĐĂNG KÝ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color:  Color(0xFF3B6332),
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(_emailController, 'Email'),
                const SizedBox(height: 20),
                _buildTextField(_userNameController, 'Tên hiển thị'),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, 'Mật khẩu', isPassword: true),
                const SizedBox(height: 20),
                _buildTextField(_confirmPasswordController, 'Xác nhận mật khẩu', isPassword: true),
                const SizedBox(height: 20),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 10),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60B0D1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    elevation: 5,
                  ),
                  onPressed: _signUp,
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Bạn đã có tài khoản? ',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color:  Color(0xFFFFD166),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Quay lại màn hình đăng nhập
                      },
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color:Color(0xFF60B0D1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color:Color(0xFF3B6332),
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
        filled: true,
        fillColor: const Color(0xFFFFD166),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
