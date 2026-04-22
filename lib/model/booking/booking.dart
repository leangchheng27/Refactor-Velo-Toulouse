enum BookingStatus {
  pending,
  active,
  cancelled,
  completed,
}

class Booking {
  final String id;
  final String userId;
  final String bikeId;
  final String stationId;
  final String? pickedUpStation;
  final int? pickedUpSlot;
  final BookingStatus status;
  final int unlockAttempts;
  final DateTime startTime;
  final DateTime? endTime;

  Booking({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.stationId,
    this.pickedUpStation,
    this.pickedUpSlot,
    required this.status,
    required this.unlockAttempts,
    required this.startTime,
    this.endTime,
  });
}


