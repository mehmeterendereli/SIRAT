import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/config/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/quran_service.dart';
import '../bloc/quran_bloc.dart';

/// =============================================================================
/// QURAN PAGE - Premium Kelime Kelime Kuran Görüntüleyici
/// =============================================================================
/// 
/// React örneğinden ilham alınarak tasarlandı:
/// - Kelime kelime interaktif Arapça metin
/// - Tıklama ile anlam, kök ve çeviri
/// - Çoklu dil desteği (TR/EN/AR)
/// - Audio oynatma

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  int _selectedSurahNumber = 1;
  bool _showSurahList = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuranBloc>()..add(LoadSurahs()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: _showSurahList
            ? _SurahListView(
                onSurahSelected: (number) {
                  setState(() {
                    _selectedSurahNumber = number;
                    _showSurahList = false;
                  });
                },
              )
            : _WordByWordView(
                surahNumber: _selectedSurahNumber,
                onBack: () => setState(() => _showSurahList = true),
              ),
      ),
    );
  }
}

// =============================================================================
// SURAH LIST VIEW
// =============================================================================

class _SurahListView extends StatelessWidget {
  final Function(int) onSurahSelected;

  const _SurahListView({required this.onSurahSelected});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: AppTheme.primaryGreen,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryGreen,
                    const Color(0xFF00695C),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kuran-ı Kerim',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '114 Sure • Kelime Kelime',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Search hint
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Kelimelere tıklayarak anlamlarını öğrenebilirsiniz',
                    style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Surah list
        BlocBuilder<QuranBloc, QuranState>(
          builder: (context, state) {
            if (state is QuranLoading) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is SurahsLoaded) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _SurahCard(
                    surah: state.surahs[index],
                    onTap: () => onSurahSelected(state.surahs[index].number),
                  ),
                  childCount: state.surahs.length,
                ),
              );
            }

            if (state is QuranError) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<QuranBloc>().add(LoadSurahs()),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _SurahCard extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const _SurahCard({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Sure numarası
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGreen, const Color(0xFF00897B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Sure bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.turkishName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${surah.numberOfAyahs} ayet • ${surah.isMakki ? "Mekki" : "Medeni"}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Arapça isim
              Text(
                surah.name,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  color: AppTheme.primaryGreen,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// WORD BY WORD VIEW - Kelime Kelime Görüntüleyici
// =============================================================================

class _WordByWordView extends StatefulWidget {
  final int surahNumber;
  final VoidCallback onBack;

  const _WordByWordView({required this.surahNumber, required this.onBack});

  @override
  State<_WordByWordView> createState() => _WordByWordViewState();
}

class _WordByWordViewState extends State<_WordByWordView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentAyahIndex = 0;
  int? _selectedWordIndex;
  String _currentLanguage = 'tr';
  bool _showTranslation = true;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuranBloc>()..add(LoadSurah(widget.surahNumber)),
      child: BlocBuilder<QuranBloc, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SurahDetailLoaded) {
            return _buildContent(context, state.surah);
          }

          if (state is QuranError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SurahDetail surah) {
    final currentAyah = surah.ayahs.isNotEmpty ? surah.ayahs[_currentAyahIndex] : null;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFE0F2F1), Color(0xFFE0F7FA)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(surah),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Sure info card
                    _buildSurahInfoCard(surah),
                    const SizedBox(height: 16),

                    // Word by word Arabic
                    if (currentAyah != null) _buildWordByWordCard(currentAyah),
                    const SizedBox(height: 16),

                    // Selected word detail
                    if (_selectedWordIndex != null && currentAyah != null)
                      _buildWordDetailCard(currentAyah),

                    // Ayah navigation
                    _buildAyahNavigation(surah),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(SurahDetail surah) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: widget.onBack,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sırat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Kuran-ı Kerim', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          // Language selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _currentLanguage,
              underline: const SizedBox(),
              isDense: true,
              items: const [
                DropdownMenuItem(value: 'tr', child: Text('🇹🇷 TR')),
                DropdownMenuItem(value: 'en', child: Text('🇬🇧 EN')),
              ],
              onChanged: (v) => setState(() => _currentLanguage = v ?? 'tr'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahInfoCard(SurahDetail surah) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            surah.name,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 32,
              color: AppTheme.primaryGreen,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            '${surah.number}. Sure • ${surah.numberOfAyahs} Ayet • ${_currentAyahIndex + 1}. Ayet',
            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWordByWordCard(Ayah ayah) {
    // Kelime kelime böl
    final words = ayah.arabic.split(' ');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hint
            Text(
              '💡 Kelimelerin üzerine tıklayarak anlamlarını öğrenebilirsiniz',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Arabic words
            Wrap(
              spacing: 12,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              textDirection: TextDirection.rtl,
              children: words.asMap().entries.map((entry) {
                final index = entry.key;
                final word = entry.value;
                final isSelected = _selectedWordIndex == index;

                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedWordIndex = isSelected ? null : index;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryGreen.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 36,
                        color: isSelected ? AppTheme.primaryGreen : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Translation
            if (_showTranslation) ...[
              const SizedBox(height: 24),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MEAL', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                    onPressed: () => setState(() => _showTranslation = false),
                  ),
                ],
              ),
              Text(
                ayah.turkish,
                style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],

            if (!_showTranslation)
              TextButton(
                onPressed: () => setState(() => _showTranslation = true),
                child: Text('Meal göster', style: TextStyle(color: AppTheme.primaryGreen)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordDetailCard(Ayah ayah) {
    final words = ayah.arabic.split(' ');
    if (_selectedWordIndex! >= words.length) return const SizedBox();

    final selectedWord = words[_selectedWordIndex!];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen, const Color(0xFF00897B)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            selectedWord,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 40,
                              color: Colors.white,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.volume_up, color: Colors.white, size: 20),
                            ),
                            onPressed: () {
                              // Play audio
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.8)),
                  onPressed: () => setState(() => _selectedWordIndex = null),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Translation
                _buildDetailSection('Çeviri', _getWordMeaning(selectedWord)),

                const SizedBox(height: 16),

                // Explanation
                _buildDetailSection('Açıklama', _getWordExplanation(selectedWord)),

                const SizedBox(height: 16),

                // Root letters
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KÖK HARFLER', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(
                        _getRootLetters(selectedWord),
                        style: const TextStyle(fontFamily: 'Amiri', fontSize: 24),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }

  Widget _buildAyahNavigation(SurahDetail surah) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _currentAyahIndex > 0 ? AppTheme.primaryGreen : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: _currentAyahIndex > 0 ? Colors.white : Colors.grey),
              ),
              onPressed: _currentAyahIndex > 0
                  ? () => setState(() {
                        _currentAyahIndex--;
                        _selectedWordIndex = null;
                      })
                  : null,
            ),
            Column(
              children: [
                Text('Ayet', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text(
                  '${_currentAyahIndex + 1} / ${surah.numberOfAyahs}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _currentAyahIndex < surah.ayahs.length - 1 ? AppTheme.primaryGreen : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward, color: _currentAyahIndex < surah.ayahs.length - 1 ? Colors.white : Colors.grey),
              ),
              onPressed: _currentAyahIndex < surah.ayahs.length - 1
                  ? () => setState(() {
                        _currentAyahIndex++;
                        _selectedWordIndex = null;
                      })
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions for word meanings (example data)
  String _getWordMeaning(String word) {
    final meanings = {
      'بِسْمِ': 'adıyla',
      'ٱللَّهِ': 'Allah\'ın',
      'ٱلرَّحْمَٰنِ': 'Rahman olan',
      'ٱلرَّحِيمِ': 'Rahim olan',
      'ٱلْحَمْدُ': 'Hamd',
      'لِلَّهِ': 'Allah\'a mahsustur',
      'رَبِّ': 'Rabbi',
      'ٱلْعَٰلَمِينَ': 'âlemlerin',
    };
    return meanings[word] ?? 'Anlam bilgisi yükleniyor...';
  }

  String _getWordExplanation(String word) {
    final explanations = {
      'بِسْمِ': 'İsim, ad anlamına gelir. "Bi" ön eki "ile/adıyla" anlamını verir.',
      'ٱللَّهِ': 'Allah, İslam\'da tek tanrının özel ismidir. Tüm güzel isimlerin sahibidir.',
      'ٱلرَّحْمَٰنِ': 'Sonsuz merhamet sahibi. Tüm yaratılmışlara merhamet eden.',
      'ٱلرَّحِيمِ': 'Çok merhametli. Özellikle müminlere özel merhamet gösteren.',
      'ٱلْحَمْدُ': 'Hamd, şükür ve övgü anlamlarını içerir.',
      'لِلَّهِ': '"Li" ön eki "için/a mahsus" anlamındadır. Allah\'a aittir.',
      'رَبِّ': 'Rab, terbiye eden, yetiştiren, idare eden anlamlarını taşır.',
      'ٱلْعَٰلَمِينَ': 'Âlem kelimesinin çoğulu. Tüm varlıklar, evrenler demektir.',
    };
    return explanations[word] ?? 'Detaylı açıklama için lütfen bekleyin...';
  }

  String _getRootLetters(String word) {
    final roots = {
      'بِسْمِ': 'س م و',
      'ٱللَّهِ': 'ا ل ه',
      'ٱلرَّحْمَٰنِ': 'ر ح م',
      'ٱلرَّحِيمِ': 'ر ح م',
      'ٱلْحَمْدُ': 'ح م د',
      'لِلَّهِ': 'ا ل ه',
      'رَبِّ': 'ر ب ب',
      'ٱلْعَٰلَمِينَ': 'ع ل م',
    };
    return roots[word] ?? '...';
  }
}
