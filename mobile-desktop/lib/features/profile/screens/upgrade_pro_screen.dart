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
      'price': 1000,
      'originalPrice': null,
      'discount': null,
      'subtitle': '1000 iCoin/tháng'
    },
    {
      'duration': '12 tháng',
      'price': 5000,
      'originalPrice': 12000,
      'discount': '58% off',
      'subtitle': '416 iCoin/tháng'
    },
    {
      'duration': 'PLUS trọn đời',
      'price': 8000,
      'originalPrice': null,
      'discount': null,
      'subtitle': 'Thanh toán 1 lần'
    },
  ];

  @override
  Widget build(BuildContext context) {
    print('Building UpgradeProScreen');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PLUS',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPackages(),
                      const SizedBox(height: 32),
                      _buildBuyButton(),
                      const SizedBox(height: 16),
                      _buildFooterText(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 250,
      decoration: const BoxDecoration(
        color: Colors.blue,
        gradient: LinearGradient(
          colors: [Color(0xFF3A7BD5), Color(0xFF3A6073)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                print('Navigating back from UpgradeProScreen');
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 70,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'SuperTest PLUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Chuẩn bị IELTS một cách\ndễ dàng và hiệu quả',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackages() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_packages.length, (index) {
        final package = _packages[index];
        final isSelected = _selectedPackageIndex == index;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              print('Selected package index $index - ${package['duration']}');
              setState(() {
                _selectedPackageIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == _packages.length - 1 ? 0 : 8,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFE0B2) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          package['duration'],
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${package['price']}',
                              style: TextStyle(
                                color: isSelected ? Colors.brown[800] : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'iCoin',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        if (package['originalPrice'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${package['originalPrice']} iCoin',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 14),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange[200] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            package['subtitle'],
                            style: TextStyle(
                              color: isSelected ? Colors.brown[800] : Colors.black54,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (package['discount'] != null)
                    Positioned(
                      top: -10,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          package['discount'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
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
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                final package = _packages[_selectedPackageIndex];
                final price = package['price'] as int;
                
                int months = 1;
                if (_selectedPackageIndex == 1) months = 12;
                if (_selectedPackageIndex == 2) months = 1200; // Lifetime

                print('Mua ngay tapped for package: ${package['duration']}, price: $price iCoin');
                
                setState(() {
                  _isLoading = true;
                });

                bool success = await SubscriptionService.purchasePro(months, price);

                if (!mounted) return;

                setState(() {
                  _isLoading = false;
                });

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nâng cấp PLUS thành công!')),
                  );
                  Navigator.pop(context); // Go back after success
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không đủ iCoin hoặc có lỗi xảy ra.')),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B61FF), // Purple color from screenshot
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Mua ngay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildFooterText() {
    return const Text(
      'Bấm vào mua/gia hạn nghĩa là bạn đã đọc và đồng ý với 《Quy tắc tự động gia hạn》 《Vui lòng đánh dấu vào mục "Chính sách bảo mật và điều khoản sử dụng"》',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}
