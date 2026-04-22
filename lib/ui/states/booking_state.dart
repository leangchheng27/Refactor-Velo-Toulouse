import 'package:flutter/material.dart';
import '../../../model/booking/booking.dart';
import '../../../model/bike/bike.dart';
import '../../data/repositories/booking/booking_repository.dart';
import '../../data/repositories/bike/bike_repository.dart';
import '../../data/repositories/station/station_repository.dart';
import '../../utils/async_value.dart';

class BookingState extends ChangeNotifier {
  final BookingRepository _bookingRepository;
  final BikeRepository _bikeRepository;
  final StationRepository _stationRepository;
  BookingState(
    this._bookingRepository,
    this._bikeRepository,
    this._stationRepository,
  );

  AsyncValue<Booking?> _activeBooking = AsyncValue.success(null);
  bool _isCompletingRide = false;

  AsyncValue<Booking?> get activeBooking => _activeBooking;
  Booking? get activeBookingData => _activeBooking.data;
  bool get isCompletingRide => _isCompletingRide;

  bool get hasCurrentRide {
    final booking = _activeBooking.data;
    return booking != null &&
        booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed;
  }

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
      await _stationRepository.decrementAvailableBikes(booking.stationId);
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

  Future<void> completeRide({
    String? returnStationId,
    int? returnSlotNumber,
  }) async {
    final booking = _activeBooking.data;
    if (booking == null) return;
    _isCompletingRide = true;
    notifyListeners();
    try {
      await _bookingRepository.updateBookingStatus(
        booking.id,
        BookingStatus.completed,
      );
      if (returnStationId != null && returnSlotNumber != null) {
        await _bikeRepository.returnBikeToSlot(
          booking.bikeId,
          returnStationId,
          returnSlotNumber,
        );
      } else {
        await _bikeRepository.updateBikeStatus(booking.bikeId, BikeStatus.available);
      }
      await _stationRepository.applyReturnAtStation(
        returnStationId ?? booking.stationId,
      );
      _activeBooking = AsyncValue.success(null);
    } catch (e) {
      _activeBooking = AsyncValue.error(e);
    } finally {
      _isCompletingRide = false;
    }
    notifyListeners();
  }
}
