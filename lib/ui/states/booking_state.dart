import 'package:flutter/material.dart';
import '../../../model/booking/booking.dart';
import '../../../model/bike/bike.dart';
import '../../data/repositories/booking/booking_repository.dart';
import '../../data/repositories/bike/bike_repository.dart';
import '../../utils/async_value.dart';

class BookingState extends ChangeNotifier {
  final BookingRepository _bookingRepository;
  final BikeRepository _bikeRepository;
  BookingState(this._bookingRepository, this._bikeRepository);

  AsyncValue<Booking?> _activeBooking = AsyncValue.success(null);

  AsyncValue<Booking?> get activeBooking => _activeBooking;

  Future<void> loadActiveBooking(String userId) async {
    _activeBooking = AsyncValue.loading();
    notifyListeners();
    try {
      final booking = await _bookingRepository.fetchActiveBooking(userId);
      _activeBooking = AsyncValue.success(booking);
    } catch (e) {
      _activeBooking = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> createBooking(Booking booking) async {
    _activeBooking = AsyncValue.loading();
    notifyListeners();
    try {
      final createdBooking = await _bookingRepository.createBooking(booking);
      // Update bike status to inUse
      await _bikeRepository.updateBikeStatus(booking.bikeId, BikeStatus.inUse);
      _activeBooking = AsyncValue.success(createdBooking);
    } catch (e) {
      _activeBooking = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> cancelBooking() async {
    final booking = _activeBooking.data;
    if (booking == null) return;
    _activeBooking = AsyncValue.loading();
    notifyListeners();
    try {
      await _bookingRepository.updateBookingStatus(
        booking.id,
        BookingStatus.cancelled,
      );
      // Update bike status back to available
      await _bikeRepository.updateBikeStatus(booking.bikeId, BikeStatus.available);
      _activeBooking = AsyncValue.success(null);
    } catch (e) {
      _activeBooking = AsyncValue.error(e);
    }
    notifyListeners();
  }
}
