import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/injection.dart';
import '../../core/services/location_service.dart';
import '../../core/services/geocoding_service.dart';
import '../../l10n/app_localizations.dart';

/// Dashboard Header Component
/// Displays time-based greeting with DYNAMIC location from GPS.
/// Uses Nominatim API for reverse geocoding (city name).

class DashboardHeader extends StatefulWidget {
  final VoidCallback? onSearchTap;
  
  const DashboardHeader({super.key, this.onSearchTap});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> with WidgetsBindingObserver {
  String _locationName = 'Konum alınıyor...';
  bool _isLoading = true;
  bool _hasError = false;
  
  VoidCallback? get onSearchTap => widget.onSearchTap;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchLocation();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasError) {
      _fetchLocation();
    }
  }
  
  Future<void> _fetchLocation() async {
    if (_isLoading && _locationName != 'Konum alınıyor...') return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _locationName = 'Konum alınıyor...';
    });
    
    try {
      final locationService = getIt<LocationService>();
      final geocodingService = getIt<GeocodingService>();
      
      Position? position;
      
      if (kIsWeb) {
        // Web-specific handling
        debugPrint('Header: Checking web location permission...');
        final permission = await Geolocator.checkPermission();
        
        if (permission == LocationPermission.denied) {
          final newPermission = await Geolocator.requestPermission();
          if (newPermission == LocationPermission.denied || 
              newPermission == LocationPermission.deniedForever) {
            _setError('Konum izni verilmedi');
            return;
          }
        } else if (permission == LocationPermission.deniedForever) {
          _setError('Konum izni engellendi');
          return;
        }
        
        // Get position with retry
        for (int i = 0; i < 3; i++) {
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 15),
              ),
            );
            if (position != null) break;
          } catch (e) {
            debugPrint('Header: Web location attempt ${i + 1} failed: $e');
            if (i < 2) await Future.delayed(const Duration(seconds: 2));
          }
        }
      } else {
        position = await locationService.getCurrentLocation();
      }
      
      if (position == null) {
        _setError('Konuma dokunarak yenile');
        return;
      }
      
      debugPrint('Header: Got position: ${position.latitude}, ${position.longitude}');
      
      // Reverse geocode using Nominatim
      final result = await geocodingService.reverseGeocode(
        position.latitude, 
        position.longitude,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
          _locationName = result?.formattedName ?? 
              '${position!.latitude.toStringAsFixed(2)}°, ${position.longitude.toStringAsFixed(2)}°';
        });
      }
      
      debugPrint('Header: Final location name: $_locationName');
      
    } catch (e) {
      debugPrint('Header: Error - $e');
      _setError('Konuma dokunarak yenile');
    }
  }
  
  void _setError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _locationName = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final greetingKey = TimeBasedGreeting.getGreetingKey();
    
    String greeting;
    switch (greetingKey) {
      case 'greeting_morning':
        greeting = loc.greeting_morning;
        break;
      case 'greeting_afternoon':
        greeting = loc.greeting_afternoon;
        break;
      case 'greeting_evening':
        greeting = loc.greeting_evening;
        break;
      default:
        greeting = loc.greeting_night;
    }
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        gradient: AppTheme.getHeaderGradientByTime(),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tappable location row
                  GestureDetector(
                    onTap: _hasError ? _fetchLocation : null,
                    child: Row(
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          )
                        else
                          Icon(
                            _hasError ? Icons.refresh : Icons.location_on_outlined,
                            size: 14,
                            color: Colors.white70,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          _locationName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            decoration: _hasError ? TextDecoration.underline : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.ai_placeholder,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Icon(Icons.mic_none_rounded, color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
