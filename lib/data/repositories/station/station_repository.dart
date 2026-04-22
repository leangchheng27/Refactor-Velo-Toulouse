import '../../../model/station/station.dart';

abstract class StationRepository {
  Future<List<Station>> fetchStations({bool forceFetch = false});
  Future<Station?> fetchStationById(String stationId, {bool forceFetch = false});
  Future<List<Station>> searchStations(String query, {bool forceFetch = false});
  Future<void> decrementAvailableBikes(String stationId);
  Future<void> applyReturnAtStation(String stationId);
}