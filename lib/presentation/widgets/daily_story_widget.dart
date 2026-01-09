import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Daily Story Widget
/// Instagram-style circle for daily verse/hadith/dua.

class DailyStoryWidget extends StatelessWidget {
  const DailyStoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          final titles = ['Günün Ayeti', 'Günün Hadisi', 'Günün Duası', 'Günün İsmi', 'Günün Sünneti'];
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
                      child: Icon(
                        index == 0 ? Icons.menu_book_rounded : Icons.star_border_rounded,
                        color: AppTheme.primaryGreen,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  titles[index],
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
