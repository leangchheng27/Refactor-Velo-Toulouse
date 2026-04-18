import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/async_value.dart';
import '../../../../data/repositories/payment/payment_repository.dart';
import '../../../../data/repositories/subscription/subscription_repository.dart';
import '../../../../model/bike/bike.dart';
import '../../../../model/plan/plan.dart';
import 'view_model/payment_view_model.dart';
import 'widgets/payment_method.dart';
import '../success/success_screen.dart';
import '../../states/subscription_state.dart';
import '../confirm/confirm_screen.dart';
import '../../../../model/payment/payment.dart';

class PaymentScreen extends StatelessWidget {
  final Plan plan;
  final Bike? pendingBike;
  final String? stationName;

  const PaymentScreen({
    super.key,
    required this.plan,
    this.pendingBike,
    this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentViewModel(
        context.read<PaymentRepository>(),
        context.read<SubscriptionRepository>(),
      ),
      child: _PaymentScreenBody(
        plan: plan,
        pendingBike: pendingBike,
        stationName: stationName,
      ),
    );
  }
}

class _PaymentScreenBody extends StatelessWidget {
  final Plan plan;
  final Bike? pendingBike;
  final String? stationName;

  const _PaymentScreenBody({
    required this.plan,
    this.pendingBike,
    this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PaymentViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 46),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Review & Confirm',
                      style: TextStyle(
                        fontSize: 48,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF402437),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFB7D00), Color(0xFFD10C6B)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _planLabel(plan.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '€${_formatPrice(plan.price)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 3, bottom: 7),
                                child: Text(
                                  '/${_planUnit(plan.type)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _planSubtitle(plan.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 32,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF402437),
                      ),
                    ),
                    const SizedBox(height: 18),
                    PaymentMethodWidget(
                      selectedMethod: viewModel.selectedMethod,
                      onSelect: viewModel.selectMethod,
                    ),
                    const SizedBox(height: 30),
                    if (viewModel.selectedMethod == PaymentMethod.mastercard)
                      _DigitalWalletPanel(planPrice: plan.price)
                    else
                      const _CreditCardPanel(),
                    const SizedBox(height: 18),
                    _PaymentNotices(
                      selectedMethod: viewModel.selectedMethod,
                      plan: plan,
                    ),
                    const SizedBox(height: 36),
                    const Spacer(),
                    if (viewModel.paymentState.state == AsyncValueState.error)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          viewModel.paymentState.error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFB7D00), Color(0xFFD10C6B)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: viewModel.paymentState.state ==
                                  AsyncValueState.loading
                              ? null
                              : () async {
                                  final activeSubscription = context
                                      .read<SubscriptionState>()
                                      .activeSubscription
                                      .data;

                                  final result =
                                      await viewModel.confirmPayment(
                                    plan: plan,
                                    activeSubscription: activeSubscription,
                                    pendingBike: pendingBike,
                                  );

                                  if (!context.mounted) return;

                                  switch (result) {
                                    case PaymentResult.noMethodSelected:
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Please choose a payment method'),
                                      ));
                                    case PaymentResult.downgradeBlocked:
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'You cannot downgrade an active pass.'),
                                      ));
                                    case PaymentResult.alreadyActive:
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'This pass is already active.'),
                                      ));
                                    case PaymentResult.navigateToConfirm:
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ConfirmScreen(
                                            bike: pendingBike!,
                                            subscription: activeSubscription!,
                                            stationName: stationName,
                                          ),
                                        ),
                                      );
                                    case PaymentResult.success:
                                      await context
                                          .read<SubscriptionState>()
                                          .loadActiveSubscription(
                                              'currentUserId');
                                      if (!context.mounted) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SuccessScreen(
                                            plan: plan,
                                            pendingBike: pendingBike,
                                            stationName: stationName,
                                          ),
                                        ),
                                      );
                                  }
                                },
                          child: viewModel.paymentState.state ==
                                  AsyncValueState.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Confirm & Pay',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    height: 1,
                                    fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }
}

class _CreditCardPanel extends StatelessWidget {
  const _CreditCardPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CARD NUMBER',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.6,
              color: Color(0xFF7A6A78),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _FakeInput(
            hint: '0000 0000 0000 0000',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.credit_card, size: 16, color: Color(0xFF4A4A4A)),
                SizedBox(width: 4),
                Icon(Icons.verified_user,
                    size: 16, color: Color(0xFF0D3D5C)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'EXPIRY DATE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.6,
                    color: Color(0xFF7A6A78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'CVV',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.6,
                    color: Color(0xFF7A6A78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _FakeInput(hint: 'MM/YY')),
              SizedBox(width: 12),
              Expanded(
                child: _FakeInput(
                  hint: '***',
                  trailing: Icon(
                    Icons.help_outline,
                    size: 14,
                    color: Color(0xFFA06A88),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DigitalWalletPanel extends StatelessWidget {
  const _DigitalWalletPanel({required this.planPrice});

  final double planPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8D8DC), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Color(0xFF5E5E62)),
              SizedBox(width: 8),
              Text(
                'Digital Wallet Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF35333A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'You will be redirected to your wallet app to complete payment of €${_formatPrice(planPrice)}.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF696872),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 16, color: Color(0xFF777781)),
                SizedBox(width: 8),
                Text(
                  'Secure wallet payment',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777781),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeInput extends StatelessWidget {
  const _FakeInput({required this.hint, this.trailing});

  final String hint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(
                color: Color(0xFF7D8993),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _PaymentNotices extends StatelessWidget {
  const _PaymentNotices({
    required this.selectedMethod,
    required this.plan,
  });

  final PaymentMethod? selectedMethod;
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final methodText = selectedMethod == PaymentMethod.mastercard
        ? 'Digital wallet payments may open an external app before returning here.'
        : 'Please keep your card details private and do not share your CVV code.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0CDCD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF9D3D50)),
              SizedBox(width: 6),
              Text(
                'Before You Pay',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9D3D50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• $methodText\n'
            '• Your ${_planLabel(plan.type)} starts immediately after payment.\n'
            '• Subscription renewals are not automatic in this demo build.',
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: Color(0xFF6A5A67),
            ),
          ),
        ],
      ),
    );
  }
}

String _planLabel(PlanType type) {
  switch (type) {
    case PlanType.hourPass:    return 'Hour Pass';
    case PlanType.dayPass:     return 'Day Pass';
    case PlanType.monthlyPass: return 'Monthly Pass';
    case PlanType.yearPass:    return 'Year Pass';
  }
}

String _planUnit(PlanType type) {
  switch (type) {
    case PlanType.hourPass:    return 'hour';
    case PlanType.dayPass:     return 'day';
    case PlanType.monthlyPass: return 'month';
    case PlanType.yearPass:    return 'year';
  }
}

String _planSubtitle(PlanType type) {
  switch (type) {
    case PlanType.hourPass:    return 'Perfect for spontaneous rides.';
    case PlanType.dayPass:     return 'Unlimited rides for 24 hours.';
    case PlanType.monthlyPass: return 'Best for students and daily commuters. Cancel anytime.';
    case PlanType.yearPass:    return 'Best long-term value for frequent riders.';
  }
}

String _formatPrice(double price) {
  if (price == price.roundToDouble()) return price.toInt().toString();
  return price.toStringAsFixed(2);
}