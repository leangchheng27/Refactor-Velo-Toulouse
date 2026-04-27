import '../../../model/booking/booking.dart';
import 'booking_repository.dart';

class BookingRepositoryMock implements BookingRepository {
  final List<Booking> _bookings = [];

  @override
  Future<Booking> createBooking(Booking booking) async {
    final newBooking = Booking(
      id: 'bk${_bookings.length + 1}',
      userId: booking.userId,
      bikeId: booking.bikeId,
      stationId: booking.stationId,
      pickedUpStation: booking.pickedUpStation,
      pickedUpSlot: booking.pickedUpSlot,
      status: BookingStatus.pending,
      unlockAttempts: 0,
      startTime: DateTime.now(),
      endTime: null,
    );
    _bookings.add(newBooking);
    return newBooking;
  }

  @override
  Future<Booking?> fetchActiveBooking(
    String userId, {
    bool forceFetch = false,
  }) async {
    try {
      return _bookings.firstWhere(
        (b) =>
            b.userId == userId &&
            (b.status == BookingStatus.active ||
                b.status == BookingStatus.pending),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = Booking(
        id: _bookings[index].id,
        userId: _bookings[index].userId,
        bikeId: _bookings[index].bikeId,
        stationId: _bookings[index].stationId,
        pickedUpStation: _bookings[index].pickedUpStation,
        pickedUpSlot: _bookings[index].pickedUpSlot,
        status: status,
        unlockAttempts: _bookings[index].unlockAttempts,
        startTime: _bookings[index].startTime,
        endTime: status == BookingStatus.completed ? DateTime.now() : null,
      );
    }
  }

  @override
  Future<void> incrementUnlockAttempts(
    String bookingId,
    int currentAttempts,
  ) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = Booking(
        id: _bookings[index].id,
        userId: _bookings[index].userId,
        bikeId: _bookings[index].bikeId,
        stationId: _bookings[index].stationId,
        pickedUpStation: _bookings[index].pickedUpStation,
        pickedUpSlot: _bookings[index].pickedUpSlot,
        status: _bookings[index].status,
        unlockAttempts: currentAttempts + 1,
        startTime: _bookings[index].startTime,
        endTime: _bookings[index].endTime,
      );
    }
  }
}
