import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../model/bike/bike.dart';

class BookingViewModel extends ChangeNotifier {
  // UI Context / Countdown
  Bike? selectedBike;
  String stationName = 'Arnaud Bernard';
  String planLabel = 'Monthly Pass';
  int countdown = 30;
  bool _initialized = false;
  Timer? _timer;
  VoidCallback? onExpired;

  BookingViewModel();

  //  Getters 
  bool get initialized => _initialized;

  // UI Context Methods 
  void setBookingContext({
    required Bike bike,
    required String stationName,
    required String planLabel,
  }) {
    selectedBike = bike;
    this.stationName = stationName;
    this.planLabel = planLabel;
    _initialized = true;
    notifyListeners();
  }

  void startCountdown() {
    countdown = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (countdown == 0) {
        _timer?.cancel();
        onExpired?.call();
      } else {
        countdown--;
        notifyListeners();
      }
    });
  }

  void cancelCountdown() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}