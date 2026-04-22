import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../../model/station/station.dart';
import '../../dtos/station_dto.dart';
import 'station_repository.dart';
import '../../../utils/station_search_utils.dart';

class StationRepositoryFirebase implements StationRepository {
  static const String _baseHost = 'velo-toulo-default-rtdb.firebaseio.com';
  List<Station>? _cachedStations;
  final Map<String, Station?> _cachedStationById = {};

  final Uri stationsUri = Uri.https(_baseHost, '/stations.json');

  @override
  Future<List<Station>> fetchStations({bool forceFetch = false}) async {
    if (!forceFetch && _cachedStations != null) {
      return _cachedStations!;
    }

    try {
      final stations = await _fetchStationsFromApi();
      _cachedStations = stations;
      for (final station in stations) {
        _cachedStationById[station.id] = station;
      }
      return stations;
    } catch (e) {
      throw Exception('Failed to load stations: $e');
    }
  }

  @override
  Future<Station?> fetchStationById(String stationId, {bool forceFetch = false}) async {
    if (!forceFetch) {
      if (_cachedStationById.containsKey(stationId)) {
        return _cachedStationById[stationId];
      }

      if (_cachedStations != null) {
        final index = _cachedStations!.indexWhere((s) => s.id == stationId);
        if (index != -1) {
          final station = _cachedStations![index];
          _cachedStationById[stationId] = station;
          return station;
        }
      }
    }

    try {
      final station = await _fetchStationByIdFromApi(stationId);
      _cachedStationById[stationId] = station;
      if (station != null) {
        _upsertCachedStation(station);
      }
      return station;
    } catch (e) {
      throw Exception('Failed to load station: $e');
    }
  }

  @override
  Future<List<Station>> searchStations(String query, {bool forceFetch = false}) async {
    // Search is done client-side after fetching all stations.
    // Firebase RTDB doesn't support full-text search natively.
    final stations = await fetchStations(forceFetch: forceFetch);
    return filterStationsByQuery(stations, query);
  }

  @override
  Future<void> decrementAvailableBikes(String stationId) async {
    try {
      final station = await fetchStationById(stationId);
      if (station == null) return;

      final nextAvailableBikes = max(0, station.availableBikes - 1);
      final uri = Uri.https(_baseHost, '/stations/$stationId.json');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'availableBikes': nextAvailableBikes,
          'availableSlots': null,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update station bikes (${response.statusCode})');
      }

      _upsertCachedStation(
        Station(
          id: station.id,
          name: station.name,
          latitude: station.latitude,
          longitude: station.longitude,
          totalDocks: station.totalDocks,
          availableBikes: nextAvailableBikes,
        ),
      );
    } catch (e) {
      throw Exception('Failed to decrement available bikes: $e');
    }
  }

  @override
  Future<void> applyReturnAtStation(String stationId) async {
    try {
      final station = await fetchStationById(stationId);
      if (station == null) return;

      final nextAvailableBikes = min(
        station.totalDocks,
        max(0, station.availableBikes + 1),
      );
      final uri = Uri.https(_baseHost, '/stations/$stationId.json');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'availableBikes': nextAvailableBikes,
          'availableSlots': null,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update station return counts (${response.statusCode})');
      }

      _upsertCachedStation(
        Station(
          id: station.id,
          name: station.name,
          latitude: station.latitude,
          longitude: station.longitude,
          totalDocks: station.totalDocks,
          availableBikes: nextAvailableBikes,
        ),
      );
    } catch (e) {
      throw Exception('Failed to apply return at station: $e');
    }
  }

  Future<List<Station>> _fetchStationsFromApi() async {
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

  Future<Station?> _fetchStationByIdFromApi(String stationId) async {
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

  void _upsertCachedStation(Station station) {
    _cachedStationById[station.id] = station;
    if (_cachedStations == null) return;

    final index = _cachedStations!.indexWhere((s) => s.id == station.id);
    if (index == -1) {
      _cachedStations = [..._cachedStations!, station];
      return;
    }

    _cachedStations![index] = station;
  }
}