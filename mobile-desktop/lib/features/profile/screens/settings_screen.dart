import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEffects = true;
  bool _nightMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildSettingsItem('Cài đặt ngôn ngữ', trailingText: 'Tiếng Việt'),
          _buildSettingsItem('Nhắc nhở học tập'),
          _buildSettingsSwitch('Hiệu ứng âm thanh', _soundEffects, (value) {
            setState(() {
              _soundEffects = value;
            });
          }),
          _buildSettingsItem('Cỡ chữ'),
          _buildDivider(),
          _buildSettingsItem('Hướng dẫn sử dụng'),
          _buildSettingsItem('Nạp thẻ VIP'),
          _buildDivider(),
          _buildSettingsItem('Xóa cache'),
          _buildDivider(),
          _buildSettingsItem('Theo dõi chúng tôi'),
          _buildSettingsItem('Về chúng tôi'),
          _buildDivider(),
          _buildSettingsItem('Chia sẻ APP'),
          _buildSettingsItem('Ý kiến phản hồi'),
          _buildDivider(),
          _buildSettingsSwitch('Chế độ ban đêm', _nightMode, (value) {
            setState(() {
              _nightMode = value;
            });
          }),
          _buildDivider(),
          _buildSettingsItem('Xoá tài khoản'),
          _buildDivider(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () {},
              child: const Text('Thoát', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, {String? trailingText}) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          if (trailingText != null) const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ],
      ),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
    );
  }

  Widget _buildSettingsSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: AppColors.primaryBlue,
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.05), height: 1, thickness: 1);
  }
}
