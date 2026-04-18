enum PaymentStatus {
  pending,
  success,
}

enum PaymentMethod {
  visa,
  mastercard,
}

class Payment {
  final String id;
  final String userId;
  final String subscriptionId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime paidAt;

  Payment({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.amount,
    required this.method,
    required this.status,
    required this.paidAt,
  });
}