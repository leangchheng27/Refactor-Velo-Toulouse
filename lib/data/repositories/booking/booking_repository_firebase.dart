import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/booking/booking.dart';
import '../../dtos/booking_dto.dart';
import 'booking_repository.dart';


class BookingRepositoryFirebase implements BookingRepository {
  static const String _baseHost = 'velo-toulo-default-rtdb.firebaseio.com';
  final Map<String, Booking?> _cachedActiveBookingByUserId = {};
  final Map<String, Booking> _cachedBookingsById = {};

  @override
  Future<Booking> createBooking(Booking booking) async {
    try {
      final uri = Uri.https(_baseHost, '/bookings.json');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(BookingDTO.toMap(booking)),
      );

      if (response.statusCode == 200) {
        final String newId = jsonDecode(response.body)['name'];
        final created = BookingDTO.fromMap({...BookingDTO.toMap(booking), 'id': newId});
        _cachedBookingsById[created.id] = created;
        if (created.status == BookingStatus.active ||
            created.status == BookingStatus.pending) {
          _cachedActiveBookingByUserId[created.userId] = created;
        }
        return created;
      } else {
        throw Exception('Failed to create booking (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<Booking?> fetchActiveBooking(String userId, {bool forceFetch = false}) async {
    if (!forceFetch && _cachedActiveBookingByUserId.containsKey(userId)) {
      return _cachedActiveBookingByUserId[userId];
    }

    try {
      final bookings = await _fetchBookingsByUserIdFromApi(userId);
      Booking? activeBooking;

      for (final booking in bookings) {
        _cachedBookingsById[booking.id] = booking;
        if (activeBooking == null &&
            (booking.status == BookingStatus.active ||
                booking.status == BookingStatus.pending)) {
          activeBooking = booking;
        }
      }

      _cachedActiveBookingByUserId[userId] = activeBooking;
      return activeBooking;
    } catch (e) {
      throw Exception('Failed to load booking: $e');
    }
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      final uri = Uri.https(_baseHost, '/bookings/$bookingId.json');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status.name}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update booking status (${response.statusCode})');
      }

      final cached = _cachedBookingsById[bookingId];
      if (cached != null) {
        final updated = Booking(
          id: cached.id,
          userId: cached.userId,
          bikeId: cached.bikeId,
          stationId: cached.stationId,
          pickedUpStation: cached.pickedUpStation,
          pickedUpSlot: cached.pickedUpSlot,
          status: status,
          unlockAttempts: cached.unlockAttempts,
          startTime: cached.startTime,
          endTime: cached.endTime,
        );
        _cachedBookingsById[bookingId] = updated;

        if (status == BookingStatus.active || status == BookingStatus.pending) {
          _cachedActiveBookingByUserId[updated.userId] = updated;
        } else {
          _cachedActiveBookingByUserId[updated.userId] = null;
        }
      }
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  @override
  Future<void> incrementUnlockAttempts(
    String bookingId,
    int currentAttempts,
  ) async {
    try {
      final uri = Uri.https(_baseHost, '/bookings/$bookingId.json');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'unlockAttempts': currentAttempts + 1}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to increment unlock attempts (${response.statusCode})');
      }

      final cached = _cachedBookingsById[bookingId];
      if (cached != null) {
        final updated = Booking(
          id: cached.id,
          userId: cached.userId,
          bikeId: cached.bikeId,
          stationId: cached.stationId,
          pickedUpStation: cached.pickedUpStation,
          pickedUpSlot: cached.pickedUpSlot,
          status: cached.status,
          unlockAttempts: currentAttempts + 1,
          startTime: cached.startTime,
          endTime: cached.endTime,
        );
        _cachedBookingsById[bookingId] = updated;
        if (updated.status == BookingStatus.active ||
            updated.status == BookingStatus.pending) {
          _cachedActiveBookingByUserId[updated.userId] = updated;
        }
      }
    } catch (e) {
      throw Exception('Failed to increment unlock attempts: $e');
    }
  }

  Future<List<Booking>> _fetchBookingsByUserIdFromApi(String userId) async {
    final uri = Uri.https(_baseHost, '/bookings.json', {
      'orderBy': '"userId"',
      'equalTo': '"$userId"',
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null) return [];
      final Map<String, dynamic> json = body;
      return json.entries
          .map((entry) => BookingDTO.fromMap({...entry.value, 'id': entry.key}))
          .toList();
    } else {
      throw Exception('Failed to load booking (${response.statusCode})');
    }
  }
}