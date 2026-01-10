import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/injection.dart';
import '../../core/services/location_service.dart';
import '../../l10n/app_localizations.dart';

/// Dashboard Header Component
/// Displays time-based greeting with DYNAMIC location from GPS.
/// [onSearchTap] - Callback when search bar is tapped (navigates to AI page).

class DashboardHeader extends StatefulWidget {
  final VoidCallback? onSearchTap;
  
  const DashboardHeader({super.key, this.onSearchTap});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> with WidgetsBindingObserver {
  String _locationName = 'Konum alınıyor...';
  bool _isLoading = false;
  bool _hasError = false;
  
  // Getter for callback
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
  
  // Called when app resumes from background (after permission dialog)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasError) {
      // Retry location fetch when app resumes (user might have granted permission)
      _fetchLocation();
    }
  }
  
  Future<void> _fetchLocation() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _locationName = 'Konum alınıyor...';
    });
    
    try {
      final locationService = getIt<LocationService>();
      
      // For web, try multiple times with delays
      Position? position;
      
      if (kIsWeb) {
        // Web needs special handling - check permission first
        debugPrint('Web: Checking location permission...');
        final permission = await Geolocator.checkPermission();
        debugPrint('Web: Current permission status: $permission');
        
        if (permission == LocationPermission.denied) {
          debugPrint('Web: Permission denied, requesting...');
          // Request permission
          final newPermission = await Geolocator.requestPermission();
          debugPrint('Web: New permission status: $newPermission');
          if (newPermission == LocationPermission.denied || 
              newPermission == LocationPermission.deniedForever) {
            _setLocationError('Konum izni verilmedi');
            return;
          }
        } else if (permission == LocationPermission.deniedForever) {
          _setLocationError('Konum izni engellendi');
          return;
        }
        
        debugPrint('Web: Permission granted, getting position...');
        // Now try to get position with retry
        for (int i = 0; i < 3; i++) {
          try {
            debugPrint('Web: Attempt ${i + 1} to get position...');
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low, // Use low for web - faster
                timeLimit: Duration(seconds: 15), // Longer timeout
              ),
            );
            debugPrint('Web: Got position: ${position?.latitude}, ${position?.longitude}');
            if (position != null) break;
          } catch (e) {
            debugPrint('Web: Location attempt ${i + 1} failed: $e');
            if (i < 2) await Future.delayed(const Duration(seconds: 2));
          }
        }
      } else {
        // Mobile - use location service
        position = await locationService.getCurrentLocation();
      }
      
      if (position != null) {
        // Reverse geocode to get address
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final district = place.subAdministrativeArea ?? place.locality ?? '';
            final city = place.administrativeArea ?? '';
            
            if (mounted) {
              setState(() {
                _hasError = false;
                _isLoading = false;
                _locationName = district.isNotEmpty && city.isNotEmpty
                    ? '$district, $city'
                    : city.isNotEmpty
                        ? city
                        : 'Konum belirlendi';
              });
            }
            return;
          }
        } catch (e) {
          debugPrint('Geocoding failed: $e');
          // Position obtained but geocoding failed - show coordinates
          if (mounted) {
            setState(() {
              _hasError = false;
              _isLoading = false;
              _locationName = 'Konum alındı';
            });
          }
          return;
        }
      }
      
      // No position obtained
      _setLocationError('Konuma dokunarak yenile');
    } catch (e) {
      debugPrint('Location error: $e');
      _setLocationError('Konuma dokunarak yenile');
    }
  }
  
  void _setLocationError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _locationName = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final greetingKey = TimeBasedGreeting.getGreetingKey();
    
    // Get localized greeting based on time
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
        gradient: AppTheme.getHeaderGradientByTime(), // Dynamic time-based gradient
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
                  // Tappable location row for retry
                  GestureDetector(
                    onTap: _hasError || _locationName.contains('dokunarak') 
                        ? _fetchLocation 
                        : null,
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
          // Search Bar (AI Quick Access)
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
