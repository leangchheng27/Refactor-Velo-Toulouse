import '../../model/subscription/subscription.dart';

class SubscriptionDTO {
  static Subscription fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      userId: map['userId'],
      planId: map['planId'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      status: SubscriptionStatus.values.byName(map['status']),
    );
  }

  static Map<String, dynamic> toMap(Subscription subscription) {
    return {
      'id': subscription.id,
      'userId': subscription.userId,
      'planId': subscription.planId,
      'startDate': subscription.startDate.toIso8601String(),
      'endDate': subscription.endDate.toIso8601String(),
      'status': subscription.status.name,
    };
  }
}