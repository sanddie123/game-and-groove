import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<dynamic> _gameResults = [];
  List<dynamic> _ostResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  void _search() async {
    FocusScope.of(context).unfocus(); 
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    
    final games = await _apiService.searchGames(query);
    final osts = await _apiService.searchOSTs(query);
    
    if (mounted) {
      setState(() {
        _gameResults = games;
        _ostResults = osts;
        _isLoading = false;
      });
    }
  }

  Widget _buildResultsList(List<dynamic> items, String type, Color accentColor) {
    if (!_hasSearched) return const Center(child: Text("AWAITING INPUT.", style: TextStyle(color: Colors.white54, letterSpacing: 1.5)));
    if (items.isEmpty) return const Center(child: Text("NO DIRECTIVES FOUND.", style: TextStyle(color: Colors.white54, letterSpacing: 1.5)));

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title = item['name'] ?? 'Unknown';
        
        String imageUrl = '';
        if (type == 'game') {
          imageUrl = item['background_image'] ?? '';
        } else if (item['images'] != null && item['images'].isNotEmpty) {
          imageUrl = item['images'][0]['url'];
        }

        final description = type == 'game' 
            ? 'Released: ${item['released'] ?? 'Unknown'}' 
            : 'Artist: ${item['artists']?[0]['name'] ?? 'Unknown'}';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: imageUrl.isNotEmpty
              ? Container(width: 60, height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)))
              : Icon(type == 'game' ? Icons.gamepad : Icons.music_note, size: 40, color: accentColor),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(description, style: const TextStyle(color: Colors.white54)),
          trailing: Icon(Icons.chevron_right, color: accentColor),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => DetailScreen(title: title, imageUrl: imageUrl, type: type, description: description),
            ));
          },
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
          title: const Text("GLOBAL SEARCH", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter directive...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1C1C23),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF00E5FF).withOpacity(0.3))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00E5FF))),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF00E5FF), borderRadius: BorderRadius.circular(12)),
                    child: IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: _search),
                  ),
                ],
              ),
            ),
            const TabBar(
              indicatorColor: Color(0xFF00E5FF),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: [Tab(text: "GAMES"), Tab(text: "MUSIC")],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
                  : TabBarView(
                      children: [
                        _buildResultsList(_gameResults, 'game', const Color(0xFF00E5FF)),
                        _buildResultsList(_ostResults, 'ost', const Color(0xFFFF0055)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}