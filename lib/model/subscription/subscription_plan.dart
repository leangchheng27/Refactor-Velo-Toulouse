enum PlanType {
  hourPass,
  dayPass,
  monthlyPass,
  yearPass,
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.type,
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    this.highlight = false,
  });

  final String id;
  final PlanType type;
  final String title;
  final String price;
  final String period;
  final String description;
  final bool highlight;
}
