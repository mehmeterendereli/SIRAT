import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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

class _DashboardHeaderState extends State<DashboardHeader> {
  String _locationName = 'Konum alınıyor...';
  
  // Getter for callback
  VoidCallback? get onSearchTap => widget.onSearchTap;
  
  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }
  
  Future<void> _fetchLocation() async {
    try {
      final locationService = getIt<LocationService>();
      final position = await locationService.getCurrentLocation();
      
      if (position != null) {
        // Reverse geocode to get address
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
              _locationName = district.isNotEmpty && city.isNotEmpty
                  ? '$district, $city'
                  : city.isNotEmpty
                      ? city
                      : 'Konum belirlendi';
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      if (mounted) {
        setState(() {
          _locationName = 'Konum alınamadı';
        });
      }
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
        gradient: AppTheme.headerGradient,
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
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _locationName, // NOW DYNAMIC!
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
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
