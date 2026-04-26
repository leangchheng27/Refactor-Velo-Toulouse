import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../model/bike/bike.dart';
import '../../states/booking_state.dart';
import '../station/station_screen.dart';
import 'widgets/expired_header_widget.dart';
import 'widgets/station_info_box_widget.dart';
import 'widgets/unlock_again_card_widget.dart';
import 'widgets/action_card_widget.dart';

class ExpiredScreen extends StatelessWidget {
  final Bike bike;
  final String? stationName;

  const ExpiredScreen({
    super.key,
    required this.bike,
    this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    final bookingState = context.watch<BookingState>();
    final displayStationName = stationName ?? 'Station ${bike.stationId}';
    final stationLabel = displayStationName.toUpperCase();

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
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpiredHeaderWidget(
                        bikeId: bike.id,
                        stationName: stationName,
                      ),
                      const SizedBox(height: 14),
                      StationInfoBoxWidget(stationLabel: stationLabel),
                      const SizedBox(height: 18),
                      const UnlockAgainCardWidget(),
                      const SizedBox(height: 24),
                      ActionCardWidget(
                        backgroundColor: const Color(0xFFF9E5EC),
                        icon: Icons.swap_horiz,
                        iconColor: const Color(0xFFD63B58),
                        title: 'Pick a different bike',
                        subtitle:
                            'Browse other bikes at ${displayStationName.toLowerCase()} or nearby.',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StationScreen(stationId: bike.stationId),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ActionCardWidget(
                        backgroundColor: const Color(0xFFF9E5EC),
                        icon: Icons.close,
                        iconColor: const Color(0xFFD63B58),
                        title: 'Cancel booking',
                        subtitle: 'No charge applied. Your Pass remains active.',
                        onTap: () async {
                          await context.read<BookingState>().cancelBooking();
                          if (context.mounted) {
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          }
                        },
                      ),
                      if (bookingState.activeBooking.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          bookingState.activeBooking.error.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
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