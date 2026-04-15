import '../bike/bike.dart';

class BikeStation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int availableBikes;
  final int totalCapacity;
  final List<Bike> bikes;

  const BikeStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.availableBikes,
    required this.totalCapacity,
    this.bikes = const [],
  });
}
