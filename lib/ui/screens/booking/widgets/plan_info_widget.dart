import 'package:flutter/material.dart';

class PlanInfoWidget extends StatelessWidget {
  final String planLabel;

  const PlanInfoWidget({
    super.key,
    required this.planLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E2E3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_note,
            size: 18,
            color: Color(0xFF8A7682),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.4,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                planLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A2D43),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
