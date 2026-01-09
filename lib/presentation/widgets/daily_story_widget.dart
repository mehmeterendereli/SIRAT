import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/injection.dart';
import '../../core/services/daily_content_service.dart';

/// Daily Story Widget (Dynamic Version)
/// Fetches real stories from Firestore to avoid mock data.

class DailyStoryWidget extends StatelessWidget {
  const DailyStoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: StreamBuilder<QuerySnapshot>(
        stream: getIt<DailyContentService>().getDailyStoriesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Placeholder while loading or if empty (Shimmer handled elsewhere usually)
            return const Center(child: CircularProgressIndicator());
          }

          final stories = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final data = stories[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '...';
              final iconCode = data['icon_code'] ?? 'star';
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: index == 0 ? AppTheme.goldGradient : const LinearGradient(colors: [Colors.grey, Colors.blueGrey]),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: InkWell(
                            onTap: () => _showStoryDetail(context, data),
                            child: Icon(
                              _getIconData(iconCode),
                              color: AppTheme.primaryGreen,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showStoryDetail(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(data['title'] ?? '', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: Text(data['content'] ?? '', style: const TextStyle(fontSize: 16, height: 1.6)))),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String code) {
    switch (code) {
      case 'book': return Icons.menu_book_rounded;
      case 'star': return Icons.star_rounded;
      case 'favorite': return Icons.favorite_rounded;
      case 'lightbulb': return Icons.lightbulb_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}
