import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/localization/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.translate('login_success'))),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'] ?? l10n.translate('enter_password'))), // Fallback if error not provided
      );
    }
  }

  void _handleGoogleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    final response = await AuthApi.loginWithGoogle();
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (response != null && !response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('google_login_success'))),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else if (response != null && response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('error_prefix', params: {'error': response['error']}))),
      );
    }
  }

  void _handleQuickLogin() {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('Quick login triggered: user1@gmail.com / User@123');
    setState(() {
      _emailController.text = 'user1@gmail.com';
      _passwordController.text = 'User@123';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.translate('quick_login_filled'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                text: l10n.translate('login_button'),
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: l10n.translate('login_google'),
                isLoading: _isLoading,
                onPressed: _handleGoogleLogin,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: l10n.translate('quick_login'),
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
                  child: Text(
                    l10n.translate('forgot_password'),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                  child: Text(
                    l10n.translate('no_account_register'),
                    style: const TextStyle(color: Color(0xFF3A7BD5), fontSize: 15),
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