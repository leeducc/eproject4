import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/policy_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/services/policy_service.dart';
import '../../../data/services/profile_api.dart';
import '../../auth/screens/login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isLoading = false;
  bool _isFetchingPolicy = true;
  PolicyModel? _policy;
  final PolicyService _policyService = PolicyService();

  @override
  void initState() {
    super.initState();
    _fetchPolicy();
    _startTimer();
  }

  Future<void> _fetchPolicy() async {
    try {
      final policy = await _policyService.getPolicy('DELETE_ACCOUNT');
      if (mounted) {
        setState(() {
          _policy = policy;
          _isFetchingPolicy = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching delete policy: $e');
      if (mounted) {
        setState(() => _isFetchingPolicy = false);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showConfirmationDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2531),
        title: Text(
          l10n.translate('delete_confirmation_title'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.translate('confirm_delete_msg'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel'), style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDeleteAccount();
            },
            child: Text(
              l10n.translate('confirm_button'),
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    
    final success = await ProfileApi.deleteAccount();
    
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('delete_success'))),
      );
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('delete_failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.translate('delete_account_policy_title'),
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isFetchingPolicy 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          _policy?.getLocalizedTitle(context) ?? l10n.translate('delete_account_policy_title'),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_policy != null)
                    Html(
                      data: _policy!.getLocalizedContent(context),
                      style: {
                        "body": Style(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          fontSize: FontSize(15),
                          lineHeight: LineHeight.number(1.6),
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        "strong": Style(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        "li": Style(margin: Margins.only(bottom: 8)),
                      },
                    )
                  else
                    Text(
                      l10n.translate('delete_account_policy_text'),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CustomButton(
                  text: _secondsRemaining > 0
                      ? l10n.translate('wait_seconds_to_confirm', params: {'seconds': _secondsRemaining.toString()})
                      : l10n.translate('confirm_delete_account'),
                  isLoading: _isLoading,
                  onPressed: (_secondsRemaining > 0 || _isFetchingPolicy) ? () {} : _showConfirmationDialog,
                ),
                if (_secondsRemaining > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      l10n.translate('wait_seconds_to_confirm', params: {'seconds': _secondsRemaining.toString()}),
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}