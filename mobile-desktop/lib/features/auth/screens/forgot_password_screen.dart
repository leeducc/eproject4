import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/localization/app_localizations.dart';
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
        if (mounted) setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _requestOtp() async {
    debugPrint('[ForgotPasswordScreen] _requestOtp triggered');
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
      debugPrint('[ForgotPasswordScreen] sending code');
      _startCooldown();
      await AuthApi.sendForgotPasswordOtp(email, captchaToken);

      if (!mounted) return;
      setState(() {
        _hasRequestedOtp = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('verification_code_sent'))),
      );
    }
  }

  void _handleChangePassword() {
    debugPrint('[ForgotPasswordScreen] _handleChangePassword triggered');
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
    debugPrint('[ForgotPasswordScreen] build triggered');
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  l10n.translate('forgot_password_title'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.translate('enter_registered_email_for_otp'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
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
                  hintText: l10n.translate('verification_code_placeholder'),
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
                            l10n.translate('get_code'),
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : (_secondsLeft > 0
                          ? Text(
                              '${_secondsLeft}s',
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 13),
                            )
                          : GestureDetector(
                              onTap: _requestOtp,
                              child: Text(
                                l10n.translate('resend'),
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            )),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: l10n.translate('change_password_button'),
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