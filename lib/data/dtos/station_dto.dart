import '../../model/station/station.dart';

class StationDTO {
  static Station fromMap(Map<String, dynamic> map) {
    final availableBikes = (map['availableBikes'] as num?)?.toInt() ?? 0;
    final legacyAvailableSlots = (map['availableSlots'] as num?)?.toInt() ?? 0;
    final totalDocksFromMap = (map['totalDocks'] as num?)?.toInt();
    final inferredTotalDocks = availableBikes + legacyAvailableSlots;

    return Station(
      id: map['id'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      totalDocks: totalDocksFromMap ??
          (inferredTotalDocks > 0 ? inferredTotalDocks : 12),
      availableBikes: availableBikes,
    );
  }

  static Map<String, dynamic> toMap(Station station) {
    return {
      'id': station.id,
      'name': station.name,
      'latitude': station.latitude,
      'longitude': station.longitude,
      'totalDocks': station.totalDocks,
      'availableBikes': station.availableBikes,
    };
  }
}