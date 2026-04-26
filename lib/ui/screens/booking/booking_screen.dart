import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../model/bike/bike.dart';
import '../../states/booking_state.dart';
import '../../../../utils/async_value.dart';
import 'view_model/booking_view_model.dart';
import '../expired/expired_screen.dart';
import '../../../main_common.dart';
import 'widgets/station_header_widget.dart';
import 'widgets/bike_info_card_widget.dart';
import 'widgets/countdown_timer_widget.dart';
import 'widgets/plan_info_widget.dart';
import 'widgets/booking_actions_widget.dart';

class BookingScreen extends StatelessWidget {
  final Bike bike;
  final String stationName;
  final String planLabel;
  final String userId;

  const BookingScreen({
    super.key,
    required this.bike,
    this.stationName = 'Arnaud Bernard',
    this.planLabel = 'Monthly Pass',
    this.userId = 'currentUserId',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingViewModel(),
      child: _BookingScreenBody(
        bike: bike,
        stationName: stationName,
        planLabel: planLabel,
        userId: userId,
      ),
    );
  }
}

class _BookingScreenBody extends StatefulWidget {
  final Bike bike;
  final String stationName;
  final String planLabel;
  final String userId;

  const _BookingScreenBody({
    required this.bike,
    this.stationName = 'Arnaud Bernard',
    this.planLabel = 'Monthly Pass',
    required this.userId,
  });

  @override
  State<_BookingScreenBody> createState() => _BookingScreenBodyState();
}

class _BookingScreenBodyState extends State<_BookingScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<BookingViewModel>();
      viewModel.setBookingContext(
        bike: widget.bike,
        stationName: widget.stationName,
        planLabel: widget.planLabel,
      );
      viewModel.onExpired = () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExpiredScreen(
              bike: widget.bike,
              stationName: viewModel.stationName,
            ),
          ),
        );
      };
      viewModel.startCountdown();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BookingViewModel>();
    final bikeLabel = 'Bike #${viewModel.selectedBike?.id ?? widget.bike.id}';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StationHeaderWidget(stationName: viewModel.stationName),
                      const SizedBox(height: 60),
                      BikeInfoCardWidget(bikeLabel: bikeLabel),
                      const SizedBox(height: 26),
                      Center(
                        child: CountdownTimerWidget(countdown: viewModel.countdown),
                      ),
                      const SizedBox(height: 22),
                      PlanInfoWidget(planLabel: viewModel.planLabel),
                      const SizedBox(height: 16),
                      BookingActionsWidget(
                        isLoading: context.watch<BookingState>().activeBooking.state ==
                            AsyncValueState.loading,
                        onUnlock: () async {
                          context.read<BookingViewModel>().cancelCountdown();
                          await context.read<BookingState>().confirmBooking(
                                userId: widget.userId,
                                bike: widget.bike,
                              );
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const MyApp()),
                              (route) => false,
                            );
                          }
                        },
                        onCancel: () {
                          context.read<BookingViewModel>().cancelCountdown();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
