import 'package:flutter/material.dart';

class ConfirmWarningNotice extends StatelessWidget {
  final String message;

  const ConfirmWarningNotice({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDD5DB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD63B58),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFD63B58),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFD63B58),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
