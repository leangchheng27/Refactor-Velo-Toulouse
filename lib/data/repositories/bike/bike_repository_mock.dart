import '../../../model/bike/bike.dart';
import 'bike_repository.dart';

class BikeRepositoryMock implements BikeRepository {
  final List<Bike> _bikes = [
    Bike(id: 'b1', stationId: 's1', slotNumber: 1, status: BikeStatus.available),
    Bike(id: 'b2', stationId: 's1', slotNumber: 2, status: BikeStatus.inUse),
    Bike(id: 'b3', stationId: 's1', slotNumber: 3, status: BikeStatus.available),
    Bike(id: 'b4', stationId: 's2', slotNumber: 1, status: BikeStatus.available),
    Bike(id: 'b5', stationId: 's2', slotNumber: 2, status: BikeStatus.maintenance),
  ];

  @override
  Future<List<Bike>> fetchBikesByStation(String stationId) async {
    return _bikes.where((b) => b.stationId == stationId).toList();
  }

  @override
  Future<void> updateBikeStatus(String bikeId, BikeStatus status) async {
    final index = _bikes.indexWhere((b) => b.id == bikeId);
    if (index != -1) {
      _bikes[index] = Bike(
        id: _bikes[index].id,
        stationId: _bikes[index].stationId,
        slotNumber: _bikes[index].slotNumber,
        status: status,
      );
    }
  }

  @override
  Future<void> returnBikeToSlot(
    String bikeId,
    String stationId,
    int slotNumber,
  ) async {
    final index = _bikes.indexWhere((b) => b.id == bikeId);
    if (index != -1) {
      _bikes[index] = Bike(
        id: _bikes[index].id,
        stationId: stationId,
        slotNumber: slotNumber,
        status: BikeStatus.available,
      );
    }
  }
}