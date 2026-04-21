import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:local_service_app/core/config/app_config.dart';
import 'package:local_service_app/core/constants/app_constants.dart';
import 'package:local_service_app/core/widgets/app_button.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

// ─── Map State ────────────────────────────────────────────────────────────────

class MapState {
  const MapState({
    this.currentLocation,
    this.address,
    this.isLocating = false,
    this.errorMessage,
  });

  final LatLng? currentLocation;
  final String? address;
  final bool isLocating;
  final String? errorMessage;

  MapState copyWith({
    LatLng? currentLocation,
    String? address,
    bool? isLocating,
    String? errorMessage,
  }) =>
      MapState(
        currentLocation: currentLocation ?? this.currentLocation,
        address: address ?? this.address,
        isLocating: isLocating ?? this.isLocating,
        errorMessage: errorMessage,
      );
}

// ─── Map Notifier ─────────────────────────────────────────────────────────────

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(const MapState());

  Future<void> locateMe() async {
    state = state.copyWith(isLocating: true, errorMessage: null);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
            isLocating: false,
            errorMessage: 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
              isLocating: false,
              errorMessage: 'Location permission denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
            isLocating: false,
            errorMessage: 'Location permission permanently denied.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      final address = await _reverseGeocode(latLng);
      state = state.copyWith(
        isLocating: false,
        currentLocation: latLng,
        address: address,
      );
    } catch (e) {
      state = state.copyWith(
          isLocating: false,
          errorMessage: 'Could not get location. Try again.');
    }
  }

  /// Reverse geocoding using Nominatim (free, no API key)
  Future<String?> _reverseGeocode(LatLng latLng) async {
    try {
      final url = Uri.parse(
          '${AppConfig.nominatimBaseUrl}/reverse?lat=${latLng.latitude}&lon=${latLng.longitude}&format=json');
      final res = await http.get(url, headers: {
        'User-Agent': 'LocalServeApp/1.0',
        'Accept-Language': 'en',
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['display_name'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    if (query.isEmpty) return [];
    try {
      final url = Uri.parse(
          '${AppConfig.nominatimBaseUrl}/search?q=${Uri.encodeComponent(query)}&format=json&limit=5');
      final res = await http.get(url, headers: {
        'User-Agent': 'LocalServeApp/1.0',
        'Accept-Language': 'en',
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  void setLocation(LatLng latLng, {String? address}) {
    state = state.copyWith(currentLocation: latLng, address: address);
  }
}

final mapNotifierProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});

// ─── Map Screen ───────────────────────────────────────────────────────────────

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.selectionMode = false});
  final bool selectionMode;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  static const _defaultLatLng = LatLng(
    AppConstants.defaultLatitude,
    AppConstants.defaultLongitude,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapNotifierProvider.notifier).locateMe();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    final results =
        await ref.read(mapNotifierProvider.notifier).searchAddress(query);
    setState(() => _searchResults = results);
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = double.tryParse(result['lat'].toString()) ?? 0;
    final lon = double.tryParse(result['lon'].toString()) ?? 0;
    final latLng = LatLng(lat, lon);
    ref
        .read(mapNotifierProvider.notifier)
        .setLocation(latLng, address: result['display_name'] as String?);
    _mapController.move(latLng, 14);
    _searchController.text = result['display_name'] as String? ?? '';
    setState(() => _searchResults = []);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final center = mapState.currentLocation ?? _defaultLatLng;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ─────────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: AppConstants.defaultZoom,
              onTap: (tapPos, latLng) {
                if (widget.selectionMode) {
                  ref.read(mapNotifierProvider.notifier).setLocation(latLng);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: AppConfig.osmTileUrl,
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.localservice.app',
              ),
              if (mapState.currentLocation != null)
                MarkerLayer(
                  markers: [
                    // Customer marker
                    Marker(
                      point: mapState.currentLocation!,
                      width: 48,
                      height: 48,
                      child: _CustomerMarker(),
                    ),
                    // Mock provider markers
                    Marker(
                      point: LatLng(center.latitude + 0.01, center.longitude + 0.01),
                      width: 48,
                      height: 48,
                      child: _ProviderMarker(),
                    ),
                    Marker(
                      point: LatLng(center.latitude - 0.008, center.longitude + 0.015),
                      width: 48,
                      height: 48,
                      child: _ProviderMarker(),
                    ),
                  ],
                ),
            ],
          ),

          // ── Search Bar ───────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Material(
                    elevation: 6,
                    borderRadius: AppRadius.r12,
                    shadowColor: Colors.black26,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      style: AppTypography.bodyMedium(
                          color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900),
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        hintStyle: AppTypography.bodyMedium(color: AppColors.grey400),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchResults = []);
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.r12,
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
                      ),
                    ),
                  ),
                ),

                // Search results
                if (_searchResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: Material(
                      borderRadius: AppRadius.r12,
                      elevation: 4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.take(5).length,
                        itemBuilder: (_, i) {
                          final r = _searchResults[i];
                          return ListTile(
                            leading: const Icon(Icons.location_on_rounded,
                                color: AppColors.primary),
                            title: Text(
                              r['display_name'] as String? ?? '',
                              style: AppTypography.bodySmall(
                                  color: (Theme.of(context).brightness == Brightness.dark)
                                      ? Colors.white
                                      : AppColors.grey800),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchResult(r),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Bottom Sheet ──────────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl2)),
                boxShadow: AppShadows.lg,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.grey300,
                          borderRadius: AppRadius.chip,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            mapState.address ?? 'Detecting location...',
                            style: AppTypography.bodyMedium(
                                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey800),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (widget.selectionMode)
                      GradientButton(
                        label: 'Confirm Location',
                        icon: Icons.check_circle_rounded,
                        onPressed: () =>
                            Navigator.of(context).pop(mapState.currentLocation),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Locate Me FAB ─────────────────────────────────────────────────────
          Positioned(
            right: AppSpacing.md,
            bottom: 160,
            child: AppIconButton(
              icon: mapState.isLocating
                  ? Icons.loop_rounded
                  : Icons.my_location_rounded,
              onPressed: mapState.isLocating
                  ? null
                  : () {
                      ref.read(mapNotifierProvider.notifier).locateMe().then((_) {
                        final loc = ref.read(mapNotifierProvider).currentLocation;
                        if (loc != null) _mapController.move(loc, 15);
                      });
                    },
              size: 48,
              color: AppColors.primary,
              backgroundColor: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : Colors.white,
              bordered: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Map Markers ──────────────────────────────────────────────────────────────

class _CustomerMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mapPinCustomer,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: AppShadows.md,
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
    );
  }
}

class _ProviderMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mapPinProvider,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: AppShadows.md,
      ),
      child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 20),
    );
  }
}
