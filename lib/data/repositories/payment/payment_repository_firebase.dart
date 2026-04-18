import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/payment/payment.dart';
import '../../dtos/payment_dto.dart';
import 'payment_repository.dart';

class PaymentRepositoryFirebase implements PaymentRepository {
static const String _baseHost = 'velo-toulo-default-rtdb.firebaseio.com';
  @override
  Future<Payment> createPayment(Payment payment) async {
    final uri = Uri.https(_baseHost, '/payments.json');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(PaymentDTO.toMap(payment)),
    );

    if (response.statusCode == 200) {
      final String newId = jsonDecode(response.body)['name'];
      return PaymentDTO.fromMap({...PaymentDTO.toMap(payment), 'id': newId});
    } else {
      throw Exception('Failed to create payment');
    }
  }
}