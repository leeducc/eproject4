import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/faq_model.dart';

class FAQDetailScreen extends StatelessWidget {
  final FAQModel faq;

  const FAQDetailScreen({Key? key, required this.faq}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(faq.getLocalizedQuestion(context), style: TextStyle(color: colorScheme.onBackground, fontSize: 16)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faq.getLocalizedQuestion(context),
              style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Html(
              data: faq.getLocalizedAnswer(context),
              style: {
                "body": Style(
                  color: colorScheme.onBackground.withOpacity(0.9),
                  fontSize: FontSize(16.0),
                  lineHeight: LineHeight.em(1.5),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "h1": Style(color: colorScheme.onBackground, fontWeight: FontWeight.bold),
                "h2": Style(color: colorScheme.onBackground, fontWeight: FontWeight.bold),
                "p": Style(margin: Margins.only(bottom: 10)),
                "li": Style(margin: Margins.only(bottom: 5)),
                "b": Style(fontWeight: FontWeight.bold, color: colorScheme.onBackground),
                "strong": Style(fontWeight: FontWeight.bold, color: colorScheme.onBackground),
              },
            ),
          ],
        ),
      ),
    );
  }
}
