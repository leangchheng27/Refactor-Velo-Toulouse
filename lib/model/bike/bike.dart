enum BikeStatus {
  available,
  inUse,
  maintenance,
}

class Bike {
  final String id;
  final String stationId;
  final int slotNumber;
  final BikeStatus status;

  Bike({
    required this.id,
    required this.stationId,
    required this.slotNumber,
    required this.status,
  });

  factory Bike.fromMap(Map<String, dynamic> map) {
    return Bike(
      id: map['id'],
      stationId: map['stationId'],
      slotNumber: map['slotNumber'],
      status: BikeStatus.values.byName(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stationId': stationId,
      'slotNumber': slotNumber,
      'status': status.name,
    };
  }
}