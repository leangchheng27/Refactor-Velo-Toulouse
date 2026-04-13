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

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'],
      type: PlanType.values.byName(map['type']),
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'price': price,
    };
  }
}