import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/plan/plan.dart';
import '../../dtos/plan_dto.dart';
import 'plan_repository.dart';

class PlanRepositoryFirebase implements PlanRepository {
static const String _baseHost = 'velo-toulo-default-rtdb.firebaseio.com';

Uri get _plansUri => Uri.https(_baseHost, '/plans.json');

  @override
  Future<List<Plan>> fetchPlans() async {
    final response = await http.get(_plansUri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded == null) return [];
      final json = Map<String, dynamic>.from(decoded as Map);
      return json.entries
          .map((e) => PlanDTO.fromMap({...e.value, 'id': e.key}))
          .toList();
    } else {
      throw Exception('Failed to load plans (${response.statusCode})');
    }
  }

  @override
  Future<Plan?> fetchPlanById(String planId) async {
    final uri = Uri.https(_baseHost, '/plans/$planId.json');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null) return null;
      return PlanDTO.fromMap({...body, 'id': planId});
    } else {
      throw Exception('Failed to load plan');
    }
  }
}