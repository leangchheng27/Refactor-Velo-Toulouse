enum PlanType {
  hourPass,
  dayPass,
  monthlyPass,
  yearPass,
}

class Plan {
  final String id;
  final PlanType type;
  final double price;

  Plan({
    required this.id,
    required this.type,
    required this.price,
  });
}