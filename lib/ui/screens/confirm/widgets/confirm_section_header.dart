import 'package:flutter/material.dart';

class ConfirmSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final Color actionColor;

  const ConfirmSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.actionColor = const Color(0xFFD63B58),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B6B7F),
            letterSpacing: 0.5,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              foregroundColor: actionColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              actionText!,
              style: TextStyle(
                fontSize: 12,
                color: actionColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
