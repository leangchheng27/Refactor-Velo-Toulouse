import '../../model/booking/booking.dart';

class BookingDTO {
  static Booking fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'],
      bikeId: map['bikeId'],
      stationId: map['stationId'],
      pickedUpStation: map['pickedUpStation'],
      pickedUpSlot: (map['pickedUpSlot'] as num?)?.toInt(),
      status: BookingStatus.values.byName(map['status']),
      unlockAttempts: map['unlockAttempts'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
    );
  }

  static Map<String, dynamic> toMap(Booking booking) {
    return {
      'id': booking.id,
      'userId': booking.userId,
      'bikeId': booking.bikeId,
      'stationId': booking.stationId,
      'pickedUpStation': booking.pickedUpStation,
      'pickedUpSlot': booking.pickedUpSlot,
      'status': booking.status.name,
      'unlockAttempts': booking.unlockAttempts,
      'startTime': booking.startTime.toIso8601String(),
      'endTime': booking.endTime?.toIso8601String(),
    };
  }
}