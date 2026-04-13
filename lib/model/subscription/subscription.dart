enum SubscriptionStatus {
  active,
  expired,
  cancelled,
}

class Subscription {
  final String id;
  final String userId;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionStatus status;

  Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      userId: map['userId'],
      planId: map['planId'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      status: SubscriptionStatus.values.byName(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
    };
  }
}