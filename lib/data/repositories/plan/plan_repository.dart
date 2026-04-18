import '../../../model/plan/plan.dart';

abstract class PlanRepository {
  Future<List<Plan>> fetchPlans();
  Future<Plan?> fetchPlanById(String planId);
}