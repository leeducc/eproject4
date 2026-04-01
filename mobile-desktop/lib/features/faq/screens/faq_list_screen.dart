import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/faq_model.dart';
import '../../../data/services/faq_service.dart';
import 'faq_detail_screen.dart';

class FAQListScreen extends StatefulWidget {
  const FAQListScreen({Key? key}) : super(key: key);

  @override
  State<FAQListScreen> createState() => _FAQListScreenState();
}

class _FAQListScreenState extends State<FAQListScreen> {
  final FAQService _faqService = FAQService();
  late Future<List<FAQModel>> _faqsFuture;

  @override
  void initState() {
    super.initState();
    _faqsFuture = _faqService.getFAQs();
  }

  Future<void> _refreshFAQs() async {
    setState(() {
      _faqsFuture = _faqService.getFAQs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.translate('faq'), style: TextStyle(color: colorScheme.onBackground, fontSize: 18)),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFAQs,
        color: colorScheme.primary,
        child: FutureBuilder<List<FAQModel>>(
          future: _faqsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: colorScheme.primary));
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
                        style: TextStyle(color: colorScheme.onBackground),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshFAQs,
                        child: Text(l10n.translate('retry')),
                      )
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, color: colorScheme.onBackground.withOpacity(0.5), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      l10n.translate('no_data'),
                      style: TextStyle(color: colorScheme.onBackground.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _refreshFAQs,
                      child: Text(l10n.translate('retry')),
                    )
                  ],
                ),
              );
            }

            final faqs = snapshot.data!;
            return ListView.separated(
              itemCount: faqs.length,
              separatorBuilder: (context, index) => Divider(color: Theme.of(context).dividerTheme.color, height: 1),
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return ListTile(
                  title: Text(
                    faq.getLocalizedQuestion(context),
                    style: TextStyle(color: colorScheme.onBackground, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.chevron_right, color: colorScheme.onBackground.withOpacity(0.5), size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FAQDetailScreen(faq: faq),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
