import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../model/bike/bike.dart';
import '../../../../model/plan/plan.dart';
import '../confirm/confirm_screen.dart';
import '../../../main_common.dart';
import '../../states/subscription_state.dart';

class SuccessScreen extends StatelessWidget {
  final Plan plan;
  final Bike? pendingBike;
  final String? stationName;

  const SuccessScreen({
    super.key,
    required this.plan,
    this.pendingBike,
    this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
            child: Column(
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A746D),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A746D).withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 50,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF402437),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your subscription is now active',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF86556E),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFFB7D00),
                      width: 2.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'PLAN NAME',
                              style: TextStyle(
                                color: Color(0xFFA17689),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          Text(
                            _planLabel(plan.type),
                            style: const TextStyle(
                              color: Color(0xFF402437),
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1.4,
                        color: const Color(0xFFFB7D00),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'TOTAL',
                              style: TextStyle(
                                color: Color(0xFFA17689),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          Text(
                            '€${_formatPrice(plan.price)}',
                            style: const TextStyle(
                              color: Color(0xFFD7442B),
                              fontWeight: FontWeight.w800,
                              fontSize: 42,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFB7D00), Color(0xFFD10C6B)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD10C6B).withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final subscriptionState = context.read<SubscriptionState>();
                        final activeSubscription =
                            subscriptionState.activeSubscription.data;

                        if (pendingBike != null && activeSubscription != null) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmScreen(
                                bike: pendingBike!,
                                subscription: activeSubscription,
                                stationName: stationName,
                              ),
                            ),
                            (route) => false,
                          );
                          return;
                        }

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MyApp()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

String _formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return '${price.toInt()}.00';
  }
  return price.toStringAsFixed(2);
}