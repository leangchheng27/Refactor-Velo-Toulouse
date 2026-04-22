class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int totalDocks;
  final int availableBikes;

  Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.totalDocks = 12,
    this.availableBikes = 0,
  });

  int get availableSlots {
    final slots = totalDocks - availableBikes;
    if (slots < 0) return 0;
    return slots;
  }
}