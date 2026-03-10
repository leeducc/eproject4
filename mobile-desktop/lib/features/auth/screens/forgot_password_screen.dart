import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/services/auth_api.dart';
import '../widgets/captcha_dialog.dart';
import 'change_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  bool _hasRequestedOtp = false;

  Timer? _countdownTimer;
  int _secondsLeft = 0;
  final int _cooldownSeconds = 120;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsLeft = _cooldownSeconds;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _requestOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập E-mail hợp lệ trước')),
      );
      return;
    }

    if (_secondsLeft > 0) return;

    final String? captchaToken = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CaptchaDialog(),
    );

    if (captchaToken != null && captchaToken.isNotEmpty) {
      _startCooldown();
      await AuthApi.sendForgotPasswordOtp(email, captchaToken);

      if (!mounted) return;
      setState(() {
        _hasRequestedOtp = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã xác thực đã được gửi! (Kiểm tra email của bạn)')),
      );
    }
  }

  void _handleChangePassword() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(email: email, code: code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quên mật khẩu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhập email đã đăng ký để nhận mã xác thực',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  hintText: 'Vui lòng nhập E-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập Email';
                    if (!value.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: 'Vui lòng nhập mã xác thực',
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập mã xác thực';
                    return null;
                  },
                  suffixWidget: !_hasRequestedOtp
                      ? GestureDetector(
                          onTap: _requestOtp,
                          child: const Text(
                            'Nhận mã xác thực',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        )
                      : (_secondsLeft > 0
                          ? Text(
                              '${_secondsLeft}s',
                              style: const TextStyle(color: Colors.white54, fontSize: 14),
                            )
                          : null),
                ),
                if (_hasRequestedOtp && _secondsLeft == 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _requestOtp,
                        child: const Text(
                          'Nhận lại mã xác thực',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Đổi mật khẩu',
                  isLoading: _isLoading,
                  onPressed: _handleChangePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
