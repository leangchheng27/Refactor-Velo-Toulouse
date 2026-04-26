import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../model/booking/booking.dart';
import '../../../utils/async_value.dart';
import '../../states/booking_state.dart';
import '../../../../data/repositories/bike/bike_repository.dart';
import '../../../../data/repositories/station/station_repository.dart';
import 'view_model/map_view_model.dart';
import 'widgets/current_ride_bottom_sheet.dart';
import 'widgets/search_bar.dart';
import 'widgets/map_pin.dart';
import 'widgets/station_bottom_sheet.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(
        context.read<StationRepository>(),
        context.read<BikeRepository>(),
      ),
      child: const _MapScreenBody(),
    );
  }
}

class _MapScreenBody extends StatefulWidget {
  const _MapScreenBody();

  @override
  State<_MapScreenBody> createState() => _MapScreenBodyState();
}

class _MapScreenBodyState extends State<_MapScreenBody> {
  static const LatLng _defaultCenter = LatLng(43.6047, 1.4442);
  static const double _bottomNavOverlayHeight = 98;
  final MapController _mapController = MapController();
  bool _isCurrentRideModalVisible = false;
  bool _isOpeningCurrentRideModal = false;
  bool _isSelectingReturnStation = false;
  String? _lastCurrentRideId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MapViewModel>().loadStations();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = context.read<MapViewModel>();
    viewModel.removeListener(_onViewModelChanged);
    viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    final viewModel = context.read<MapViewModel>();
    final station = viewModel.pinnedStation ?? viewModel.selectedStation;
    if (station != null) {
      _mapController.move(LatLng(station.latitude, station.longitude), 15);
    }
  }

  @override
  void dispose() {
    context.read<MapViewModel>().removeListener(_onViewModelChanged);
    super.dispose();
  }

  LatLng get _currentMapCenter {
    try {
      return _mapController.camera.center;
    } catch (_) {
      return _defaultCenter;
    }
  }

  Future<void> _openCurrentRideModal(
    Booking? booking,
    MapViewModel viewModel,
    BookingState bookingState,
  ) async {
    if (booking == null) return;
    if (_isCurrentRideModalVisible || _isOpeningCurrentRideModal) return;

    _isOpeningCurrentRideModal = true;
    final resolvedStationName =
        viewModel.stationNamesById[booking.stationId] ??
        (viewModel.pinnedStation?.id == booking.stationId
            ? viewModel.pinnedStation?.name
            : null) ??
        (viewModel.selectedStation?.id == booking.stationId
            ? viewModel.selectedStation?.name
            : null) ??
        'Station ${booking.stationId}';

    try {
      _isCurrentRideModalVisible = true;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        builder: (sheetContext) {
          return CurrentRideBottomSheet(
            stationName: resolvedStationName,
            slotNumber: viewModel.bikeSlotNumbersById[booking.bikeId],
            rideStartTime: booking.startTime,
            isSelectingReturnStation: _isSelectingReturnStation,
            isReturning: bookingState.isCompletingRide,
            onStartReturnSelection: () async {
              if (!mounted) return;
              viewModel.showReturnStationHintToast();
              Navigator.of(sheetContext).pop();
              if (!mounted) return;
              setState(() {
                _isSelectingReturnStation = true;
              });
              await viewModel.loadStations();
            },
          );
        },
      );

      _isCurrentRideModalVisible = false;
      if (!mounted) return;
    } finally {
      _isOpeningCurrentRideModal = false;
    }
  }

  Future<void> _onReturnStationTapped({
    required Booking booking,
    required String stationId,
    required MapViewModel viewModel,
    required BookingState bookingState,
  }) async {
    final availableSlots = viewModel.availableDockSlotCounts[stationId] ?? 0;
    final slotOptions =
        viewModel.availableDockSlotNumbersByStation[stationId] ?? <int>[];
    if (!bookingState.canProceedWithReturnStationTap(
      availableSlotCount: availableSlots,
      slotOptions: slotOptions,
    )) {
      if (bookingState.noSlotError) {
        viewModel.showPinValidationErrorToast(MapViewModel.stationFullMessage);
      }
      return;
    }

    final stationName =
        viewModel.stationNamesById[stationId] ?? 'Station $stationId';
    int selectedSlot = slotOptions.first;

    final shouldReturn = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('Return Bike'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stationName),
                  const SizedBox(height: 8),
                  Text('Available slots: $availableSlots'),
                  const SizedBox(height: 12),
                  const Text(
                    'Select slot',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD92B74)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFD92B74),
                          width: 2,
                        ),
                      ),
                    ),
                    initialValue: selectedSlot,
                    isExpanded: true,
                    items: slotOptions
                        .map(
                          (slot) => DropdownMenuItem<int>(
                            value: slot,
                            child: Text(
                              'Slot ${slot.toString().padLeft(2, '0')}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedSlot = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            SizedBox(
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8A00), Color(0xFFD92B74)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Return Here',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldReturn != true) {
      return;
    }

    final rideDuration = bookingState.calculateRideDuration(
      booking.startTime,
    );
    await bookingState.completeRide(
      returnStationId: stationId,
      returnSlotNumber: selectedSlot,
    );
    await viewModel.loadStations();

    if (!mounted) return;

    if (_isCurrentRideModalVisible) {
      Navigator.of(context).pop();
    }

    setState(() {
      _isSelectingReturnStation = false;
    });

    await _showRideSummaryBottomSheet(
      stationName: stationName,
      rideDuration: rideDuration,
      returnedSlot: selectedSlot,
    );
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _showRideSummaryBottomSheet({
    required String stationName,
    required Duration rideDuration,
    required int returnedSlot,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bike returned successfully',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Returned at',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stationName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Returned slot',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Slot ${returnedSlot.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Ride duration',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(rideDuration),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A00), Color(0xFFD92B74)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _syncCurrentRideModal({
    required bool hasCurrentRide,
    required Booking? activeBooking,
    required MapViewModel viewModel,
    required BookingState bookingState,
  }) {
    final currentRideId = hasCurrentRide ? activeBooking?.id : null;
    if (currentRideId != _lastCurrentRideId) {
      _lastCurrentRideId = currentRideId;
      _isSelectingReturnStation = false;
    }

    if (!hasCurrentRide) {
      _isSelectingReturnStation = false;
      if (_isCurrentRideModalVisible) {
        Navigator.of(context).pop();
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();
    final bookingState = context.watch<BookingState>();
    final activeBooking = bookingState.activeBookingData;
    final hasCurrentRide = bookingState.hasCurrentRide;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncCurrentRideModal(
        hasCurrentRide: hasCurrentRide,
        activeBooking: activeBooking,
        viewModel: viewModel,
        bookingState: bookingState,
      );
    });

    final isReturnSelectionMode = hasCurrentRide && _isSelectingReturnStation;
    final showDockSlotsOnPins = hasCurrentRide;
    final markerCounts = showDockSlotsOnPins
        ? viewModel.availableDockSlotCounts
        : viewModel.availableBikeCounts;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          viewModel.dismissSuggestions();
          viewModel.dismissPinnedStation();
        },
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 13,
                onTap: (tapPosition, latLng) {
                  viewModel.dismissSuggestions();
                  viewModel.dismissPinnedStation();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  userAgentPackageName: 'refactor_velo_toulouse',
                ),
                MarkerLayer(
                  markers: viewModel.stations.state == AsyncValueState.success
                      ? (viewModel.stations.data ?? []).map((station) {
                          final stationId = station.id;
                          final isPinned =
                              viewModel.pinnedStation?.id == stationId;
                          final count = markerCounts[stationId] ?? 0;
                          final showSelectedRideLabel =
                              hasCurrentRide && isPinned && count > 0;
                          return Marker(
                            point: LatLng(station.latitude, station.longitude),
                            width: showSelectedRideLabel
                                ? 180
                                : (isPinned ? 100 : 56),
                            height: showSelectedRideLabel
                                ? 130
                                : (isPinned ? 100 : 56),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (showSelectedRideLabel)
                                    IgnorePointer(
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.12,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              station.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF212121),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Available slots: $count',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF616161),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  MapPinWidget(
                                    isSelected: isPinned,
                                    availableBikeCount: count,
                                    countPrefix: showDockSlotsOnPins ? 'P' : 'B',
                                    pinColor: count > 0
                                        ? Colors.green
                                        : Colors.red,
                                    onTap: () {
                                      if (isReturnSelectionMode) {
                                        _onReturnStationTapped(
                                          booking: activeBooking!,
                                          stationId: stationId,
                                          viewModel: viewModel,
                                          bookingState: bookingState,
                                        );
                                        return;
                                      }

                                      if (hasCurrentRide && count <= 0) {
                                        viewModel.showPinValidationErrorToast(
                                          MapViewModel.stationFullMessage,
                                        );
                                      }

                                      if (!bookingState
                                          .canProceedWithStationTapForBooking(
                                            hasCurrentRide: hasCurrentRide,
                                            availableBikeCount: count,
                                          )) {
                                        viewModel.showPinValidationErrorToast(
                                          MapViewModel.noBikesAvailableMessage,
                                        );
                                        return;
                                      }
                                      viewModel.onPinTapped(station);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList()
                      : [],
                ),
              ],
            ),
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchBarWidget(mapCenter: _currentMapCenter),
                  IgnorePointer(
                    ignoring: true,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: viewModel.toastMessage == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: viewModel.toastBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.18),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    viewModel.toastMessage!,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: _bottomNavOverlayHeight,
              child: AnimatedSlide(
                offset: viewModel.pinnedStation != null && !hasCurrentRide
                    ? Offset.zero
                    : const Offset(0, 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: viewModel.pinnedStation != null && !hasCurrentRide
                    ? StationBottomSheet(
                        station: viewModel.pinnedStation!,
                        availableBikeCount:
                            viewModel.availableBikeCounts[viewModel
                                .pinnedStation!
                                .id] ??
                            0,
                        onDismiss: viewModel.dismissPinnedStation,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            if (viewModel.stations.state == AsyncValueState.loading)
              const Center(child: CircularProgressIndicator()),
            if (viewModel.stations.state == AsyncValueState.error)
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red.shade600,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      viewModel.stations.error.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            if (hasCurrentRide &&
                !_isCurrentRideModalVisible &&
                !_isSelectingReturnStation)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        if (_isCurrentRideModalVisible ||
                            _isOpeningCurrentRideModal) {
                          return;
                        }
                        _openCurrentRideModal(
                          activeBooking,
                          viewModel,
                          bookingState,
                        );
                      },
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions_bike,
                              size: 16,
                              color: Color(0xFFE53935),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Current ride',
                              style: TextStyle(
                                color: Color(0xFF212121),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
