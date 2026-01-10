import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/injection.dart';
import '../bloc/prayer_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/daily_story_widget.dart';
import '../widgets/next_prayer_card.dart';
import '../../l10n/app_localizations.dart';
import 'qibla_page.dart';
import 'zikirmatik_page.dart';
import 'islam_ai_page.dart';
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
    setState(() => _currentNavIndex = 2); // İslam-AI index
  }

  List<Widget> get _pages => [
    _HomeContent(onSearchTap: _goToAIPage),
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
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Ana Sayfa'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Kıble'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_rounded), label: 'İslam-AI'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ayarlar'),
          ],
        ),
      ),
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
          // 1. Dynamic Header with search tap
          DashboardHeader(onSearchTap: onSearchTap),
          
          // 2. Daily Stories
          const SizedBox(height: 24),
          const DailyStoryWidget(),
          
          // 3. Next Prayer Card
          const NextPrayerCard(),
          
          // 4. Quick Actions Grid
          _buildQuickActions(context),
          
          // 5. Daily Insight Card
          _buildAIInsightCard(context),
          
          const SizedBox(height: 100), // Bottom padding for Nav Bar
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.quickActions,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildActionItem(context, loc.zikirmatik, Icons.touch_app_rounded, AppTheme.emerald, () {
                _navigateToPage(context, const ZikirmatikPage());
              }),
              _buildActionItem(context, loc.qiblaFinder, Icons.explore_rounded, Colors.orange, () {
                _navigateToPage(context, const QiblaPage());
              }),
              _buildActionItem(context, loc.readQuran, Icons.auto_stories_rounded, Colors.blue, () {
                // TODO: Kuran sayfası
              }),
              _buildActionItem(context, loc.findMosque, Icons.location_on_rounded, Colors.redAccent, () {
                // TODO: Cami bulucu
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
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
