import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _topGames = [];
  List<dynamic> _topOSTs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharts();
  }

  void _loadCharts() async {
    // CHANGED: Now fetches by player count instead of rating
    final games = await _apiService.fetchTopPlayedGames(); 
    final osts = await _apiService.fetchTrendingOSTs();
    if (mounted) {
      setState(() {
        _topGames = games;
        _topOSTs = osts;
        _isLoading = false;
      });
    }
  }

  Widget _buildList(List<dynamic> items, String type, Color accentColor) {
    if (items.isEmpty) return const Center(child: Text("NO DATA FOUND.", style: TextStyle(color: Colors.white54)));
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title = item['name'] ?? 'Unknown';
        
        String imageUrl = '';
        String previewUrl = ''; 

        if (type == 'game') {
          imageUrl = item['background_image'] ?? '';
        } else {
          if (item['images'] != null && item['images'].isNotEmpty) {
            imageUrl = item['images'][0]['url'];
          }
          previewUrl = item['previewUrl'] ?? ''; 
        }

        // CHANGED: Display "Player Count" (the 'added' field) instead of Rating
        final description = type == 'game' 
            ? 'Player Count: ${item['added'] ?? 'Unknown'}' 
            : 'Artist: ${item['artists'][0]['name'] ?? 'Unknown'}';

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => DetailScreen(
                title: title, 
                imageUrl: imageUrl, 
                type: type, 
                description: description,
                previewUrl: previewUrl, 
              ),
            ));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            height: 200, 
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C23),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Center(
                    child: Text("#${index + 1}", style: TextStyle(color: accentColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (imageUrl.isNotEmpty)
                  Container(
                    width: 80, height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        // Subtitle text rendering the Player Count
                        Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // CHANGED: Updated the title to reflect popularity instead of ratings
          title: const Text("TRENDING", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFF00E5FF),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: "GAMES"), Tab(text: "MUSICS")],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
            : TabBarView(
                children: [
                  _buildList(_topGames, 'game', const Color(0xFF00E5FF)),
                  _buildList(_topOSTs, 'ost', const Color(0xFFFF0055)),
                ],
              ),
      ),
    );
  }
}