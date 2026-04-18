import 'package:flutter/material.dart';
import '../../../../model/plan/plan.dart';

class PlanCardWidget extends StatelessWidget {
  final Plan plan;
  final bool isSelected;
  final bool isActive;
  final bool isMostPopular;
  final VoidCallback onSelect;

  const PlanCardWidget({
    super.key,
    required this.plan,
    required this.isSelected,
    this.isActive = false,
    this.isMostPopular = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final label = _planLabel(plan.type);
    final price = _formatPrice(plan.price);
    final unit = _planUnit(plan.type);
    final subtitle = _planSubtitle(plan.type);

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive 
                ? const Color(0xFFFF8A00)
                : isSelected 
                    ? const Color(0xFFFB7D00) 
                    : const Color(0xFFD9D9DD),
            width: isActive || isSelected ? 1.4 : 1,
          ),
          boxShadow: (isSelected || isActive)
              ? [
                  BoxShadow(
                    color: isActive
                        ? const Color(0xFFFF8A00).withValues(alpha: 0.16)
                        : const Color(0xFFFB7D00).withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (isActive)
              Positioned(
                top: 8,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF8A00), Color(0xFFD92B74)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 34,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F1C27),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '€$price',
                        style: const TextStyle(
                          fontSize: 44,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFB7D00),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '/ $unit',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6A6575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7C7886),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (isMostPopular)
              const Positioned(
                top: -8,
                left: 12,
                child: _MostPopularTag(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MostPopularTag extends StatelessWidget {
  const _MostPopularTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFB7D00),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'MOST POPULAR',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _planLabel(PlanType type) {
  switch (type) {
    case PlanType.hourPass:
      return 'Hour Pass';
    case PlanType.dayPass:
      return 'Day Pass';
    case PlanType.monthlyPass:
      return 'Monthly Pass';
    case PlanType.yearPass:
      return 'Year Pass';
  }
}

String _planUnit(PlanType type) {
  switch (type) {
    case PlanType.hourPass:
      return 'hour';
    case PlanType.dayPass:
      return 'Day';
    case PlanType.monthlyPass:
      return 'Month';
    case PlanType.yearPass:
      return 'Year';
  }
}

String _planSubtitle(PlanType type) {
  switch (type) {
    case PlanType.hourPass:
      return 'Pay as you go - perfect for spontaneous rides.';
    case PlanType.dayPass:
      return 'Unlimited rides for 24 hours - ideal for a sunny day.';
    case PlanType.monthlyPass:
      return 'Best for students and daily commuters. Cancel anytime.';
    case PlanType.yearPass:
      return 'Maximum flexibility for great users. Includes e-bike access and best savings.';
  }
}

String _formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return price.toInt().toString();
  }
  return price.toStringAsFixed(2);
}