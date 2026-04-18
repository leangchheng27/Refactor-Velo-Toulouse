import '../../model/bike/bike.dart';

class BikeDTO {
  static Bike fromMap(Map<String, dynamic> map) {
    return Bike(
      id: map['id'],
      stationId: map['stationId'],
      slotNumber: map['slotNumber'],
      status: BikeStatus.values.byName(map['status']),
    );
  }

  static Map<String, dynamic> toMap(Bike bike) {
    return {
      'id': bike.id,
      'stationId': bike.stationId,
      'slotNumber': bike.slotNumber,
      'status': bike.status.name,
    };
  }
}