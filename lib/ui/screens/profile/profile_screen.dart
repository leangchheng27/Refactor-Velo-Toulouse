import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/async_value.dart';
import '../../states/subscription_state.dart';
import 'widgets/subscription_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionState = context.watch<SubscriptionState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(
              bottom: false,
              child: Text(
                'My Pass',
                style: TextStyle(
                  fontSize: 48,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF402437),
                ),
              ),
            ),
            const SizedBox(height: 18),
            switch (subscriptionState.activeSubscription.state) {
              AsyncValueState.loading =>
                const CircularProgressIndicator(),
              AsyncValueState.error => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Error: ${subscriptionState.activeSubscription.error}',
                    style: const TextStyle(color: Color(0xFF7A6A78), fontSize: 16),
                  ),
                ),
              AsyncValueState.success =>
                subscriptionState.activeSubscription.data == null
                    ? const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'No active subscription',
                          style: TextStyle(color: Color(0xFF7A6A78), fontSize: 16),
                        ),
                      )
                    : SubscriptionCardWidget(
                        subscription: subscriptionState.activeSubscription.data!,
                      ),
            },
          ],
        ),
      ),
    );
  }
}