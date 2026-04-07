import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WrongAnswersScreen extends StatelessWidget {
  const WrongAnswersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Luyện Nghe IELTS',
          style: TextStyle(color: context.colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          'Nội dung phần Nghe sẽ nằm ở đây',
          style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16),
        ),
      ),
    );
  }
}