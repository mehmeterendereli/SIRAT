import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../core/config/injection.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/location_service.dart';
import '../../data/repositories/user_preferences_repository.dart';
import 'home_page.dart';

/// Onboarding Page (Bölüm 2.1)
/// Handles Language, Mezhep, Location Permission, and Notification Permission flows.
/// 5-step onboarding with premium UX.

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 5;

  String _selectedLanguage = 'tr';
  int _selectedMezhep = 1; // Default: Hanafi
  int _selectedMethod = 13; // Default: Diyanet Turkey (Method 13)
  
  // Permission states
  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logOnboardingStart();
    _checkExistingPermissions();
  }

  Future<void> _checkExistingPermissions() async {
    final locationStatus = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;
    
    setState(() {
      _locationGranted = locationStatus.isGranted;
      _notificationGranted = notificationStatus.isGranted;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isRequestingPermission = true);
    
    try {
      final status = await Permission.location.request();
      setState(() {
        _locationGranted = status.isGranted;
        _isRequestingPermission = false;
      });
      
      if (status.isGranted) {
        // Initialize location service with timeout for web
        try {
          await getIt<LocationService>()
              .getCurrentLocation()
              .timeout(const Duration(seconds: 5));
          getIt<AnalyticsService>().logEvent(name: 'location_permission_granted');
        } catch (e) {
          // Location fetch failed but we continue - fallback will be used
          debugPrint('Location fetch failed: $e - Using fallback coordinates');
        }
      } else {
        getIt<AnalyticsService>().logEvent(name: 'location_permission_denied');
      }
      
      _nextPage();
    } catch (e) {
      debugPrint('Location permission error: $e');
      setState(() => _isRequestingPermission = false);
      _nextPage();
    }
  }

  Future<void> _requestNotificationPermission() async {
    setState(() => _isRequestingPermission = true);
    
    try {
      final status = await Permission.notification.request();
      setState(() {
        _notificationGranted = status.isGranted;
        _isRequestingPermission = false;
      });
      
      if (status.isGranted) {
        getIt<AnalyticsService>().logEvent(name: 'notification_permission_granted');
      } else {
        getIt<AnalyticsService>().logEvent(name: 'notification_permission_denied');
      }
      
      _nextPage();
    } catch (e) {
      setState(() => _isRequestingPermission = false);
      _nextPage();
    }
  }

  Future<void> _finishOnboarding() async {
    final repo = getIt<UserPreferencesRepository>();
    await repo.saveLanguage(_selectedLanguage);
    await repo.saveMezhep(_selectedMezhep);
    await repo.saveCalculationMethod(_selectedMethod);
    await repo.setOnboardingComplete(true);
    
    getIt<AnalyticsService>().logEvent(name: 'onboarding_complete', parameters: {
      'language': _selectedLanguage,
      'mezhep': _selectedMezhep.toString(),
      'location_granted': _locationGranted.toString(),
      'notification_granted': _notificationGranted.toString(),
    });

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe for permission pages
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _buildLanguageStep(),
              _buildMezhepStep(),
              _buildCalcMethodStep(),
              _buildLocationPermissionStep(),
              _buildNotificationPermissionStep(),
            ],
          ),
          _buildTopIndicator(),
          if (_currentPage < 3) _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTopIndicator() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: _currentPage == index ? 24 : 8,
            decoration: BoxDecoration(
              color: _currentPage == index ? AppTheme.primaryGreen : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Devam Et'),
      ),
    );
  }

  // --- Step Builders ---

  Widget _buildLanguageStep() {
    return _buildBaseStep(
      title: 'Diline Hoş Geldin',
      subtitle: 'SIRAT seninle kendi dilinde konuşacak.',
      icon: Icons.language_rounded,
      child: Column(
        children: AppConfig.supportedLocales.map((code) {
          final name = code == 'tr' ? 'Türkçe' : code == 'en' ? 'English' : code == 'ar' ? 'العربية' : code;
          return _buildRadioItem(
            title: name,
            subtitle: code.toUpperCase(),
            isSelected: _selectedLanguage == code,
            onTap: () => setState(() => _selectedLanguage = code),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMezhepStep() {
    return _buildBaseStep(
      title: 'Mezhep Seçimi',
      subtitle: 'Namaz vakitleri ve fetvalar buna göre ayarlanacak.',
      icon: Icons.menu_book_rounded,
      child: Column(
        children: AppConfig.madhabs.entries.map((entry) {
          return _buildRadioItem(
            title: entry.value,
            subtitle: entry.key == 1 ? 'Türkiye Geneli' : '',
            isSelected: _selectedMezhep == entry.key,
            onTap: () => setState(() => _selectedMezhep = entry.key),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalcMethodStep() {
    return _buildBaseStep(
      title: 'Vakit Metodu',
      subtitle: 'Konumuna göre en hassas hesaplama yöntemini seç.',
      icon: Icons.access_time_filled_rounded,
      child: Column(
        children: [
          _buildRadioItem(
            title: 'Diyanet İşleri Başkanlığı',
            subtitle: 'Türkiye için standart (Önerilen)',
            isSelected: _selectedMethod == 13,
            onTap: () => setState(() => _selectedMethod = 13),
          ),
          _buildRadioItem(
            title: 'ISNA (Kuzey Amerika)',
            subtitle: 'Alternatif hesaplama',
            isSelected: _selectedMethod == 2,
            onTap: () => setState(() => _selectedMethod = 2),
          ),
          _buildRadioItem(
            title: 'Muslim World League',
            subtitle: 'Uluslararası standart',
            isSelected: _selectedMethod == 3,
            onTap: () => setState(() => _selectedMethod = 3),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPermissionStep() {
    return _buildBaseStep(
      title: 'Konum İzni',
      subtitle: 'Sana en yakın camiyi bulmak ve doğru kıble yönünü göstermek için konumuna ihtiyacımız var.',
      icon: Icons.location_on_rounded,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, size: 60, color: Colors.orange),
          ),
          const SizedBox(height: 32),
          if (_locationGranted) ...[
            _buildPermissionGrantedBadge('Konum izni verildi'),
            const SizedBox(height: 24),
            // Continue button after permission granted
            ElevatedButton.icon(
              onPressed: _nextPage,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Devam Et'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ] else
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isRequestingPermission ? null : _requestLocationPermission,
                  icon: _isRequestingPermission 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check),
                  label: Text(_isRequestingPermission ? 'İzin İsteniyor...' : 'Konum İzni Ver'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isRequestingPermission ? null : _nextPage,
                  child: const Text('Şimdilik Atla', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationPermissionStep() {
    return _buildBaseStep(
      title: 'Bildirim İzni',
      subtitle: 'Namaz vakitlerini kaçırmamanız için seni vaktinde uyandıralım!',
      icon: Icons.notifications_active_rounded,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_rounded, size: 60, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ezan vakti geldiğinde seni hemen bilgilendireceğiz.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 32),
          if (_notificationGranted)
            _buildPermissionGrantedBadge('Bildirim izni verildi')
          else
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isRequestingPermission ? null : _requestNotificationPermission,
                  icon: _isRequestingPermission 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.notifications_active),
                  label: Text(_isRequestingPermission ? 'İzin İsteniyor...' : 'Bildirimleri Aç'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isRequestingPermission ? null : _finishOnboarding,
                  child: const Text('Şimdilik Atla', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          if (_notificationGranted) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _finishOnboarding,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Hadi Başlayalım'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionGrantedBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: AppTheme.primaryGreen),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 48),
          child,
        ],
      ),
    );
  }

  Widget _buildRadioItem({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppTheme.primaryGreen : Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen),
            ],
          ),
        ),
      ),
    );
  }
}
