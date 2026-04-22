import '../../../model/bike/bike.dart';

abstract class BikeRepository {
  Future<List<Bike>> fetchBikesByStation(String stationId);
  Future<void> updateBikeStatus(String bikeId, BikeStatus status);
  Future<void> returnBikeToSlot(
    String bikeId,
    String stationId,
    int slotNumber,
  );
}