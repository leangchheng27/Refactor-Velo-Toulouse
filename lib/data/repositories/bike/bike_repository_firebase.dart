import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/bike/bike.dart';
import '../../dtos/bike_dto.dart';
import 'bike_repository.dart';


class BikeRepositoryFirebase implements BikeRepository {
static const String _baseHost = 'velo-toulo-default-rtdb.firebaseio.com';
  @override
  Future<List<Bike>> fetchBikesByStation(String stationId) async {
    final uri = Uri.https(_baseHost, '/bikes.json', {
      'orderBy': '"stationId"',
      'equalTo': '"$stationId"',
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null) return [];
      final Map<String, dynamic> bikesJson = body;
      return bikesJson.entries
          .map((e) => BikeDTO.fromMap({...e.value, 'id': e.key}))
          .toList();
    } else {
      throw Exception('Failed to load bikes (${response.statusCode})');
    }
  }

  @override
  Future<void> updateBikeStatus(String bikeId, BikeStatus status) async {
    final uri = Uri.https(_baseHost, '/bikes/$bikeId.json');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status.name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update bike status (${response.statusCode})');
    }
  }

  @override
  Future<void> returnBikeToSlot(
    String bikeId,
    String stationId,
    int slotNumber,
  ) async {
    final uri = Uri.https(_baseHost, '/bikes/$bikeId.json');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'stationId': stationId,
        'slotNumber': slotNumber,
        'status': BikeStatus.available.name,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to return bike to slot (${response.statusCode})');
    }
  }
}