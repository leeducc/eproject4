import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.primaryColor;
    final tc = textColor ?? (bg == theme.primaryColor ? theme.colorScheme.onPrimary : Colors.white);

    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: tc,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
          elevation: theme.brightness == Brightness.dark ? 0 : 4,
          shadowColor: bg.withOpacity(0.4),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(color: tc, strokeWidth: 3),
              )
            : Text(
                text,
                style: TextStyle(fontSize: 18, color: tc, fontWeight: FontWeight.w900, letterSpacing: 0.8),
              ),
      ),
    );
  }
}