import '../../../model/station/station.dart';
import '../../../utils/station_search_utils.dart';
import 'station_repository.dart';

class StationRepositoryMock implements StationRepository {
  final List<Station> _stations = [
    Station(id: 's1', name: 'Arnaud Bernard', latitude: 43.6051, longitude: 1.4429),
    Station(id: 's2', name: 'Jean Jaures', latitude: 43.6089, longitude: 1.4442),
    Station(id: 's3', name: 'Capitole', latitude: 43.6047, longitude: 1.4442),
  ];

  @override
  Future<List<Station>> fetchStations() async {
    return _stations;
  }

  @override
  Future<Station?> fetchStationById(String stationId) async {
    return _stations.firstWhere((s) => s.id == stationId);
  }

  @override
  Future<List<Station>> searchStations(String query) async {
    return filterStationsByQuery(_stations, query);
  }
}