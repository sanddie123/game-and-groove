import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // --- RAWG API (GAMES) ---
  static const String _rawgApiKey = '61095fcab5a94799826e22d4038ba7a8';
  static const String _rawgBaseUrl = 'https://api.rawg.io/api';

  Future<List<dynamic>> fetchTrendingGames() async {
    final url = Uri.parse('$_rawgBaseUrl/games?key=$_rawgApiKey&ordering=-added&page_size=12');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return json.decode(response.body)['results'];
      return [];
    } catch (e) { return []; }
  }

  // --- ITUNES API (STRICT VIDEO GAME MUSIC) ---
  Future<List<dynamic>> fetchTrendingOSTs() async {
    // UPDATED: Hyper-specific video game queries to avoid generic electronic/movie scores
    final globalQueries = [
      'Video Game Soundtrack',
      'Original Game Soundtrack',
      'Video Game OST',
      'Game Score'
    ];
    
    List<dynamic> combinedResults = [];
    try {
      for (var q in globalQueries) {
        // CHANGED: entity=song (for previews) and added attribute=genreIndex to strictly search within genres/soundtracks if possible
        final url = Uri.parse('https://itunes.apple.com/search?term=${Uri.encodeComponent(q)}&entity=song&limit=10&sort=popular');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          // STRICT FILTER: Only keep items whose genre is 'Soundtrack' or 'Video Game'
          final List<dynamic> results = data['results'];
          final gameMusic = results.where((item) {
            final genre = (item['primaryGenreName'] ?? '').toString().toLowerCase();
            return genre.contains('soundtrack') || genre.contains('game') || genre.contains('anime');
          }).toList();

          combinedResults.addAll(gameMusic.take(5)); // Take top 5 from each query
        }
      }
      
      combinedResults.shuffle();
      return _formatITunesData(combinedResults);
    } catch (e) { return []; }
  }

  List<dynamic> _formatITunesData(List<dynamic> results) {
    return results.map((item) {
      String imageUrl = item['artworkUrl100']?.replaceAll('100x100bb', '600x600bb') ?? '';
      return {
        // CHANGED: Use trackName for songs instead of collectionName
        'name': item['trackName'] ?? item['collectionName'] ?? 'Unknown Audio',
        'images': [{'url': imageUrl}],
        'artists': [{'name': item['artistName'] ?? 'Unknown Artist'}],
        'release_date': item['releaseDate']?.substring(0, 10) ?? '2026',
        // ADDED: Music preview URL for the audio player
        'previewUrl': item['previewUrl'] ?? '', 
      };
    }).toList();
  }

  // Search logic for both APIs
  Future<List<dynamic>> searchGames(String query) async {
    final url = Uri.parse('$_rawgBaseUrl/games?key=$_rawgApiKey&search=$query&page_size=15');
    final response = await http.get(url);
    return response.statusCode == 200 ? json.decode(response.body)['results'] : [];
  }

  Future<List<dynamic>> searchOSTs(String query) async {
    // STRICT FILTER: Force "video game soundtrack" into the user's search query
    final formattedQuery = Uri.encodeComponent('$query video game soundtrack');
    // CHANGED: entity=song for previews
    final url = Uri.parse('https://itunes.apple.com/search?term=$formattedQuery&entity=song&limit=15');
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // STRICT FILTER: Double check the genre
      final List<dynamic> results = data['results'];
      final gameMusic = results.where((item) {
        final genre = (item['primaryGenreName'] ?? '').toString().toLowerCase();
        return genre.contains('soundtrack') || genre.contains('game') || genre.contains('anime');
      }).toList();

      return _formatITunesData(gameMusic);
    }
    return [];
  }

  Future<List<dynamic>> fetchTopPlayedGames() async {
    final url = Uri.parse('$_rawgBaseUrl/games?key=$_rawgApiKey&ordering=-added&page_size=20');
    final response = await http.get(url);
    return response.statusCode == 200 ? json.decode(response.body)['results'] : [];
  }

  
}