import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../model/bike/bike.dart';
import '../../../../model/booking/booking.dart';
import '../../../../data/repositories/booking/booking_repository.dart';
import '../../../../data/repositories/bike/bike_repository.dart';
import '../../../../data/repositories/station/station_repository.dart';

class BookingViewModel extends ChangeNotifier {
  // UI Context / Countdown
  Bike? selectedBike;
  String stationName = 'Arnaud Bernard';
  String planLabel = 'Monthly Pass';
  int countdown = 30;
  bool _initialized = false;
  Timer? _timer;
  VoidCallback? onExpired;

  // Repositories (injected)
  final BookingRepository? _bookingRepository;
  final BikeRepository? _bikeRepository;
  final StationRepository? _stationRepository;

  BookingViewModel({
    BookingRepository? bookingRepository,
    BikeRepository? bikeRepository,
    StationRepository? stationRepository,
  })  : _bookingRepository = bookingRepository,
        _bikeRepository = bikeRepository,
        _stationRepository = stationRepository;

  // Booking/Return State (moved from BookingState)
  Booking? _currentRide;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCompletingRide = false;

  // Validation flags
  bool _noBikeError = false;
  bool _noSlotError = false;

  //  Getters 
  bool get initialized => _initialized;
  Booking? get currentRide => _currentRide;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCompletingRide => _isCompletingRide;
  bool get noBikeError => _noBikeError;
  bool get noSlotError => _noSlotError;

  bool get hasCurrentRide {
    final booking = _currentRide;
    return booking != null &&
        booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed;
  }

  // UI Context Methods 
  void setBookingContext({
    required Bike bike,
    required String stationName,
    required String planLabel,
  }) {
    selectedBike = bike;
    this.stationName = stationName;
    this.planLabel = planLabel;
    _initialized = true;
    notifyListeners();
  }

  void startCountdown() {
    countdown = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (countdown == 0) {
        _timer?.cancel();
        onExpired?.call();
      } else {
        countdown--;
        notifyListeners();
      }
    });
  }

  void cancelCountdown() {
    _timer?.cancel();
  }

  // Booking/Return Methods (moved from BookingState)
    bool validateBikeAvailability(int availableBikeCount) {
      _noBikeError = availableBikeCount <= 0;
      notifyListeners();
      return availableBikeCount > 0;
    }

      bool canProceedWithStationTapForBooking({
        required bool hasCurrentRide,
        required int availableBikeCount,
      }) {
        if (hasCurrentRide) return true;
        return validateBikeAvailability(availableBikeCount);
      }

    /// Validates if a return station has available dock slots.
    /// Called by UI (MapScreen) during return station selection.
    /// Returns true if slots are available, false otherwise.
    bool validateSlotAvailability(int availableSlotCount) {
      _noSlotError = availableSlotCount <= 0;
      notifyListeners();
      return availableSlotCount > 0;
    }

      /// Centralized return-station validation.
      bool canProceedWithReturnStationTap({
        required int availableSlotCount,
        required List<int> slotOptions,
      }) {
        if (!validateSlotAvailability(availableSlotCount)) {
          return false;
        }
        return slotOptions.isNotEmpty;
      }

      Duration calculateRideDuration(DateTime rideStartTime) {
        return DateTime.now().difference(rideStartTime);
      }

    /// Clears all validation error flags.
    void clearValidationErrors() {
      _noBikeError = false;
      _noSlotError = false;
      notifyListeners();
    }

  
  Future<void> loadActiveBooking(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final booking = await _bookingRepository!.fetchActiveBooking(userId);
      _currentRide = booking;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBooking(Booking booking) async {
    _isLoading = true;
    notifyListeners();
    try {
      final createdBooking = await _bookingRepository!.createBooking(booking);
      _bikeRepository?.updateBikeStatus(booking.bikeId, BikeStatus.inUse);
      _stationRepository?.decrementAvailableBikes(booking.stationId);
      _currentRide = createdBooking;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> confirmBooking({
    required String userId,
    required Bike bike,
  }) async {
    cancelCountdown();
    await createBooking(
      Booking(
        id: '',
        userId: userId,
        bikeId: bike.id,
        stationId: bike.stationId,
        pickedUpStation: bike.stationId,
        pickedUpSlot: bike.slotNumber,
        status: BookingStatus.active,
        unlockAttempts: 0,
        startTime: DateTime.now(),
        endTime: null,
      ),
    );
  }

  Future<void> cancelBooking() async {
    final booking = _currentRide;
    if (booking == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _bookingRepository!.updateBookingStatus(
        booking.id,
        BookingStatus.cancelled,
      );
      _bikeRepository?.updateBikeStatus(booking.bikeId, BikeStatus.available);
      _currentRide = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeRide({
    String? returnStationId,
    int? returnSlotNumber,
  }) async {
    final booking = _currentRide;
    if (booking == null) return;
    _isCompletingRide = true;
    notifyListeners();
    try {
      await _bookingRepository!.updateBookingStatus(
        booking.id,
        BookingStatus.completed,
      );
      if (returnStationId != null && returnSlotNumber != null) {
        await _bikeRepository!.returnBikeToSlot(
          booking.bikeId,
          returnStationId,
          returnSlotNumber,
        );
      } else {
        _bikeRepository?.updateBikeStatus(booking.bikeId, BikeStatus.available);
      }
      _stationRepository?.applyReturnAtStation(
        returnStationId ?? booking.stationId,
      );
      _currentRide = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isCompletingRide = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}