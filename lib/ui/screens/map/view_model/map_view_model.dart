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

  MapViewModel(this._stationRepository, this._bikeRepository);

  AsyncValue<List<Station>> _stations = AsyncValue.loading();
  AsyncValue<List<Station>> _suggestions = AsyncValue.success([]);
  AsyncValue<List<Station>> _filteredStations = AsyncValue.loading();
  Station? selectedStation;
  Station? pinnedStation;
  final Map<String, int> availableBikeCounts = {};

  String searchQuery = '';
  bool showSuggestions = false;
  bool isSearchActive = false;

  AsyncValue<List<Station>> get stations => isSearchActive ? _filteredStations : _stations;
  AsyncValue<List<Station>> get suggestions => _suggestions;

  Future<void> loadStations() async {
    _stations = AsyncValue.loading();
    notifyListeners();

    try {
      final stations = await _stationRepository.fetchStations();
      await _loadAvailableBikeCounts(stations);
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

  Future<void> _loadAvailableBikeCounts(List<Station> stations) async {
    availableBikeCounts.clear();

    final results = await Future.wait(
      stations.map((s) => _bikeRepository.fetchBikesByStation(s.id)),
    );

    for (var i = 0; i < stations.length; i++) {
      availableBikeCounts[stations[i].id] = results[i]
          .where((bike) => bike.status == BikeStatus.available)
          .length;
    }
  }

  void onSuggestionSelected(Station station) {
    selectedStation = station;
    searchQuery = station.name;
    showSuggestions = false;
    _suggestions = AsyncValue.success([]);
    isSearchActive = true;
    
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
    super.dispose();
  }
}