import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/injection.dart';
import '../../core/services/remote_config_service.dart';
import '../bloc/prayer_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/dynamic_sky/dynamic_prayer_header.dart';
import '../widgets/daily_story_widget.dart';
import '../widgets/premium_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'qibla_page.dart';
import 'zikirmatik_page.dart';
import 'islam_ai_page.dart';
import 'quran_page.dart';
import 'settings_page.dart';

/// HomePage (Dashboard) with Time-Aware visuals
/// Assembles all components into a scrollable view.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;

  void _goToAIPage() {
    setState(() => _currentNavIndex = 3); // İslam-AI index (now 3)
  }

  List<Widget> get _pages => [
    _HomeContent(onSearchTap: _goToAIPage),
    const QuranPage(),
    const QiblaPage(),
    const IslamAIPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PrayerBloc>()..add(FetchPrayerTimes()),
      child: Scaffold(
        body: IndexedStack(
          index: _currentNavIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return FloatingBottomNav(
      currentIndex: _currentNavIndex,
      onTap: (index) => setState(() => _currentNavIndex = index),
      items: const [
        FloatingNavItem(
          icon: Icons.home_rounded,
          label: 'Ana Sayfa',
          activeColor: Color(0xFF1B5E20),
        ),
        FloatingNavItem(
          icon: Icons.menu_book_rounded,
          label: 'Kuran',
          activeColor: AppTheme.primaryGreen,
        ),
        FloatingNavItem(
          icon: Icons.explore_rounded,
          label: 'Kıble',
          activeColor: Color(0xFFFF6F00),
        ),
        FloatingNavItem(
          icon: Icons.psychology_rounded,
          label: 'İslam-AI',
          activeColor: Color(0xFF6A1B9A),
        ),
        FloatingNavItem(
          icon: Icons.settings_rounded,
          label: 'Ayarlar',
          activeColor: Color(0xFF00796B),
        ),
      ],
    );
  }
}

/// Home Content - Ana sayfa içeriği
class _HomeContent extends StatelessWidget {
  final VoidCallback? onSearchTap;
  
  const _HomeContent({this.onSearchTap});

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Dynamic Prayer Header (Apple Weather Quality)
          // Replaces both DashboardHeader and NextPrayerCard
          DynamicPrayerHeader(onSearchTap: onSearchTap),
          
          // 2. Daily Stories
          const SizedBox(height: 24),
          const DailyStoryWidget(),
          
          // 3. Quick Actions Grid
          _buildQuickActions(context),
          
          // 4. Daily Insight Card
          _buildAIInsightCard(context),
          
          const SizedBox(height: 100), // Bottom padding for Nav Bar
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    
    // Build action items list dynamically
    final actionItems = <Widget>[
      // Zikirmatik (Her zaman açık)
      _buildActionItem(context, loc.zikirmatik, Icons.touch_app_rounded, AppTheme.emerald, () {
        _navigateToPage(context, const ZikirmatikPage());
      }),

      // Cami Bulucu (Future Feature)
      if (getIt<RemoteConfigService>().getBool('feature_show_mosque_finder'))
        _buildActionItem(context, 'Cami Bul', Icons.mosque_rounded, Colors.blue, () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yakında...')));
        }),

      // Kıble
      if (getIt<RemoteConfigService>().getBool('feature_show_ar_qibla'))
        _buildActionItem(context, loc.qiblaFinder, Icons.explore_rounded, Colors.orange, () {
          _navigateToPage(context, const QiblaPage());
        }),

      // İslam AI
      _buildActionItem(context, 'İslam AI', Icons.psychology_rounded, const Color(0xFF6A1B9A), () {
        _navigateToPage(context, const IslamAIPage());
      }),

      // Ayarlar
      _buildActionItem(context, loc.settings_title, Icons.settings_rounded, const Color(0xFF00796B), () {
        _navigateToPage(context, const SettingsPage());
      }),
    ];
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.quickActions,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : null,
            ),
          ),
          const SizedBox(height: 16),
          // LayoutBuilder for responsive grid
          LayoutBuilder(
            builder: (context, constraints) {
              final gridWidth = constraints.maxWidth;
              const spacing = 12.0;
              final itemWidth = (gridWidth - spacing) / 2;
              // Dynamic aspect ratio based on available width
              final itemHeight = (itemWidth / 1.6).clamp(60.0, 90.0);
              
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: actionItems.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: item,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final iconSize = isSmallScreen ? 24.0 : 30.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 20),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: iconSize),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIInsightCard(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('daily_content').doc('ai_insight').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final content = data['content'] ?? '...';

        return Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF4527A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          loc.aiSuggestion,
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6A1B9A),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      child: Text(loc.ok),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.psychology, size: 80, color: Colors.white24),
            ],
          ),
        );
      },
    );
  }
}
