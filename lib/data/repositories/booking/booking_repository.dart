import '../../../model/booking/booking.dart';

abstract class BookingRepository {
  Future<Booking> createBooking(Booking booking);
  Future<Booking?> fetchActiveBooking(String userId, {bool forceFetch = false});
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);
  Future<void> incrementUnlockAttempts(String bookingId, int currentAttempts);
}
