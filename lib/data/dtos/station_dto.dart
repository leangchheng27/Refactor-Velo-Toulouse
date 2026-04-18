import '../../model/station/station.dart';

class StationDTO {
  static Station fromMap(Map<String, dynamic> map) {
    return Station(
      id: map['id'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  static Map<String, dynamic> toMap(Station station) {
    return {
      'id': station.id,
      'name': station.name,
      'latitude': station.latitude,
      'longitude': station.longitude,
    };
  }
}