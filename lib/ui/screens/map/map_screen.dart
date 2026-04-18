import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../utils/async_value.dart';
import '../../../../data/repositories/bike/bike_repository.dart';
import '../../../../data/repositories/station/station_repository.dart';
import 'view_model/map_view_model.dart';
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
  final MapController _mapController = MapController();

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
      _mapController.move(
        LatLng(station.latitude, station.longitude),
        15,
      );
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

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
                onTap: (_, __) {
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
                          final isPinned =
                              viewModel.pinnedStation?.id == station.id;
                          return Marker(
                            point: LatLng(station.latitude, station.longitude),
                            width: isPinned ? 100 : 56,
                            height: isPinned ? 100 : 56,
                            child: MapPinWidget(
                              isSelected: isPinned,
                              availableBikeCount:
                                  viewModel.availableBikeCounts[station.id] ??
                                      0,
                              onTap: () => viewModel.onPinTapped(station),
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
              child: SearchBarWidget(mapCenter: _currentMapCenter),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                offset: viewModel.pinnedStation != null
                    ? Offset.zero
                    : const Offset(0, 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: viewModel.pinnedStation != null
                    ? StationBottomSheet(
                        station: viewModel.pinnedStation!,
                        availableBikeCount: viewModel.availableBikeCounts[
                                viewModel.pinnedStation!.id] ??
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
                        horizontal: 16, vertical: 12),
                    child: Text(
                      viewModel.stations.error.toString(),
                      style: const TextStyle(color: Colors.white),
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