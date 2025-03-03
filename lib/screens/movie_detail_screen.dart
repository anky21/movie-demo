import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_service.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TMDBService _tmdbService = TMDBService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _movieDetails;
  String? _trailerKey;
  YoutubePlayerController? _youtubeController;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _youtubeController?.close();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = AdsService.createBannerAd()
      ..load().then((value) {
        setState(() {
          _isBannerAdReady = true;
        });
      });
  }

  Future<void> _loadMovieDetails() async {
    try {
      final details = await _tmdbService.getMovieDetails(widget.movie.id);
      final videos = await _tmdbService.getMovieVideos(widget.movie.id);
      
      String? trailerKey;
      if (videos['results'] != null && (videos['results'] as List).isNotEmpty) {
        final trailers = (videos['results'] as List)
            .where((video) => 
                video['type'] == 'Trailer' && 
                video['site'] == 'YouTube')
            .toList();
        
        if (trailers.isNotEmpty) {
          trailerKey = trailers.first['key'];
          if (trailerKey != null) {
            _trailerKey = trailerKey;
            _initializeYoutubePlayer(trailerKey);
          }
        }
      }

      setState(() {
        _movieDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load movie details';
        _isLoading = false;
      });
    }
  }

  void _initializeYoutubePlayer(String videoId) {
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)))
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: _trailerKey != null ? 300 : 400,
                          pinned: true,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: _trailerKey != null && _youtubeController != null
                                ? YoutubePlayer(
                                    controller: _youtubeController!,
                                    aspectRatio: 16 / 9,
                                  )
                                : Image.network(
                                    TMDBService.getImageUrl(widget.movie.backdropPath ?? widget.movie.posterPath),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[900],
                                        child: const Center(
                                          child: Icon(Icons.error_outline, color: Colors.white, size: 48),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.movie.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.movie.voteAverage.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      _movieDetails?['release_date']?.substring(0, 4) ?? '',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Overview',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.movie.overview,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                if (_movieDetails?['genres'] != null) ...[
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (_movieDetails!['genres'] as List)
                                        .map((genre) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                genre['name'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                                // Add padding at the bottom for the banner ad
                                SizedBox(height: _bannerAd?.size.height.toDouble() ?? 0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
          // Banner ad at the bottom
          AdsService.buildBannerAdWidget(_bannerAd, _isBannerAdReady),
        ],
      ),
    );
  }
} 