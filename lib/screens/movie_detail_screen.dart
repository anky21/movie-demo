import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String? _trailerUrl;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
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
          _trailerUrl = 'https://www.youtube.com/watch?v=$trailerKey';
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

  Future<void> _openTrailer() async {
    if (_trailerUrl != null) {
      final Uri url = Uri.parse(_trailerUrl!);
      try {
        // First try to launch in YouTube app
        final youtubeAppUrl = Uri.parse('youtube://${url.host}${url.path}?${url.query}');
        if (await canLaunchUrl(youtubeAppUrl)) {
          await launchUrl(youtubeAppUrl);
        } else {
          // Fallback to browser
          if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open trailer')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open trailer')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 400,
                      pinned: true,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
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
                            if (_trailerUrl != null)
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: FloatingActionButton(
                                  onPressed: _openTrailer,
                                  backgroundColor: Colors.red,
                                  child: const Icon(Icons.play_arrow),
                                ),
                              ),
                          ],
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
} 