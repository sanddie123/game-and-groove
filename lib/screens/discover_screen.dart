import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final ApiService _apiService = ApiService();
  dynamic _featuredGame;
  dynamic _featuredOST;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyHighlights();
  }

  Future<void> _loadDailyHighlights() async {
    // Fetch data and pick a random item from the top results for variety each day
    final games = await _apiService.fetchTrendingGames();
    final osts = await _apiService.fetchTrendingOSTs();
    
    final random = Random();
    
    if (mounted) {
      setState(() {
        if (games.isNotEmpty) _featuredGame = games[random.nextInt(min(5, games.length))];
        if (osts.isNotEmpty) _featuredOST = osts[random.nextInt(min(5, osts.length))];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Extract name from email (e.g., "alex@test.com" -> "ALEX")
    final String displayName = user?.email?.split('@')[0].toUpperCase() ?? 'OPERATOR';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. WELCOME HEADER
            const Text("SYSTEM ONLINE.", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2.0)),
            const SizedBox(height: 4),
            Text(
              "WELCOME, $displayName",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 24),

            // 2. USER ANALYTICS DASHBOARD
            const Text("VAULT ANALYTICS", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            const SizedBox(height: 12),
            _buildAnalyticsStream(user?.uid),
            
            const SizedBox(height: 40),

            // 3. DAILY HIGHLIGHTS (HERO CARDS)
            const Text("DAILY HIGHLIGHTS", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: Color(0xFF00E5FF))))
            else ...[
              if (_featuredGame != null)
                _buildHeroCard(
                  title: _featuredGame['name'] ?? 'Unknown',
                  imageUrl: _featuredGame['background_image'] ?? '',
                  description: 'Rating: ${_featuredGame['rating'] ?? 'N/A'}\nReleased: ${_featuredGame['released'] ?? 'Unknown'}',
                  type: 'game',
                  accentColor: const Color(0xFF00E5FF),
                ),
              
              const SizedBox(height: 24),
              
              if (_featuredOST != null)
                _buildHeroCard(
                  title: _featuredOST['name'] ?? 'Unknown',
                  imageUrl: _featuredOST['images'][0]['url'] ?? '',
                  description: 'Artist: ${_featuredOST['artists'][0]['name']}\nReleased: ${_featuredOST['release_date']}',
                  type: 'ost',
                  accentColor: const Color(0xFFFF0055),
                  previewUrl: _featuredOST['previewUrl'],
                ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildAnalyticsStream(String? uid) {
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('vault').snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        int games = 0;
        int audio = 0;

        if (snapshot.hasData) {
          total = snapshot.data!.docs.length;
          games = snapshot.data!.docs.where((doc) => doc['type'] == 'game').length;
          audio = snapshot.data!.docs.where((doc) => doc['type'] == 'ost').length;
        }

        return Row(
          children: [
            Expanded(child: _buildStatBox("TOTAL", total.toString(), Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatBox("GAMES", games.toString(), const Color(0xFF00E5FF))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatBox("AUDIO", audio.toString(), const Color(0xFFFF0055))),
          ],
        );
      },
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: -5)],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required String title,
    required String imageUrl,
    required String description,
    required String type,
    required Color accentColor,
    String? previewUrl,
  }) {
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
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
          boxShadow: [BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
          image: imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                )
              : null,
        ),
        child: Stack(
          children: [
            // Gradient Overlay for text readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(4)),
                    child: Text(type.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text("TAP TO INSPECT", style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, color: accentColor, size: 10),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}