import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/async_value.dart';
import '../../../../data/repositories/bike/bike_repository.dart';
import '../../../../data/repositories/station/station_repository.dart';
import 'view_model/station_view_model.dart';
import 'widgets/bike_card.dart';
import '../confirm/confirm_screen.dart';
import '../plan/plan_screen.dart';
import '../../../../model/bike/bike.dart';
import '../../../../model/subscription/subscription.dart';
import '../../states/subscription_state.dart';

class StationScreen extends StatelessWidget {
  final String stationId;

  const StationScreen({super.key, required this.stationId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StationViewModel(
        context.read<StationRepository>(),
        context.read<BikeRepository>(),
      ),
      child: _StationScreenBody(stationId: stationId),
    );
  }
}

class _StationScreenBody extends StatefulWidget {
  final String stationId;

  const _StationScreenBody({required this.stationId});

  @override
  State<_StationScreenBody> createState() => _StationScreenBodyState();
}

class _StationScreenBodyState extends State<_StationScreenBody> {
  static const String _currentUserId = 'currentUserId';
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StationViewModel>().loadStation(widget.stationId);
    });
  }

  Future<void> _onBookPressed(Bike bike) async {
    if (_isBooking) return;
    _isBooking = true;

    try {
      final subscriptionState = context.read<SubscriptionState>();

      if (subscriptionState.activeSubscription.data == null &&
          subscriptionState.activeSubscription.state !=
              AsyncValueState.loading) {
        await subscriptionState.loadActiveSubscription(_currentUserId);
      }

      if (!mounted) return;

      final activeSubscription = subscriptionState.activeSubscription.data;
      final hasActiveSubscription = activeSubscription != null &&
          activeSubscription.status == SubscriptionStatus.active;

      if (!hasActiveSubscription) {
        final goToPlans = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFF7F1F4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: const Text(
              'Subscription Required',
              style: TextStyle(
                color: Color(0xFF402437),
                fontSize: 38,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: const Text(
              'You need an active subscription before booking a bike.',
              style: TextStyle(
                color: Color(0xFF6C4D5E),
                fontSize: 16,
                height: 1.35,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD63B58),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                child: const Text('Not now'),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFB7D00), Color(0xFFD10C6B)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD10C6B).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('View plans'),
                ),
              ),
            ],
          ),
        );

        if (goToPlans == true && mounted) {
          final stationName =
              context.read<StationViewModel>().selectedStation?.name;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlanScreen(
                pendingBike: bike,
                stationName: stationName,
              ),
            ),
          );
        }
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmScreen(
            bike: bike,
            subscription: activeSubscription,
            stationName:
                context.read<StationViewModel>().selectedStation?.name,
          ),
        ),
      );
    } finally {
      if (mounted) _isBooking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StationViewModel>();
    final stationName = viewModel.selectedStation?.name ?? 'Station Info';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: switch (viewModel.bikes.state) {
        AsyncValueState.loading =>
          const Center(child: CircularProgressIndicator()),
        AsyncValueState.error =>
          Center(child: Text('Error: ${viewModel.bikes.error}')),
        AsyncValueState.success =>
          _buildSuccessContent(context, viewModel, stationName),
      },
    );
  }

  Widget _buildSuccessContent(
      BuildContext context, StationViewModel viewModel, String stationName) {
    final availableBikeList = (viewModel.bikes.data ?? [])
        .where((bike) => bike.status == BikeStatus.available)
        .toList()
      ..sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
    final availableBikes = availableBikeList.length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
                const Text(
                  'Station Info',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'CURRENT STATION',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    stationName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF8A00), Color(0xFFD92B74)],
                    ),
                  ),
                  child: const Icon(Icons.location_on,
                      size: 20, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A00), Color(0xFFD92B74)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_bike,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AVAILABLE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '$availableBikes Bikes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (availableBikeList.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    'No available bikes at this station.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              ...availableBikeList.map((bike) {
                return BikeCardWidget(
                  bike: bike,
                  onBook: () => _onBookPressed(bike),
                );
              }),
          ],
        ),
      ),
    );
  }
}