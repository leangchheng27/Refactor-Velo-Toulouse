import 'package:flutter/material.dart';
import '../../booking/booking_screen.dart';
import '../../plan/plan_screen.dart';
import '../../station/station_screen.dart';
import '../../../../../model/bike/bike.dart';
import '../../../../../model/subscription/subscription.dart';

class ConfirmViewModel extends ChangeNotifier {
	final Bike bike;
	final Subscription subscription;
	final String? stationName;

	ConfirmViewModel({
		required this.bike,
		required this.subscription,
		this.stationName,
	});

	bool isBusy = false;

	String get resolvedStationName {
		final candidate = stationName?.trim();
		if (candidate != null && candidate.isNotEmpty) {
			return candidate;
		}
		return 'Station ${bike.stationId}';
	}

	String get planLabel {
		switch (subscription.planId) {
			case 'p1':
				return 'Hourly Pass';
			case 'p2':
				return 'Day Pass';
			case 'p3':
				return 'Monthly Pass';
			case 'p4':
				return 'Yearly Pass';
			default:
				return subscription.planId;
		}
	}

	String get formattedExpiryDate {
		final date = subscription.endDate;
		const months = [
			'January',
			'February',
			'March',
			'April',
			'May',
			'June',
			'July',
			'August',
			'September',
			'October',
			'November',
			'December',
		];
		return '${months[date.month - 1]} ${date.day}, ${date.year}';
	}

	String get bikeSummary => 'Slot ${bike.slotNumber} | Bike #${bike.id}';

	String get footerMessage =>
			'${planLabel.toUpperCase()} - NO EXTRA CHARGE FOR THIS RIDE';

	String get warningMessage =>
			'Timer starts the moment you unlock. Be at the station before tapping the button below.';

	void onEditSelection(BuildContext context) {
		if (isBusy) {
			return;
		}

		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (_) => StationScreen(stationId: bike.stationId),
			),
		);
	}

	void onModifyPlan(BuildContext context) {
		if (isBusy) {
			return;
		}
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (_) => PlanScreen(
					pendingBike: bike,
					stationName: resolvedStationName,
				),
			),
		);
	}

	Future<void> onContinue(BuildContext context) async {
		if (isBusy) {
			return;
		}

		isBusy = true;
		notifyListeners();

		await Navigator.push(
			context,
			MaterialPageRoute(
				builder: (_) => BookingScreen(
					bike: bike,
					stationName: resolvedStationName,
					planLabel: planLabel,
				),
			),
		);

		if (!context.mounted) {
			return;
		}

		isBusy = false;
		notifyListeners();
	}
}
