import '../../../model/payment/payment.dart';

abstract class PaymentRepository {
  Future<Payment> createPayment(Payment payment);
}