class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      id: map['id'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}