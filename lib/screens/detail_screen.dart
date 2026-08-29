import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // REQUIRED
import '../services/firestore_service.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String type; 
  final String description;
  final String? previewUrl; 

  const DetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.type,
    required this.description,
    this.previewUrl, 
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose(); // Cleanup audio player when leaving screen
    super.dispose();
  }

  void _toggleAudio() async {
    if (widget.previewUrl == null || widget.previewUrl!.isEmpty) return;
    
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.previewUrl!));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.type == 'game' ? const Color(0xFF00E5FF) : const Color(0xFFFF0055);
    final hasAudio = widget.type == 'ost' && widget.previewUrl != null && widget.previewUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F13),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: widget.imageUrl.isNotEmpty
                  ? ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent],
                        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.network(widget.imageUrl, fit: BoxFit.cover),
                    )
                  : Container(color: const Color(0xFF1C1C23)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ITEM DESIGNATION: ${widget.type.toUpperCase()}",
                    style: TextStyle(color: accentColor, letterSpacing: 2.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  // AUDIO PLAYER BUTTON
                  if (hasAudio) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: _toggleAudio,
                        icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: accentColor),
                        label: Text(
                          _isPlaying ? "PAUSE FREQUENCY" : "PLAY PREVIEW", 
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: accentColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accentColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // MODIFIED: FOLDER SELECTION DIALOG & SAVE TO VAULT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // 1. Show a dialog to get the folder name
                        TextEditingController folderController = TextEditingController(text: 'Main Vault');
                        
                        String? selectedFolder = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1C1C23),
                            title: Text("ASSIGN TO FOLDER", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            content: TextField(
                              controller: folderController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: widget.type == 'game' ? 'Folder Name' : 'Playlist Name',
                                labelStyle: const TextStyle(color: Colors.white54),
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor)),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, null),
                                child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, folderController.text.trim()),
                                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                                child: const Text("CONFIRM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );

                        // 2. If user provided a folder, save to Firestore
                        if (selectedFolder != null && selectedFolder.isNotEmpty) {
                          final success = await FirestoreService().saveItemToVault(
                            title: widget.title,
                            imageUrl: widget.imageUrl,
                            type: widget.type,
                            folderName: selectedFolder,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success ? 'SECURED IN [$selectedFolder].' : 'DATA TRANSFER FAILED.',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                ),
                                backgroundColor: success ? accentColor : Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.download, color: Colors.black),
                      label: const Text(
                        "SAVE TO VAULT", 
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shadowColor: accentColor,
                        elevation: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}