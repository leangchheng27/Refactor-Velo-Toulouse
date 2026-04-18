import 'package:flutter/material.dart';
import '../../../../data/repositories/bike/bike_repository.dart';
import '../../../../data/repositories/station/station_repository.dart';
import '../../../../model/bike/bike.dart';
import '../../../../model/station/station.dart';
import '../../../../utils/async_value.dart';

class StationViewModel extends ChangeNotifier {
  final StationRepository _stationRepository;
  final BikeRepository _bikeRepository;

  StationViewModel(this._stationRepository, this._bikeRepository);

  Station? selectedStation;
  AsyncValue<List<Bike>> _bikes = AsyncValue.success([]);

  AsyncValue<List<Bike>> get bikes => _bikes;

  Future<void> loadStation(String stationId) async {
    _bikes = AsyncValue.loading();
    notifyListeners();

    try {
      selectedStation = await _stationRepository.fetchStationById(stationId);
      final bikeList = await _bikeRepository.fetchBikesByStation(stationId);
      _bikes = AsyncValue.success(bikeList);
    } catch (e) {
      _bikes = AsyncValue.error(e);
    }

    notifyListeners();
  }
}