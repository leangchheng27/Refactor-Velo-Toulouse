import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/async_value.dart';
import '../../../../data/repositories/plan/plan_repository.dart';
import '../../../../model/bike/bike.dart';
import '../../../../model/plan/plan.dart';
import 'view_model/plan_view_model.dart';
import 'widgets/plan_card.dart';
import '../payment/payment_screen.dart';
import '../../states/subscription_state.dart';
import '../../../../model/subscription/subscription.dart';

class PlanScreen extends StatelessWidget {
  final Bike? pendingBike;
  final String? stationName;

  const PlanScreen({
    super.key,
    this.pendingBike,
    this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlanViewModel(
        context.read<PlanRepository>(),
      ),
      child: _PlanScreenBody(
        pendingBike: pendingBike,
        stationName: stationName,
      ),
    );
  }
}

class _PlanScreenBody extends StatefulWidget {
  final Bike? pendingBike;
  final String? stationName;

  const _PlanScreenBody({
    this.pendingBike,
    this.stationName,
  });

  @override
  State<_PlanScreenBody> createState() => _PlanScreenBodyState();
}

class _PlanScreenBodyState extends State<_PlanScreenBody> {
  static const String _currentUserId = 'currentUserId';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanViewModel>().loadPlans();
      final subscriptionState = context.read<SubscriptionState>();
      if (subscriptionState.activeSubscription.data == null) {
        subscriptionState.loadActiveSubscription(_currentUserId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlanViewModel>();
    final selectedPlan = viewModel.selectedPlan;
    final subscriptionState = context.watch<SubscriptionState>();
    final activeSubscription = subscriptionState.activeSubscription.data;
    final activePlanRank = _planRank(activeSubscription?.planId);
    final selectedPlanRank =
        selectedPlan == null ? -1 : _planRank(selectedPlan.id);
    final isDowngrade = activeSubscription != null && selectedPlan != null
        ? selectedPlanRank < activePlanRank
        : false;
    final hasActiveSubscription = activeSubscription != null &&
        activeSubscription.status == SubscriptionStatus.active;

    final isLoading = viewModel.plans.state == AsyncValueState.loading ||
        subscriptionState.activeSubscription.state == AsyncValueState.loading;
    final hasError = viewModel.plans.state == AsyncValueState.error ||
        subscriptionState.activeSubscription.state == AsyncValueState.error;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Text(
                    'Error: ${viewModel.plans.error ?? subscriptionState.activeSubscription.error}',
                  ),
                )
              : SafeArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 250),
                    itemCount: (viewModel.plans.data ?? []).length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _PlanScreenHeader();
                      }
                      final plan = (viewModel.plans.data ?? [])[index - 1];
                      return PlanCardWidget(
                        plan: plan,
                        isSelected: selectedPlan?.id == plan.id,
                        isActive: activeSubscription?.planId == plan.id,
                        isMostPopular: plan.type == PlanType.monthlyPass,
                        onSelect: () {
                          if (hasActiveSubscription &&
                              _planRank(plan.id) < activePlanRank) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'You can only upgrade to a higher pass.'),
                              ),
                            );
                            return;
                          }
                          viewModel.selectPlan(plan);
                        },
                      );
                    },
                  ),
                ),
      bottomNavigationBar: hasActiveSubscription &&
              selectedPlan != null &&
              _planRank(selectedPlan.id) == activePlanRank
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB7D00),
                      disabledBackgroundColor: const Color(0xFFE2E2E2),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: selectedPlan == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  plan: selectedPlan,
                                  pendingBike: widget.pendingBike,
                                  stationName: widget.stationName,
                                ),
                              ),
                            );
                          },
                    child: Text(
                      selectedPlan == null
                          ? 'Choose a plan to continue'
                          : hasActiveSubscription && isDowngrade
                              ? 'Upgrade only'
                              : hasActiveSubscription
                                  ? 'Upgrade to ${_planLabel(selectedPlan.type)}'
                                  : 'Continue with ${_planLabel(selectedPlan.type)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _PlanScreenHeader extends StatelessWidget {
  const _PlanScreenHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Navigator.canPop(context))
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          const SizedBox(height: 4),
          const Text(
            'CHOOSE YOUR RIDE',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              color: Color(0xFFD63B58),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Subscription Plans',
            style: TextStyle(
              fontSize: 35,
              height: 1,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1C27),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'From quick commutes to annual adventures, find the perfect rhythm for your life in Toulouse.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Color(0xFF5D5A66),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

String _planLabel(PlanType type) {
  switch (type) {
    case PlanType.hourPass:     return 'Hour Pass';
    case PlanType.dayPass:      return 'Day Pass';
    case PlanType.monthlyPass:  return 'Monthly Pass';
    case PlanType.yearPass:     return 'Year Pass';
  }
}

int _planRank(String? planId) {
  switch (planId) {
    case 'p1': return 0;
    case 'p2': return 1;
    case 'p3': return 2;
    case 'p4': return 3;
    default:   return -1;
  }
}