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
}