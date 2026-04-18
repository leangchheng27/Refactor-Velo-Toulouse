import '../../../model/station/station.dart';

abstract class StationRepository {
  Future<List<Station>> fetchStations();
  Future<Station?> fetchStationById(String stationId);
  Future<List<Station>> searchStations(String query);
}