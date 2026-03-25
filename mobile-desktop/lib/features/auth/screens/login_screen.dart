import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/services/auth_api.dart';
import '../../main_layout/screens/main_layout.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final response = await AuthApi.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'] ?? 'Sai email hoặc mật khẩu.')),
      );
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final response = await AuthApi.loginWithGoogle();
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (response != null && !response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập Google thành công!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else if (response != null && response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${response['error']}')),
      );
    }
  }

  void _handleQuickLogin() {
    debugPrint('Quick login triggered: user1@gmail.com / User@123');
    setState(() {
      _emailController.text = 'user1@gmail.com';
      _passwordController.text = 'User@123';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tự động điền thông tin đăng nhập!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                CustomTextField(
                  hintText: 'Tài khoản (Email)',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập Email';
                    if (!value.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: 'Vui lòng nhập mật khẩu',
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (value.length < 6) return 'Mật khẩu phải từ 6 ký tự';
                    return null;
                  },
                ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Đăng nhập',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Đăng nhập bằng Google',
                isLoading: _isLoading,
                onPressed: _handleGoogleLogin,
                // You can add a different color/style in CustomButton if it supports it
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Quick Login',
                isLoading: _isLoading,
                onPressed: _handleQuickLogin,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Quên mật khẩu',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Chưa có tài khoản , đăng kí ngay',
                    style: TextStyle(color: Color(0xFF3A7BD5), fontSize: 15),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}