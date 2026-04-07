import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/policy_model.dart';
import '../../../data/services/policy_service.dart';

class PolicyDetailScreen extends StatefulWidget {
  final String type; 

  const PolicyDetailScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<PolicyDetailScreen> createState() => _PolicyDetailScreenState();
}

class _PolicyDetailScreenState extends State<PolicyDetailScreen> {
  final PolicyService _policyService = PolicyService();
  late Future<PolicyModel?> _policyFuture;

  @override
  void initState() {
    super.initState();
    _policyFuture = _policyService.getPolicy(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String defaultTitle = widget.type == 'TERMS' ? l10n.translate('terms_of_service') : l10n.translate('privacy_policy');

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(defaultTitle, style: TextStyle(color: colorScheme.onSurface, fontSize: 16)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: FutureBuilder<PolicyModel?>(
        future: _policyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      l10n.translate('data_load_error'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() { _policyFuture = _policyService.getPolicy(widget.type); }),
                      child: Text(l10n.translate('retry')),
                    )
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: colorScheme.onSurface.withOpacity(0.5), size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('no_data'),
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() { _policyFuture = _policyService.getPolicy(widget.type); }),
                    child: Text(l10n.translate('retry')),
                  )
                ],
              ),
            );
          }

          final policy = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  policy.getLocalizedTitle(context),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Html(
                  data: policy.getLocalizedContent(context),
                  style: {
                    "body": Style(
                      color: colorScheme.onSurface.withOpacity(0.9),
                      fontSize: FontSize(16.0),
                      lineHeight: LineHeight.em(1.6),
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "h1": Style(color: colorScheme.onSurface, fontWeight: FontWeight.bold, margin: Margins.only(top: 20, bottom: 10)),
                    "h2": Style(color: colorScheme.onSurface, fontWeight: FontWeight.bold, margin: Margins.only(top: 15, bottom: 8)),
                    "p": Style(margin: Margins.only(bottom: 12)),
                    "li": Style(margin: Margins.only(bottom: 6)),
                    "b": Style(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    "strong": Style(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    "a": Style(color: colorScheme.primary, textDecoration: TextDecoration.underline),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}