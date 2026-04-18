import '../../../model/payment/payment.dart';
import 'payment_repository.dart';

class PaymentRepositoryMock implements PaymentRepository {
  final List<Payment> _payments = [];

  @override
  Future<Payment> createPayment(Payment payment) async {
    final newPayment = Payment(
      id: 'pay${_payments.length + 1}',
      userId: payment.userId,
      subscriptionId: payment.subscriptionId,
      amount: payment.amount,
      method: payment.method,
      status: PaymentStatus.success,
      paidAt: DateTime.now(),
    );
    _payments.add(newPayment);
    return newPayment;
  }
}