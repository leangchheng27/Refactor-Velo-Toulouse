import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../data/repositories/bike/bike_repository.dart';
import '../../../../data/repositories/station/station_repository.dart';
import '../../../../model/bike/bike.dart';
import '../../../../model/station/station.dart';
import '../../../../utils/async_value.dart';

class MapViewModel extends ChangeNotifier {
  final StationRepository _stationRepository;
  final BikeRepository _bikeRepository;
  Timer? _debounce;
  int _searchRequestId = 0;

  static const String returnStationHintMessage =
      'Select a station on the map to return your bike';
  static const String noBikesAvailableMessage =
      'No bikes available at this station';
  static const String stationFullMessage =
      'This station is full, please select another station';

  Timer? _toastTimer;
  String? _toastMessage;
  Color _toastBackgroundColor = Colors.transparent;

  MapViewModel(this._stationRepository, this._bikeRepository);

  AsyncValue<List<Station>> _stations = AsyncValue.loading();
  AsyncValue<List<Station>> _suggestions = AsyncValue.success([]);
  AsyncValue<List<Station>> _filteredStations = AsyncValue.loading();
  Station? selectedStation;
  Station? pinnedStation;
  final Map<String, int> availableBikeCounts = {};
  final Map<String, int> availableDockSlotCounts = {};
  final Map<String, List<int>> availableDockSlotNumbersByStation = {};
  final Map<String, int> bikeSlotNumbersById = {};
  final Map<String, String> stationNamesById = {};

  String searchQuery = '';
  bool showSuggestions = false;
  bool isSearchActive = false;

  AsyncValue<List<Station>> get stations => isSearchActive ? _filteredStations : _stations;
  AsyncValue<List<Station>> get suggestions => _suggestions;

  String? get toastMessage => _toastMessage;
  Color get toastBackgroundColor => _toastBackgroundColor;

  void showToast(
    String message, {
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    _toastTimer?.cancel();
    _toastMessage = message;
    _toastBackgroundColor = backgroundColor;
    notifyListeners();

    _toastTimer = Timer(duration, () {
      _toastMessage = null;
      notifyListeners();
    });
  }

  void showReturnStationHintToast() {
    showToast(
      returnStationHintMessage,
      backgroundColor: Colors.black.withValues(alpha: 0.88),
    );
  }

  void showPinValidationErrorToast(String message) {
    showToast(message, backgroundColor: Colors.red.shade600);
  }

  bool hasAvailableBikes(String stationId) {
    return (availableBikeCounts[stationId] ?? 0) > 0;
  }

  bool hasAvailableDockSlots(String stationId) {
    return (availableDockSlotCounts[stationId] ?? 0) > 0;
  }

  Future<void> loadStations() async {
    _stations = AsyncValue.loading();
    notifyListeners();

    try {
      final stations = await _stationRepository.fetchStations();
      _loadStationNames(stations);
      await _loadStationCounts(stations);
      _stations = AsyncValue.success(stations);
    } catch (e) {
      _stations = AsyncValue.error(e);
    }

    notifyListeners();
  }

  void onSearchChanged(String query, {LatLng? nearCenter}) {
    searchQuery = query;

    if (query.trim().isEmpty) {
      _suggestions = AsyncValue.success([]);
      showSuggestions = false;
      selectedStation = null;
      isSearchActive = false;
      notifyListeners();
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSuggestions(query, nearCenter: nearCenter);
    });
  }

  Future<void> _runSuggestions(String query, {LatLng? nearCenter}) async {
    final requestId = ++_searchRequestId;
    _suggestions = AsyncValue.loading();
    showSuggestions = true;
    notifyListeners();

    try {
      var result = await _stationRepository.searchStations(query);
      if (nearCenter != null) {
        result = _sortByDistance(result, nearCenter);
      }

      if (requestId != _searchRequestId) return;

      _suggestions = AsyncValue.success(result);
    } catch (e) {
      if (requestId != _searchRequestId) return;
      _suggestions = AsyncValue.error(e);
    } finally {
      if (requestId == _searchRequestId) {
        notifyListeners();
      }
    }
  }

  void _loadStationNames(List<Station> stations) {
    stationNamesById
      ..clear()
      ..addEntries(stations.map((station) => MapEntry(station.id, station.name)));
  }

  Future<void> _loadStationCounts(List<Station> stations) async {
    availableBikeCounts.clear();
    availableDockSlotCounts.clear();
    availableDockSlotNumbersByStation.clear();
    bikeSlotNumbersById.clear();

    final results = await Future.wait(
      stations.map((s) => _bikeRepository.fetchBikesByStation(s.id)),
    );

    for (var i = 0; i < stations.length; i++) {
      final bikes = results[i];
      final station = stations[i];
      final stationId = station.id;
      final availableBikes = bikes
          .where((bike) => bike.status == BikeStatus.available)
          .length;

      availableBikeCounts[stationId] = availableBikes;
      final occupiedSlots = bikes
          .where((bike) => bike.status == BikeStatus.available)
          .map((bike) => bike.slotNumber)
          .toSet();
      final freeSlots = <int>[];
      for (var slot = 1; slot <= station.totalDocks; slot++) {
        if (!occupiedSlots.contains(slot)) {
          freeSlots.add(slot);
        }
      }
      availableDockSlotCounts[stationId] = freeSlots.length;
      availableDockSlotNumbersByStation[stationId] = freeSlots;

      for (final bike in bikes) {
        bikeSlotNumbersById[bike.id] = bike.slotNumber;
      }
    }
  }

  void onSuggestionSelected(Station station) {
    selectedStation = station;
    searchQuery = station.name;
    showSuggestions = false;
    _suggestions = AsyncValue.success([]);
    isSearchActive = true;
    
    // Filter to show ONLY the selected station
    final filtered = [station];
    _filteredStations = AsyncValue.success(filtered);
    
    notifyListeners();
  }

  void onPinTapped(Station station) {
    pinnedStation = station;
    dismissSuggestions();
    notifyListeners();
  }

  void dismissPinnedStation() {
    pinnedStation = null;
    notifyListeners();
  }

  void dismissSuggestions() {
    showSuggestions = false;
    notifyListeners();
  }

  void clearSearch() {
    searchQuery = '';
    _suggestions = AsyncValue.success([]);
    selectedStation = null;
    showSuggestions = false;
    isSearchActive = false;
    notifyListeners();
  }

  List<Station> _sortByDistance(List<Station> input, LatLng center) {
    final sorted = List<Station>.from(input);
    sorted.sort((a, b) {
      final distanceA = _distanceScore(a, center);
      final distanceB = _distanceScore(b, center);
      return distanceA.compareTo(distanceB);
    });
    return sorted;
  }

  double _distanceScore(Station station, LatLng center) {
    final latDelta = station.latitude - center.latitude;
    final lngDelta = station.longitude - center.longitude;
    return (latDelta * latDelta) + (lngDelta * lngDelta);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }
}