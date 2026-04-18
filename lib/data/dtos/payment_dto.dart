import '../../model/payment/payment.dart';

class PaymentDTO {
  static Payment fromMap(Map<String, dynamic> map) {
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

  static Map<String, dynamic> toMap(Payment payment) {
    return {
      'id': payment.id,
      'userId': payment.userId,
      'subscriptionId': payment.subscriptionId,
      'amount': payment.amount,
      'method': payment.method.name,
      'status': payment.status.name,
      'paidAt': payment.paidAt.toIso8601String(),
    };
  }
}