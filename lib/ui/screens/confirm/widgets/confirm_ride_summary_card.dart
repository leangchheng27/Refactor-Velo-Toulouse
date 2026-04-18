import 'package:flutter/material.dart';

class ConfirmRideSummaryCard extends StatelessWidget {
  final String bikeSummary;
  final String stationName;
  final String subscriptionLabel;

  const ConfirmRideSummaryCard({
    super.key,
    required this.bikeSummary,
    required this.stationName,
    required this.subscriptionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(
              icon: Icons.directions_bike,
              label: 'Bike',
              value: bikeSummary,
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 14),
            _SummaryRow(
              icon: Icons.location_on,
              label: 'Pickup station',
              value: stationName,
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 14),
            _SummaryRow(
              icon: Icons.card_giftcard,
              label: 'Subscription',
              value: subscriptionLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF402437), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B6B7F),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF402437),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
