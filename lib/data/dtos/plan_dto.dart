import '../../model/plan/plan.dart';

class PlanDTO {
  static Plan fromMap(Map<String, dynamic> map) {
    final rawType = map['type'] ?? map['name'];
    return Plan(
      id: map['id'],
      type: PlanType.values.byName(rawType as String),
      price: (map['price'] as num).toDouble(),
    );
  }

  static Map<String, dynamic> toMap(Plan plan) {
    return {
      'id': plan.id,
      'type': plan.type.name,
      'price': plan.price,
    };
  }
}