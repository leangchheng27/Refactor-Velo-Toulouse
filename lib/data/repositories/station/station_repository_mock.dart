import 'dart:math';

import '../../../model/station/station.dart';
import '../../../utils/station_search_utils.dart';
import 'station_repository.dart';

class StationRepositoryMock implements StationRepository {
  final List<Station> _stations = [
    Station(
      id: 's1',
      name: 'Arnaud Bernard',
      latitude: 43.6051,
      longitude: 1.4429,
      totalDocks: 3,
      availableBikes: 2,
    ),
    Station(
      id: 's2',
      name: 'Jean Jaures',
      latitude: 43.6089,
      longitude: 1.4442,
      totalDocks: 2,
      availableBikes: 1,
    ),
    Station(
      id: 's3',
      name: 'Capitole',
      latitude: 43.6047,
      longitude: 1.4442,
      totalDocks: 2,
      availableBikes: 0,
    ),
  ];

  @override
  Future<List<Station>> fetchStations({bool forceFetch = false}) async {
    return _stations;
  }

  @override
  Future<Station?> fetchStationById(String stationId, {bool forceFetch = false}) async {
    return _stations.firstWhere((s) => s.id == stationId);
  }

  @override
  Future<List<Station>> searchStations(String query, {bool forceFetch = false}) async {
    return filterStationsByQuery(_stations, query);
  }

  @override
  Future<void> decrementAvailableBikes(String stationId) async {
    final index = _stations.indexWhere((s) => s.id == stationId);
    if (index == -1) return;
    final current = _stations[index];
    final next = current.availableBikes > 0 ? current.availableBikes - 1 : 0;
    _stations[index] = Station(
      id: current.id,
      name: current.name,
      latitude: current.latitude,
      longitude: current.longitude,
      totalDocks: current.totalDocks,
      availableBikes: next,
    );
  }

  @override
  Future<void> applyReturnAtStation(String stationId) async {
    final index = _stations.indexWhere((s) => s.id == stationId);
    if (index == -1) return;
    final current = _stations[index];
    _stations[index] = Station(
      id: current.id,
      name: current.name,
      latitude: current.latitude,
      longitude: current.longitude,
      totalDocks: current.totalDocks,
      availableBikes: min(current.totalDocks, current.availableBikes + 1),
    );
  }
}