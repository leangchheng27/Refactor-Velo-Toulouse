import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/booking/booking.dart';
import '../../dtos/booking_dto.dart';
import 'booking_repository.dart';


class BookingRepositoryFirebase implements BookingRepository {
static const String _baseHost = 'velo-toulo-default-rtdb.firebaseio.com';
  @override
  Future<Booking> createBooking(Booking booking) async {
    final uri = Uri.https(_baseHost, '/bookings.json');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(BookingDTO.toMap(booking)),
    );

    if (response.statusCode == 200) {
      final String newId = jsonDecode(response.body)['name'];
      return BookingDTO.fromMap({...BookingDTO.toMap(booking), 'id': newId});
    } else {
      throw Exception('Failed to create booking (${response.statusCode})');
    }
  }

  @override
  Future<Booking?> fetchActiveBooking(String userId) async {
    final uri = Uri.https(_baseHost, '/bookings.json', {
      'orderBy': '"userId"',
      'equalTo': '"$userId"',
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null) return null;
      final Map<String, dynamic> json = body;
      for (final entry in json.entries) {
        final booking = BookingDTO.fromMap({...entry.value, 'id': entry.key});
        if (booking.status == BookingStatus.active ||
            booking.status == BookingStatus.pending) {
          return booking;
        }
      }
      return null;
    } else {
      throw Exception('Failed to load booking (${response.statusCode})');
    }
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final uri = Uri.https(_baseHost, '/bookings/$bookingId.json');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status.name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update booking status (${response.statusCode})');
    }
  }

  @override
  Future<void> incrementUnlockAttempts(
    String bookingId,
    int currentAttempts,
  ) async {
    final uri = Uri.https(_baseHost, '/bookings/$bookingId.json');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'unlockAttempts': currentAttempts + 1}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to increment unlock attempts (${response.statusCode})');
    }
  }
}