import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '6cf2fd39b6b0054cdb958917a6ca80f9';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  static String getImageUrl(String path) => '$_imageBaseUrl/w500$path';

  Future<Map<String, dynamic>> getTrendingMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/trending/movie/week?api_key=$_apiKey'),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getGenres() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey'),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'),
    );
    return json.decode(response.body);
  }
} 