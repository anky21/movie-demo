import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_service.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TMDBService _tmdbService = TMDBService();
  final ScrollController _scrollController = ScrollController();
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  bool _isLoading = true;
  Timer? _autoScrollTimer;
  String? _errorMessage;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _setupAutoScroll();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _setupAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        final double currentPosition = _scrollController.offset;
        final double maxScrollExtent = _scrollController.position.maxScrollExtent;
        
        if (currentPosition >= maxScrollExtent) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.animateTo(
            currentPosition + 208.0, // cardWidth(200) + horizontal margin(8)
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  void _loadBannerAd() {
    _bannerAd = AdsService.createBannerAd()
      ..load().then((value) {
        setState(() {
          _isBannerAdReady = true;
        });
      });
  }

  Future<void> _loadMovies() async {
    try {
      final trendingResponse = await _tmdbService.getTrendingMovies();
      final popularResponse = await _tmdbService.getPopularMovies();

      setState(() {
        _trendingMovies = (trendingResponse['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
        _popularMovies = (popularResponse['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load movies';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Movies',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)))
                    : CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                                  child: Text(
                                    'Trending Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 340,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    itemCount: _trendingMovies.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MovieDetailScreen(
                                                movie: _trendingMovies[index],
                                              ),
                                            ),
                                          );
                                        },
                                        child: MovieCard(
                                          movie: _trendingMovies[index],
                                          isLarge: true,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                              child: Row(
                                children: const [
                                  Text(
                                    'Popular Movies',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.all(8),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MovieDetailScreen(
                                            movie: _popularMovies[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: MovieCard(
                                      movie: _popularMovies[index],
                                      isLarge: false,
                                    ),
                                  );
                                },
                                childCount: _popularMovies.length,
                              ),
                            ),
                          ),
                          // Add padding at the bottom for the banner ad
                          SliverToBoxAdapter(
                            child: SizedBox(height: _bannerAd?.size.height.toDouble() ?? 0),
                          ),
                        ],
                      ),
            // Banner ad at the bottom
            AdsService.buildBannerAdWidget(_bannerAd, _isBannerAdReady),
          ],
        ),
      ),
    );
  }
} 