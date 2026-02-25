import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/services/fake_auth_api.dart';
import '../widgets/fake_captcha_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isAgreed = false;
  bool _isLoading = false;

  Timer? _countdownTimer;
  int _secondsLeft = 0;
  final int _maxSeconds = 120;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _secondsLeft = _maxSeconds;
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

  void _handleGetVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập E-mail hợp lệ trước')),
      );
      return;
    }

    if (_secondsLeft > 0) return;

    final captchaSuccess = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FakeCaptchaDialog(),
    );

    if (captchaSuccess == true) {
      _startCountdown();
      await FakeAuthApi.sendVerificationCode(email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã xác thực đã được gửi! (Gợi ý: nhập 123456)')),
      );
    }
  }

  void _handleRegister() async {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với Chính sách & Điều khoản')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = await FakeAuthApi.register(
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
          child: Column(
            children: [
              CustomTextField(
                hintText: 'Vui lòng nhập E-mail',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                hintText: 'Vui lòng nhập mã xác thực',
                controller: _codeController,
                keyboardType: TextInputType.number,
                suffixWidget: GestureDetector(
                  onTap: _handleGetVerificationCode,
                  child: Text(
                    _secondsLeft > 0 ? '${_secondsLeft}s' : 'Nhận mã xác thực',
                    style: TextStyle(
                        color: _secondsLeft > 0 ? Colors.white54 : Colors.white,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
              CustomTextField(
                hintText: 'Vui lòng nhập mật khẩu',
                isPassword: true,
                controller: _passwordController,
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
    );
  }
}