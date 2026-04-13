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
  final BookingStatus status;
  final int unlockAttempts;
  final DateTime startTime;
  final DateTime? endTime;

  Booking({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.stationId,
    required this.status,
    required this.unlockAttempts,
    required this.startTime,
    this.endTime,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'],
      bikeId: map['bikeId'],
      stationId: map['stationId'],
      status: BookingStatus.values.byName(map['status']),
      unlockAttempts: map['unlockAttempts'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bikeId': bikeId,
      'stationId': stationId,
      'status': status.name,
      'unlockAttempts': unlockAttempts,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }
}