enum SubscriptionStatus {
  active,
  expired,
  cancelled,
}

class Subscription {
  final String id;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionStatus status;

  Subscription({
    required this.id,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}