import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/injection.dart';
import '../../core/services/daily_content_service.dart';

/// Daily Story Widget (Dynamic Version)
/// Shows placeholder if Firestore has no data, no infinite spinner.

class DailyStoryWidget extends StatelessWidget {
  const DailyStoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: StreamBuilder<QuerySnapshot>(
        stream: getIt<DailyContentService>().getDailyStoriesStream(),
        builder: (context, snapshot) {
          // Show placeholder items while loading or if empty
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildPlaceholder(context);
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Show default content instead of spinner
            return _buildDefaultContent(context);
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

  /// Placeholder while loading from Firestore
  Widget _buildPlaceholder(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Default content when Firestore has no data
  Widget _buildDefaultContent(BuildContext context) {
    final defaultItems = [
      {'title': 'Ayetin Ayet', 'icon': Icons.menu_book_rounded},
      {'title': 'Günün Hadisi', 'icon': Icons.star_rounded},
      {'title': 'Dua', 'icon': Icons.favorite_rounded},
      {'title': 'Bilgi', 'icon': Icons.lightbulb_rounded},
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: defaultItems.length,
      itemBuilder: (context, index) {
        final item = defaultItems[index];
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
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item['title']} yakında eklenecek')),
                        );
                      },
                      child: Icon(
                        item['icon'] as IconData,
                        color: AppTheme.primaryGreen,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'] as String,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
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
