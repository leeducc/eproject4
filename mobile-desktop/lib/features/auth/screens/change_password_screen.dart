import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/services/auth_api.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ChangePasswordScreen({
    Key? key,
    required this.email,
    required this.code,
  }) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    debugPrint('[ChangePasswordScreen] _handleResetPassword triggered');
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    bool success = await AuthApi.resetPassword(
      widget.email,
      widget.code,
      _newPasswordController.text,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      debugPrint('[ChangePasswordScreen] password reset success');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('change_password_success'))),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      debugPrint('[ChangePasswordScreen] password reset failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('invalid_or_expired_code'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[ChangePasswordScreen] build triggered');
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
                  l10n.translate('set_new_password_title'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.translate('enter_new_password_for_account'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  hintText: l10n.translate('new_password_placeholder'),
                  isPassword: true,
                  controller: _newPasswordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('please_enter_new_password');
                    if (value.length < 8) return l10n.translate('password_too_short');
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: l10n.translate('confirm_password_placeholder'),
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.translate('please_re_enter_password');
                    if (value != _newPasswordController.text) return l10n.translate('passwords_dont_match');
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: l10n.translate('confirm_button'),
                  isLoading: _isLoading,
                  onPressed: _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}