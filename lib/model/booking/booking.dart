enum BookingStatus {
  pending,
  active,
  cancelled,
  completed,
}

class Booking {
  final String id;
  final String bikeId;
  final String stationId;
  final BookingStatus status;
  final int unlockAttempts;
  final DateTime startTime;
  final DateTime? endTime;

  Booking({
    required this.id,
    required this.bikeId,
    required this.stationId,
    required this.status,
    required this.unlockAttempts,
    required this.startTime,
    this.endTime,
  });
}


