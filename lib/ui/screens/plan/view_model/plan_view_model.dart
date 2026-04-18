import 'package:flutter/material.dart';
import '../../../../data/repositories/plan/plan_repository.dart';
import '../../../../model/plan/plan.dart';
import '../../../../utils/async_value.dart';

class PlanViewModel extends ChangeNotifier {
  final PlanRepository _planRepository;

  PlanViewModel(this._planRepository);

  AsyncValue<List<Plan>> _plans = AsyncValue.loading();
  Plan? selectedPlan;

  AsyncValue<List<Plan>> get plans => _plans;

  Future<void> loadPlans() async {
    _plans = AsyncValue.loading();
    notifyListeners();

    try {
      final planList = await _planRepository.fetchPlans();
      _plans = AsyncValue.success(planList);
    } catch (e) {
      _plans = AsyncValue.error(e);
    }

    notifyListeners();
  }

  void selectPlan(Plan plan) {
    selectedPlan = plan;
    notifyListeners();
  }
}