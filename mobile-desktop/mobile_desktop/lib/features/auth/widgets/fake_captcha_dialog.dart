import 'package:flutter/material.dart';

class FakeCaptchaDialog extends StatefulWidget {
  const FakeCaptchaDialog({Key? key}) : super(key: key);

  @override
  State<FakeCaptchaDialog> createState() => _FakeCaptchaDialogState();
}

class _FakeCaptchaDialogState extends State<FakeCaptchaDialog> {
  double _sliderValue = 0.0;
  bool _isSuccess = false;

  void _onSliderChanged(double value) {
    if (_isSuccess) return;
    setState(() {
      _sliderValue = value;
      if (_sliderValue > 0.95) {
        _sliderValue = 1.0;
        _isSuccess = true;
        _finishCaptcha();
      }
    });
  }

  void _finishCaptcha() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2A2E39),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            top: BorderSide(color: Colors.green, width: 4),
          ),
        ),
        child: _isSuccess ? _buildSuccessState() : _buildPuzzleState(),
      ),
    );
  }

  Widget _buildPuzzleState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Slide to complete the puzzle',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Container(
          height: 120,
          width: 220,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.extension, size: 50, color: Colors.white54),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Slider(
            value: _sliderValue,
            onChanged: _onSliderChanged,
            activeColor: Colors.green,
            inactiveColor: Colors.white24,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
        SizedBox(height: 16),
        Text(
          'Verification Success',
          style: TextStyle(color: Colors.green, fontSize: 18),
        ),
      ],
    );
  }
}