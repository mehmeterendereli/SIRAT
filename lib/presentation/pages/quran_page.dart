import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/config/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/quran_service.dart';
import '../bloc/quran_bloc.dart';

/// =============================================================================
/// QURAN PAGE - Premium Kuran-ı Kerim Arayüzü
/// =============================================================================

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuranBloc>()..add(LoadSurahs()),
      child: const _QuranPageContent(),
    );
  }
}

class _QuranPageContent extends StatefulWidget {
  const _QuranPageContent();

  @override
  State<_QuranPageContent> createState() => _QuranPageContentState();
}

class _QuranPageContentState extends State<_QuranPageContent> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.teal,
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
                        const Text(
                          'Kuran-ı Kerim',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '114 Sure',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Leading removed to work as a tab or sub-page
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _showSearchDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () {
                  // TODO: Bookmark listesi
                },
              ),
            ],
          ),
          
          // Content
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
                    (context, index) => _SurahListItem(
                      surah: state.surahs[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahDetailPage(
                            surahNumber: state.surahs[index].number,
                          ),
                        ),
                      ),
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
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
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
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kuran\'da Ara'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Arama...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            Navigator.pop(ctx);
            _performSearch(context, query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performSearch(context, _searchController.text);
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  void _performSearch(BuildContext context, String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(query: query),
      ),
    );
  }
}

// =============================================================================
// SURAH LIST ITEM
// =============================================================================

class _SurahListItem extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const _SurahListItem({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Sure numarası
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arapça isim
              Text(
                surah.name,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
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
// SURAH DETAIL PAGE
// =============================================================================

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;

  const SurahDetailPage({super.key, required this.surahNumber});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  // ignore: unused_field
  int? _currentPlayingIndex;
  bool _isPlayerReady = false;
  // Removed unused _ayahs field

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Listen to playback state to update UI
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {});
      }
    });

    // Listen to current item index to update highlighted ayah
    _audioPlayer.currentIndexStream.listen((index) {
      if (mounted && index != null) {
        setState(() {
          _currentPlayingIndex = index;
        });
        // Auto-scroll logic could be added here
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initPlaylist(List<Ayah> ayahs) async {
    if (_isPlayerReady || ayahs.isEmpty) return;

    try {
      final audioSources = ayahs
          .where((a) => a.audioUrl != null)
          .map((a) => AudioSource.uri(Uri.parse(a.audioUrl!)))
          .toList();

      if (audioSources.isEmpty) return;

      final playlist = ConcatenatingAudioSource(children: audioSources);
      
      // Preload the playlist but don't auto-play yet
      await _audioPlayer.setAudioSource(
        playlist, 
        initialIndex: 0, 
        preload: false
      );
      
      _ayahs = ayahs;
      _isPlayerReady = true;
    } catch (e) {
      debugPrint('Error initializing playlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuranBloc>()..add(LoadSurah(widget.surahNumber)),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: BlocConsumer<QuranBloc, QuranState>(
          listener: (context, state) {
            if (state is SurahDetailLoaded && !_isPlayerReady) {
              _initPlaylist(state.surah.ayahs);
            }
          },
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
        floatingActionButton: _buildFab(),
      ),
    );
  }

  Widget _buildFab() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        
        final isLoading = processingState == ProcessingState.loading || 
                          processingState == ProcessingState.buffering;
        
        // Define isPlaying for UI
        final isPlaying = playing == true && processingState != ProcessingState.completed;

        if (isLoading) {
           return FloatingActionButton(
            backgroundColor: AppTheme.primaryGreen,
            child: const CircularProgressIndicator(color: Colors.white),
            onPressed: () => _audioPlayer.stop(),
          );
        }

        return FloatingActionButton.extended(
          backgroundColor: AppTheme.primaryGreen,
          onPressed: () {
            if (isPlaying) {
              _audioPlayer.pause();
            } else {
              // If completed, seek to start
              if (processingState == ProcessingState.completed) {
                _audioPlayer.seek(Duration.zero, index: 0);
              }
              _audioPlayer.play();
            }
          },
          label: Text(isPlaying ? 'Duraklat' : 'Tümünü Oku'),
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SurahDetail surah) {
    // Current playing index from player
    final currentIndex = _audioPlayer.currentIndex;
    final isPlaying = _audioPlayer.playing;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppTheme.primaryGreen,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryGreen,
                    AppTheme.teal.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        surah.name,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 36,
                          color: Colors.white,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${surah.numberOfAyahs} Ayet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        
        if (surah.number != 1 && surah.number != 9)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: const Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 28,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Highlight if this index matches player index
              final isCurrentAyah = currentIndex == index;
              
              return _AyahCard(
                ayah: surah.ayahs[index],
                surahNumber: surah.number,
                // Only show "playing" state (green border) if it's the current ayah AND player is actually playing/loading
                isPlaying: isCurrentAyah && (isPlaying || _audioPlayer.processingState == ProcessingState.buffering),
                
                // Play specific ayah
                onPlay: () async {
                   await _audioPlayer.seek(Duration.zero, index: index);
                   _audioPlayer.play();
                },
                
                // Pause
                onPause: () => _audioPlayer.pause(),
              );
            },
            childCount: surah.ayahs.length,
          ),
        ),
        
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

// =============================================================================
// AYAH CARD
// =============================================================================

class _AyahCard extends StatelessWidget {
  final Ayah ayah;
  final int surahNumber;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  const _AyahCard({
    required this.ayah,
    required this.surahNumber,
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPlaying 
            ? BorderSide(color: AppTheme.primaryGreen, width: 2)
            : BorderSide.none,
      ),
      color: isPlaying ? AppTheme.primaryGreen.withValues(alpha: 0.05) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header (Ayet numarası + actions)
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${ayah.number}',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Play/Pause button
                if (ayah.audioUrl != null)
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: AppTheme.primaryGreen,
                      size: 36,
                    ),
                    onPressed: isPlaying ? onPause : onPlay,
                  ),
                IconButton(
                  icon: Icon(Icons.bookmark_border, color: Colors.grey[400]),
                  onPressed: () {
                    // Toggle bookmark
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Colors.grey[400]),
                  onPressed: () {
                    // Share ayah
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Arabic text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ayah.arabic,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 26,
                  height: 2,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Turkish translation
            Text(
              ayah.turkish,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Metadata
            Row(
              children: [
                _MetadataChip(icon: Icons.menu_book, label: 'Sayfa ${ayah.page}'),
                const SizedBox(width: 8),
                _MetadataChip(icon: Icons.auto_stories, label: 'Cüz ${ayah.juz}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetadataChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SEARCH RESULTS PAGE
// =============================================================================

class SearchResultsPage extends StatelessWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuranBloc>()..add(SearchQuran(query)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Arama: "$query"'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<QuranBloc, QuranState>(
          builder: (context, state) {
            if (state is QuranLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is SearchResultsLoaded) {
              if (state.results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Sonuç bulunamadı',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.results.length,
                itemBuilder: (context, index) {
                  final result = state.results[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        result.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${result.surahName} - Ayet ${result.ayahNumber}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahDetailPage(
                              surahNumber: result.surahNumber,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
            
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
