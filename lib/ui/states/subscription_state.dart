import 'package:flutter/material.dart';
import '../../../model/subscription/subscription.dart';
import '../../data/repositories/subscription/subscription_repository.dart';
import '../../utils/async_value.dart';

class SubscriptionState extends ChangeNotifier {
  final SubscriptionRepository _subscriptionRepository;
  SubscriptionState(this._subscriptionRepository);

  AsyncValue<Subscription?> _activeSubscription = AsyncValue.success(null);

  AsyncValue<Subscription?> get activeSubscription => _activeSubscription;

  Future<void> loadActiveSubscription(String userId) async {
    _activeSubscription = AsyncValue.loading();
    notifyListeners();
    try {
      final subscription =
          await _subscriptionRepository.fetchActiveSubscription(userId);
      _activeSubscription = AsyncValue.success(subscription);
    } catch (e) {
      _activeSubscription = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> createSubscription(Subscription subscription) async {
    _activeSubscription = AsyncValue.loading();
    notifyListeners();
    try {
      final created =
          await _subscriptionRepository.createSubscription(subscription);
      _activeSubscription = AsyncValue.success(created);
    } catch (e) {
      _activeSubscription = AsyncValue.error(e);
    }
    notifyListeners();
  }
}