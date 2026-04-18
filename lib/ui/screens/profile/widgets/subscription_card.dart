import 'package:flutter/material.dart';
import '../../../../model/subscription/subscription.dart';
import '../../plan/plan_screen.dart';

class SubscriptionCardWidget extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionCardWidget({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final planName = _planLabel(subscription.planId);
    final priceText = _planPrice(subscription.planId);
    final timePeriod = _planPeriod(subscription.planId);
    final expirationDate = _calculateExpirationDate(subscription.planId, subscription.startDate);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFB7D00), Color(0xFFD10C6B)],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCF2B59).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -12,
            right: -10,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                color: Color(0xFFD74D57),
                size: 48,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE SUBSCRIPTION',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  planName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  subscription.planId == 'p1'
                      ? 'Valid until ${_formatDateWithTime(expirationDate)}'
                      : 'Valid until ${_formatLongDate(expirationDate)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '$priceText / $timePeriod',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlanScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'MANAGE',
                          style: TextStyle(
                            color: Color(0xFFD10C6B),
                            fontSize: 17,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _planLabel(String planId) {
  switch (planId) {
    case 'p1':
      return 'Hour Pass';
    case 'p2':
      return 'Day Pass';
    case 'p3':
      return 'Monthly Pass';
    case 'p4':
      return 'Year Pass';
    default:
      return planId;
  }
}

String _planPrice(String planId) {
  switch (planId) {
    case 'p1':
      return '€1.00';
    case 'p2':
      return '€2.00';
    case 'p3':
      return '€15.00';
    case 'p4':
      return '€117.00';
    default:
      return '€0.00';
  }
}

String _planPeriod(String planId) {
  switch (planId) {
    case 'p1':
      return '1h';
    case 'p2':
      return '1d';
    case 'p3':
      return 'mo';
    case 'p4':
      return '1y';
    default:
      return 'mo';
  }
}

DateTime _calculateExpirationDate(String planId, DateTime startDate) {
  switch (planId) {
    case 'p1':
      return startDate.add(const Duration(hours: 1));
    case 'p2':
      return startDate.add(const Duration(days: 1));
    case 'p3':
      return DateTime(startDate.year, startDate.month + 1, startDate.day);
    case 'p4':
      return DateTime(startDate.year + 1, startDate.month, startDate.day);
    default:
      return startDate;
  }
}

String _formatLongDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[value.month - 1];
  return '$month ${value.day}, ${value.year}';
}

String _formatDateWithTime(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[value.month - 1];
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$month ${value.day}, ${value.year} at $hour:$minute';
}