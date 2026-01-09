import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../core/config/injection.dart';
import '../../core/services/analytics_service.dart';
import '../../data/repositories/user_preferences_repository.dart';
import 'home_page.dart';

/// Onboarding Page (Bölüm 2.1)
/// Handles Language, Mezhep, and Permission flows with premium UX.

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _selectedLanguage = 'tr';
  int _selectedMezhep = 1; // Default: Hanafi
  int _selectedMethod = 13; // Default: Diyanet Turkey (Method 13 - correct one)

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logOnboardingStart();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final repo = getIt<UserPreferencesRepository>();
    await repo.saveLanguage(_selectedLanguage);
    await repo.saveMezhep(_selectedMezhep);
    await repo.saveCalculationMethod(_selectedMethod);
    await repo.setOnboardingComplete(true);

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
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _buildLanguageStep(),
              _buildMezhepStep(),
              _buildCalcMethodStep(),
              _buildPermissionStep(),
            ],
          ),
          _buildTopIndicator(),
          _buildBottomButton(),
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
        children: List.generate(4, (index) {
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
        child: Text(_currentPage == 3 ? 'Hadi Başlayalım' : 'Devam Et'),
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

  Widget _buildPermissionStep() {
    return _buildBaseStep(
      title: 'Neredeyse Hazırız',
      subtitle: 'Sana en yakın camiyi ve tam kıble yönünü göstermek için konuma, vaktinde uyanman için bildirimlere ihtiyacımız var.',
      icon: Icons.security_rounded,
      child: Column(
        children: [
          const Icon(Icons.location_on_rounded, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Konum ve bildirim izni vererek manevi yolculuğuna başlayabilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5, color: Colors.grey),
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
