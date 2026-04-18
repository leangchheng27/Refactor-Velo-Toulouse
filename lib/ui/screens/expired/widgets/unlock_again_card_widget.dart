import 'package:flutter/material.dart';

class UnlockAgainCardWidget extends StatelessWidget {
  const UnlockAgainCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EAEC),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF7A00),
                  Color(0xFFD81B60),
                ],
              ),
            ),
            child: const Icon(
              Icons.lock_open,
              color: Colors.white,
              size: 45,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Unlock Again',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A2D43),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'RESTART THE 30S UNLOCK WINDOW AND TRY AGAIN.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.5,
              height: 1.35,
              color: Color(0xFF8A7682),
            ),
          ),
        ],
      ),
    );
  }
}
