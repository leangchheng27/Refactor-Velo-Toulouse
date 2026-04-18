import '../../../model/plan/plan.dart';
import 'plan_repository.dart';

class PlanRepositoryMock implements PlanRepository {
  final List<Plan> _plans = [
    Plan(id: 'p1', type: PlanType.hourPass, price: 1),
    Plan(id: 'p2', type: PlanType.dayPass, price: 2),
    Plan(id: 'p3', type: PlanType.monthlyPass, price: 10),
    Plan(id: 'p4', type: PlanType.yearPass, price: 117),
  ];

  @override
  Future<List<Plan>> fetchPlans() async {
    return _plans;
  }

  @override
  Future<Plan?> fetchPlanById(String planId) async {
    return _plans.firstWhere((p) => p.id == planId);
  }
}