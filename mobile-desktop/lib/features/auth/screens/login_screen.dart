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
    debugPrint('[LoginScreen] _handleLogin triggered');
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
      debugPrint('[LoginScreen] login success');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('login_success'))),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else {
      debugPrint('[LoginScreen] login failed: ${response['error']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'] ?? l10n.translate('enter_password'))),
      );
    }
  }

  void _handleGoogleLogin() async {
    debugPrint('[LoginScreen] _handleGoogleLogin triggered');
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    final response = await AuthApi.loginWithGoogle();
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (response != null && !response.containsKey('error')) {
      debugPrint('[LoginScreen] google login success');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('google_login_success'))),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else if (response != null && response.containsKey('error')) {
      debugPrint('[LoginScreen] google login failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('error_prefix', params: {'error': response['error']}))),
      );
    }
  }

  void _handleQuickLogin() {
    debugPrint('[LoginScreen] _handleQuickLogin triggered');
    final l10n = AppLocalizations.of(context)!;
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
    debugPrint('[LoginScreen] build triggered');
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Guard: localizations delegate loads asynchronously.
    // On the very first frame it may be null — return a blank scaffold
    // so we never null-assert and cause a silent black screen crash.
    if (l10n == null) {
      debugPrint('[LoginScreen] l10n not ready yet – showing loader');
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 🔴 DIAGNOSTIC: Temporary red background — remove after confirming render works
    return Container(
      color: Colors.red,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          size: 80,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        l10n.translate('app_name'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        l10n.translate('login_to_continue'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
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
                      hintText: l10n.translate('password_placeholder'),
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.translate('enter_password');
                        if (value.length < 6) return l10n.translate('password_too_short');
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          l10n.translate('forgot_password'),
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: l10n.translate('login_button'),
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider(color: theme.dividerColor.withOpacity(0.1))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.translate('or_separator'),
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(child: Divider(color: theme.dividerColor.withOpacity(0.1))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _socialButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: "Google",
                            onPressed: _handleGoogleLogin,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _socialButton(
                            icon: Icons.bolt_rounded,
                            label: l10n.translate('try_guest'),
                            onPressed: _handleQuickLogin,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.translate('no_account'),
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            },
                            child: Text(
                              l10n.translate('register_now'),
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ); // diagnostic Container
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: theme.colorScheme.onSurface),
      label: Text(
        label,
        style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
      ),
    );
  }
}