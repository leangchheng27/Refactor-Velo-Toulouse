import 'package:flutter/material.dart';
import '../../../../data/repositories/payment/payment_repository.dart';
import '../../../../data/repositories/subscription/subscription_repository.dart';
import '../../../../model/payment/payment.dart';
import '../../../../model/subscription/subscription.dart';
import '../../../../model/plan/plan.dart';
import '../../../../model/bike/bike.dart';
import '../../../../utils/async_value.dart';

enum PaymentResult {
  alreadyActive,
  downgradeBlocked,
  noMethodSelected,
  navigateToConfirm,
  success,
}

class PaymentViewModel extends ChangeNotifier {
  final PaymentRepository _paymentRepository;
  final SubscriptionRepository _subscriptionRepository;

  PaymentViewModel(this._paymentRepository, this._subscriptionRepository);

  PaymentMethod? selectedMethod;
  AsyncValue<void> _paymentState = AsyncValue.success(null);

  AsyncValue<void> get paymentState => _paymentState;

  void selectMethod(PaymentMethod method) {
    selectedMethod = method;
    notifyListeners();
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

  Future<PaymentResult> confirmPayment({
    required Plan plan,
    required Subscription? activeSubscription,
    Bike? pendingBike,
  }) async {
    if (selectedMethod == null) return PaymentResult.noMethodSelected;

    final activePlanRank = _planRank(activeSubscription?.planId);
    final selectedPlanRank = _planRank(plan.id);

    if (activeSubscription != null && selectedPlanRank < activePlanRank) {
      return PaymentResult.downgradeBlocked;
    }

    if (activeSubscription != null && selectedPlanRank == activePlanRank) {
      if (pendingBike != null) return PaymentResult.navigateToConfirm;
      return PaymentResult.alreadyActive;
    }

    _paymentState = AsyncValue.loading();
    notifyListeners();

    try {
      await _paymentRepository.createPayment(Payment(
        id: '',
        userId: 'currentUserId',
        subscriptionId: '',
        amount: plan.price,
        method: selectedMethod!,
        status: PaymentStatus.pending,
        paidAt: DateTime.now(),
      ));
      await _subscriptionRepository.createSubscription(Subscription(
        id: '',
        userId: 'currentUserId',
        planId: plan.id,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        status: SubscriptionStatus.active,
      ));
      _paymentState = AsyncValue.success(null);
      return PaymentResult.success;
    } catch (e) {
      _paymentState = AsyncValue.error(e);
      rethrow; // Don't hide the error
    } finally {
      notifyListeners();
    }
  }
}