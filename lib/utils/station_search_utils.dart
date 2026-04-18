import '../model/station/station.dart';

List<Station> filterStationsByQuery(List<Station> stations, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return List<Station>.from(stations);
  }

  return stations
      .where((station) => station.name.toLowerCase().contains(normalizedQuery))
      .toList();
}