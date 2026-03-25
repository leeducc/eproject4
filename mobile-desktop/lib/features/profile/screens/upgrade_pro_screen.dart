import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/subscription_service.dart';

class UpgradeProScreen extends StatefulWidget {
  const UpgradeProScreen({Key? key}) : super(key: key);

  @override
  State<UpgradeProScreen> createState() => _UpgradeProScreenState();
}

class _UpgradeProScreenState extends State<UpgradeProScreen> {
  int _selectedPackageIndex = 1;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _packages = [
    {
      'duration': '1 tháng',
      'price': '15,99',
      'originalPrice': null,
      'discount': null,
      'subtitle': '15,99 USD/tháng'
    },
    {
      'duration': '12 tháng',
      'price': '25,99',
      'originalPrice': '102,99',
      'discount': '74% off',
      'subtitle': '2,17 USD/tháng'
    },
    {
      'duration': 'PLUS trọn đời',
      'price': '109,99',
      'originalPrice': null,
      'discount': null,
      'subtitle': 'Thanh toán 1 lần'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanTabs(),
                    const SizedBox(height: 16),
                    _buildPackages(),

                    const SizedBox(height: 30),
                    _buildBuyButton(),

                    const SizedBox(height: 16),
                    _buildFooterText(),
                  ],
                ),
              ),
              _buildContentBelow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTabs() {
    return Row(
      children: [
        _buildTab('PLUS', true),
        const SizedBox(width: 16),
        _buildTab('MAX', false),
      ],
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Text(
      text,
      style: TextStyle(
        color: isActive ? Colors.orange : Colors.grey,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 230,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Center(
            child: Text(
              'Mùa xuân gieo hạt giống\nNăm sau gặt thành công!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackages() {
    return Row(
      children: List.generate(_packages.length, (index) {
        final p = _packages[index];
        final isSelected = _selectedPackageIndex == index;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPackageIndex = index),
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == _packages.length - 1 ? 0 : 6,
              ),
              height: 155,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // CARD BACKGROUND
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isSelected
                          ? const LinearGradient(
                        colors: [Color(0xFFFFE29F), Color(0xFFFFC371)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                          : null,
                      color: isSelected ? null : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.orange
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 14,
                    left: 3,
                    right: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // TITLE
                        SizedBox(
                          height: 16,
                          child: Text(
                            p['duration'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF5A3E2B)
                                  : Colors.black87,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // PRICE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              p['price'],
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? const Color(0xFF5A3E2B)
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                'USD',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF5A3E2B)
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // 🔥 ORIGINAL PRICE (ĐẸP + RÕ)
                        SizedBox(
                          height: 16,
                          child: p['originalPrice'] != null
                              ? Text(
                            '${p['originalPrice']} USD',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 3,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF5A3E2B)
                                  : Colors.black,
                            ),
                          )
                              : null,
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFD89B)
                            : const Color(0xFFF3F4F6),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        p['subtitle'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF5A3E2B)
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // BADGE
                  if (p['discount'] != null)
                    Positioned(
                      top: -10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B00),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          p['discount'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBuyButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () {},
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B61FF), Color(0xFF9F7AEA)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              'Mua ngay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return const Text(
      'Bấm vào mua/gia hạn nghĩa là bạn đã đọc và đồng ý với điều khoản sử dụng',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey, fontSize: 12),
    );
  }
  Widget _buildContentBelow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 DIVIDER TRÊN CÙNG
        _buildDivider(),

        const SizedBox(height: 10),

        // ===== BAO ĐỖ HSK =====
        const Center(
          child: Text(
            'Bao đỗ HSK',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _buildFeatureItem(
          icon: Icons.show_chart,
          title: 'Thiết kế khoá học',
          desc:
          'Sự kết hợp giữa 20 năm kinh nghiệm giảng dạy và dữ liệu 100 triệu lần trả lời câu hỏi',
          colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
        ),

        _buildFeatureItem(
          icon: Icons.security,
          title: 'Trí tuệ nhân tạo AI',
          desc: 'Luyện tập được cá nhân hoá, học từ dễ đến khó',
          colors: [Color(0xFFFFC371), Color(0xFFFFE29F)],
        ),

        _buildFeatureItem(
          icon: Icons.track_changes,
          title: 'Nâng cao điểm số',
          desc:
          'Luyện tập trọng điểm, nâng cao điểm số một cách hiệu quả',
          colors: [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
        ),

        _buildDivider(),

        // ===== LUYỆN TẬP KỸ NĂNG =====
        const Center(
          child: Text(
            'Luyện tập kỹ năng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 16),

        _buildSkillItem(
          title: 'Đề thi thật, đề mô phỏng',
          desc:
          'Mô phỏng theo đề HSK, giúp bạn làm quen hoàn toàn với các dạng đề thi',
          colors: [Color(0xFFFF7E5F), Color(0xFFFF4E50)],
          icon: Icons.description,
        ),

        _buildSkillItem(
          title: 'Luyện tập từ vựng',
          desc:
          'Học và luyện từ vựng xuất hiện nhiều trong bài thi',
          colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
          icon: Icons.translate,
        ),

        _buildSkillItem(
          title: 'Nghe - Đọc - Viết',
          desc: 'Từng dạng đề luyện tập theo kỹ năng',
          colors: [Color(0xFF6A82FB), Color(0xFF5F72BD)],
          icon: Icons.headphones,
        ),

        const SizedBox(height: 20),
      ],
    );
  }
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width,
      height: 8,
      color: const Color(0xFF1E293B),
    );
  }
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String desc,
    required List<Color> colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _buildSkillItem({
    required String title,
    required String desc,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 🔥 ICON STYLE GIỐNG ẢNH
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}