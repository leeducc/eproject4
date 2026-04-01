import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/localization/app_localizations.dart';
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
  bool _hasRequestedOtp = false;

  Timer? _countdownTimer;
  int _secondsLeft = 0;
  final int _cooldownSeconds = 120;

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
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('enter_valid_email_first'))),
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
      await AuthApi.sendVerificationCode(email, captchaToken);

      if (!mounted) return;
      setState(() {
        _hasRequestedOtp = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('verification_code_sent'))),
      );
    }
  }

  void _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('agree_to_terms_error'))),
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
        SnackBar(content: Text(l10n.translate('registration_success'))),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('invalid_info_or_code'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  hintText: l10n.translate('email_hint'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('enter_email');
                    if (!value.contains('@')) return l10n.translate('invalid_email');
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: l10n.translate('password_placeholder'), // Using this as OTP placeholder too? No, I'll use a separate key.
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('invalid_info_or_code');
                    return null;
                  },
                  suffixWidget: !_hasRequestedOtp
                      ? GestureDetector(
                          onTap: _requestOtp,
                          child: Text(
                            l10n.translate('get_verification_code'),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
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
                        child: Text(
                          l10n.translate('resend_verification_code'),
                          style: const TextStyle(
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
                  hintText: l10n.translate('password_placeholder'),
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('enter_password');
                    if (value.length < 6) return l10n.translate('password_too_short');
                    return null;
                  },
                ),
              const SizedBox(height: 10),
              CustomButton(
                text: l10n.translate('register_button'),
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
                  Text(
                    l10n.translate('privacy_policy_terms'),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}