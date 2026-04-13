enum PaymentStatus {
  pending,
  success,
  failed,
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

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      userId: map['userId'],
      subscriptionId: map['subscriptionId'],
      amount: map['amount'],
      method: PaymentMethod.values.byName(map['method']),
      status: PaymentStatus.values.byName(map['status']),
      paidAt: DateTime.parse(map['paidAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionId': subscriptionId,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'paidAt': paidAt.toIso8601String(),
    };
  }
}