import 'package:flutter/material.dart';

class WritingScreen extends StatelessWidget {
  const WritingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161A23), // Màu nền tối đồng nhất
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Luyện Nghe IELTS', // Đổi tên tương ứng ở các file khác
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          'Nội dung phần Nghe sẽ nằm ở đây',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      ),
    );
  }
}