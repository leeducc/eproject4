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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

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
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
    debugPrint('[RegisterScreen] _requestOtp triggered');
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('enter_valid_email_first'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    final isAvailable = await AuthApi.checkEmailAvailable(email);
    setState(() => _isLoading = false);

    if (!isAvailable) {
      debugPrint('[RegisterScreen] email already registered');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email đã được sử dụng')),
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
      debugPrint('[RegisterScreen] captcha verified, sending code');
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
    debugPrint('[RegisterScreen] _handleRegister triggered');
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('passwords_dont_match'))),
      );
      return;
    }

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
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _addressController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      debugPrint('[RegisterScreen] registration success');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('registration_success'))),
      );
      Navigator.pop(context);
    } else {
      debugPrint('[RegisterScreen] registration failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('invalid_info_or_code'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[RegisterScreen] build triggered');
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
        title: Text(
          l10n.translate('register_title'),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                   l10n.translate('join_us'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('register_subtitle'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  hintText: l10n.translate('full_name_hint'),
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('enter_full_name');
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: l10n.translate('phone_number_hint'),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('enter_phone_number');
                    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) return l10n.translate('invalid_phone_number');
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: l10n.translate('address_hint'),
                  controller: _addressController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('enter_address');
                    return null;
                  },
                ),
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
                CustomTextField(
                  hintText: l10n.translate('password_placeholder'),
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('enter_password');
                    if (value.length < 8) return l10n.translate('password_too_short');
                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(value)) {
                      return 'Mật khẩu phải bao gồm chữ hoa, chữ thường và số';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: l10n.translate('confirm_password_placeholder'),
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('please_re_enter_password');
                    if (value != _passwordController.text) return l10n.translate('passwords_dont_match');
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isAgreed,
                        onChanged: (val) => setState(() => _isAgreed = val ?? false),
                        activeColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAgreed = !_isAgreed),
                        child: Text(
                          l10n.translate('privacy_policy_terms'),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: l10n.translate('register_button'),
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}