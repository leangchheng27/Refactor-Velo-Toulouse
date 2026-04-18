import 'package:flutter/material.dart';

class BikeInfoCardWidget extends StatelessWidget {
  final String bikeLabel;

  const BikeInfoCardWidget({
    super.key,
    required this.bikeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EAEC),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF7A00),
                  Color(0xFFD81B60),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              bikeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You're here!\nReady to start?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              height: 1.02,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5B3652),
            ),
          ),
        ],
      ),
    );
  }
}
