import '../../../model/subscription/subscription.dart';

abstract class SubscriptionRepository {
  Future<Subscription?> fetchActiveSubscription(String userId);
  Future<Subscription> createSubscription(Subscription subscription);
}