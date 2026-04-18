import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/station/station.dart';
import '../../dtos/station_dto.dart';
import 'station_repository.dart';
import '../../../utils/station_search_utils.dart';

class StationRepositoryFirebase implements StationRepository {
static const String _baseHost = 'velo-toulo-default-rtdb.firebaseio.com';

  final Uri stationsUri = Uri.https(_baseHost, '/stations.json');

  @override
  Future<List<Station>> fetchStations() async {
    final response = await http.get(stationsUri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded == null) return [];
      final json = Map<String, dynamic>.from(decoded as Map);
      return json.entries
          .map((e) => StationDTO.fromMap({...e.value, 'id': e.key}))
          .toList();
    } else {
      throw Exception('Failed to load stations (${response.statusCode})');
    }
  }

  @override
  Future<Station?> fetchStationById(String stationId) async {
    final uri = Uri.https(_baseHost, '/stations/$stationId.json');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null) return null;
      return StationDTO.fromMap({...body, 'id': stationId});
    } else {
      throw Exception('Failed to load station (${response.statusCode})');
    }
  }

  @override
  Future<List<Station>> searchStations(String query) async {
    final stations = await fetchStations();
    return filterStationsByQuery(stations, query);
  }
}