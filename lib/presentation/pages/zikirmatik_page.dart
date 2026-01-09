import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/injection.dart';
import '../../core/services/zikirmatik_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Zikirmatik Sayfası
/// Akıllı sayaç, titreşim profilleri ve rozet sistemi ile gamification destekli.

class ZikirmatikPage extends StatefulWidget {
  const ZikirmatikPage({super.key});

  @override
  State<ZikirmatikPage> createState() => _ZikirmatikPageState();
}

class _ZikirmatikPageState extends State<ZikirmatikPage> with SingleTickerProviderStateMixin {
  final ZikirmatikService _service = getIt<ZikirmatikService>();
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  ZikirType _selectedZikir = ZikirmatikService.defaultZikirs[0];
  int _count = 0;
  String? _lastBadge;
  bool _showBadgeAnimation = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() async {
    // Animasyon
    _pulseController.forward().then((_) => _pulseController.reverse());
    
    // Zikir artır
    final result = await _service.incrementZikir(_selectedZikir.id, _count);
    
    setState(() {
      _count = result.count;
      
      // Rozet kazanıldıysa göster
      if (result.earnedBadge != null) {
        _lastBadge = result.earnedBadge;
        _showBadgeAnimation = true;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showBadgeAnimation = false);
        });
      }
    });
  }

  void _resetCounter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sayacı Sıfırla'),
        content: const Text('Sayaç sıfırlanacak. Toplam sayınız bulutta korunacaktır.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              _service.resetZikir(_selectedZikir.id);
              setState(() => _count = 0);
              Navigator.pop(context);
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final progress = _count / _selectedZikir.target;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zikirmatik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCounter,
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _showZikirSelector(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ana içerik
          GestureDetector(
            onTap: _onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    AppTheme.primaryGreen.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Arapça metin
                    Text(
                      _selectedZikir.arabic,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 40,
                        height: 1.8,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Latince metin
                    Text(
                      _selectedZikir.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Büyük sayaç
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$_count',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Hedef göstergesi
                    Text(
                      'Hedef: ${_selectedZikir.target}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // İlerleme çubuğu
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.green : AppTheme.gold,
                          ),
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // İpucu
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Ekranın herhangi bir yerine dokunarak zikir çekin',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Rozet animasyonu
          if (_showBadgeAnimation && _lastBadge != null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🎉',
                            style: TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tebrikler!',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _lastBadge!,
                            style: TextStyle(fontSize: 20, color: AppTheme.gold),
                          ),
                          const SizedBox(height: 8),
                          const Text('Rozeti Kazandın'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showZikirSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: ZikirmatikService.defaultZikirs.length,
        itemBuilder: (context, index) {
          final zikir = ZikirmatikService.defaultZikirs[index];
          final isSelected = zikir.id == _selectedZikir.id;
          
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  '${zikir.target}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(zikir.name),
            subtitle: Text(zikir.arabic, style: const TextStyle(fontFamily: 'Amiri')),
            trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryGreen) : null,
            onTap: () {
              setState(() {
                _selectedZikir = zikir;
                _count = 0; // Yeni zikir seçildiğinde sıfırla
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
