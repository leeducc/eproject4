import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/services/auth_api.dart';
import '../widgets/captcha_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isAgreed = false;
  bool _isLoading = false;
  bool _hasRequestedOtp = false; // Track if user has requested OTP at least once

  Timer? _countdownTimer;
  int _secondsLeft = 0;
  final int _cooldownSeconds = 120; // Cooldown before user can request a new OTP

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
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

    if (_secondsLeft > 0) return; // Still in cooldown

    final String? captchaToken = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CaptchaDialog(),
    );

    if (captchaToken != null && captchaToken.isNotEmpty) {
      _startCooldown();
      await AuthApi.sendVerificationCode(email, captchaToken);

      if (!mounted) return;
      setState(() {
        _hasRequestedOtp = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã xác thực đã được gửi! (Kiểm tra email của bạn)')),
      );
    }
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với Chính sách & Điều khoản')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = await AuthApi.register(
      _emailController.text.trim(),
      _codeController.text.trim(),
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng kí thành công!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thông tin không hợp lệ hoặc sai mã xác thực')),
      );
    }
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
              children: [
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
                // OTP code field with inline "get code" button (first time)
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
                // "Nhận lại mã xác thực" button - only shown after first OTP request
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
                text: 'Đăng kí',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isAgreed = !_isAgreed),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isAgreed ? Colors.white : Colors.transparent,
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                      child: _isAgreed
                          ? const Icon(Icons.check, size: 14, color: Colors.black)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Chính sách Bảo mật & Điều khoản Dịch vụ',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
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
}