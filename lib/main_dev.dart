import 'package:provider/provider.dart';
import 'data/repositories/bike/bike_repository.dart';
import 'data/repositories/bike/bike_repository_firebase.dart';
import 'data/repositories/station/station_repository.dart';
import 'data/repositories/station/station_repository_firebase.dart';
import 'data/repositories/plan/plan_repository.dart';
import 'data/repositories/plan/plan_repository_firebase.dart';
import 'data/repositories/subscription/subscription_repository.dart';
import 'data/repositories/subscription/subscription_repository_firebase.dart';
import 'data/repositories/payment/payment_repository.dart';
import 'data/repositories/payment/payment_repository_firebase.dart';
import 'data/repositories/booking/booking_repository.dart';
import 'data/repositories/booking/booking_repository_firebase.dart';
import 'ui/states/booking_state.dart';
import 'ui/states/subscription_state.dart';
import 'main_common.dart';

List<InheritedProvider> get devProviders {
  final bikeRepository = BikeRepositoryFirebase();
  final stationRepository = StationRepositoryFirebase();
  final planRepository = PlanRepositoryFirebase();
  final subscriptionRepository = SubscriptionRepositoryFirebase();
  final paymentRepository = PaymentRepositoryFirebase();
  final bookingRepository = BookingRepositoryFirebase();

  return [
    Provider<BikeRepository>(create: (_) => bikeRepository),
    Provider<StationRepository>(create: (_) => stationRepository),
    Provider<PlanRepository>(create: (_) => planRepository),
    Provider<SubscriptionRepository>(create: (_) => subscriptionRepository),
    Provider<PaymentRepository>(create: (_) => paymentRepository),
    Provider<BookingRepository>(create: (_) => bookingRepository),
    ChangeNotifierProvider<SubscriptionState>(
      create: (_) => SubscriptionState(subscriptionRepository),
    ),
    ChangeNotifierProvider<BookingState>(
      create: (_) => BookingState(
        bookingRepository,
        bikeRepository,
        stationRepository,
      ),
    ),
  ];
}

void main() {
  mainCommon(devProviders);
}