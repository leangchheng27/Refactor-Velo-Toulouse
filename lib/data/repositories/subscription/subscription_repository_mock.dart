import '../../../model/subscription/subscription.dart';
import 'subscription_repository.dart';

class SubscriptionRepositoryMock implements SubscriptionRepository {
  final List<Subscription> _subscriptions = [];

  @override
  Future<Subscription?> fetchActiveSubscription(String userId) async {
    try {
      return _subscriptions.lastWhere(
        (s) => s.userId == userId && s.status == SubscriptionStatus.active,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Subscription> createSubscription(Subscription subscription) async {
    _subscriptions.removeWhere(
      (s) => s.userId == subscription.userId && s.status == SubscriptionStatus.active,
    );

    final newSubscription = Subscription(
      id: 'sub${_subscriptions.length + 1}',
      userId: subscription.userId,
      planId: subscription.planId,
      startDate: subscription.startDate,
      endDate: subscription.endDate,
      status: SubscriptionStatus.active,
    );
    _subscriptions.add(newSubscription);
    return newSubscription;
  }
}