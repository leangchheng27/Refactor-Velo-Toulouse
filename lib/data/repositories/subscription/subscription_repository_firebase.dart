import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/subscription/subscription.dart';
import '../../dtos/subscription_dto.dart';
import 'subscription_repository.dart';


class SubscriptionRepositoryFirebase implements SubscriptionRepository {
static const String _baseHost = 'velo-toulo-default-rtdb.firebaseio.com';

  @override
  Future<Subscription?> fetchActiveSubscription(String userId) async {
    final uri = Uri.https(_baseHost, '/subscriptions.json', {
      'orderBy': '"userId"',
      'equalTo': '"$userId"',
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null) return null;
      final Map<String, dynamic> json = body;
      
      // Collect all active subscriptions (skip invalid ones)
      final activeSubscriptions = <Subscription>[];
      for (final entry in json.entries) {
        try {
          final subscription =
              SubscriptionDTO.fromMap({...entry.value, 'id': entry.key});
          if (subscription.status == SubscriptionStatus.active) {
            activeSubscriptions.add(subscription);
          }
        } catch (e) {
          // Skip subscriptions with invalid status
          print('Skipping invalid subscription: $e');
          continue;
        }
      }
      
      // Return the most recent one (by startDate)
      if (activeSubscriptions.isEmpty) return null;
      activeSubscriptions.sort((a, b) => b.startDate.compareTo(a.startDate));
      return activeSubscriptions.first;
    } else {
      throw Exception('Failed to load subscription (${response.statusCode})');
    }
  }

  @override
  Future<Subscription> createSubscription(Subscription subscription) async {
    // First, deactivate any existing active subscriptions for this user
    await _deactivateActiveSubscriptions(subscription.userId);
    
    // Then create the new subscription
    final uri = Uri.https(_baseHost, '/subscriptions.json');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(SubscriptionDTO.toMap(subscription)),
    );

    if (response.statusCode == 200) {
      final String newId = jsonDecode(response.body)['name'];
      return SubscriptionDTO.fromMap(
          {...SubscriptionDTO.toMap(subscription), 'id': newId});
    } else {
      throw Exception('Failed to create subscription (${response.statusCode})');
    }
  }

  // Deactivate all active subscriptions for a user
  Future<void> _deactivateActiveSubscriptions(String userId) async {
    final uri = Uri.https(_baseHost, '/subscriptions.json', {
      'orderBy': '"userId"',
      'equalTo': '"$userId"',
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null) return;
      
      final Map<String, dynamic> json = body;
      for (final entry in json.entries) {
        try {
          final subscription =
              SubscriptionDTO.fromMap({...entry.value, 'id': entry.key});
          
          // If this subscription is active, deactivate it
          if (subscription.status == SubscriptionStatus.active) {
            final updateUri = Uri.https(
              _baseHost,
              '/subscriptions/${entry.key}/status.json',
            );
            await http.put(
              updateUri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode('inactive'),
            );
          }
        } catch (e) {
          print('Error deactivating subscription: $e');
          continue;
        }
      }
    }
  }
}