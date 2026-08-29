import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_screen.dart'; 

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("ACCESS DENIED.", style: TextStyle(color: Colors.redAccent, letterSpacing: 2.0)));
    }

    final vaultStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('vault')
        .orderBy('savedAt', descending: true)
        .snapshots();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("PERSONAL VAULT", style: TextStyle(color: Color(0xFFB300FF), fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          bottom: const TabBar(
            indicatorColor: Color(0xFFB300FF),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: "GAMES"), Tab(text: "MUSIC")],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: vaultStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFB300FF)));

            final docs = snapshot.data?.docs ?? [];
            final gameDocs = docs.where((doc) => (doc.data() as Map)['type'] == 'game').toList();
            final ostDocs = docs.where((doc) => (doc.data() as Map)['type'] == 'ost').toList();

            return TabBarView(
              children: [
                _buildGrid(gameDocs, const Color(0xFF00E5FF), user.uid, context),
                _buildGrid(ostDocs, const Color(0xFFFF0055), user.uid, context),
              ],
            );
          },
        ),
      ),
    );
  }

  // MODIFIED: Now parses into folders before building the view
  Widget _buildGrid(List<QueryDocumentSnapshot> docs, Color accentColor, String uid, BuildContext context) {
    if (docs.isEmpty) return const Center(child: Text("VAULT SECTION IS EMPTY.", style: TextStyle(color: Colors.white54, letterSpacing: 1.5)));

    // GROUP ITEMS BY FOLDER NAME
    Map<String, List<QueryDocumentSnapshot>> groupedVault = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Fallback if older items don't have a folderName yet
      String folder = data.containsKey('folderName') ? data['folderName'] : 'Main Vault';
          
      if (!groupedVault.containsKey(folder)) {
        groupedVault[folder] = [];
      }
      groupedVault[folder]!.add(doc);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groupedVault.keys.length,
      itemBuilder: (context, index) {
        String folderName = groupedVault.keys.elementAt(index);
        List<QueryDocumentSnapshot> folderItems = groupedVault[folderName]!;

        return Card(
          color: const Color(0xFF1C1C23),
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            iconColor: accentColor,
            collapsedIconColor: Colors.white70,
            title: Text(
              folderName.toUpperCase(), 
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)
            ),
            subtitle: Text("${folderItems.length} ITEMS", style: const TextStyle(color: Colors.white54, fontSize: 12)),
            children: [
              GridView.builder(
                padding: const EdgeInsets.all(12.0),
                shrinkWrap: true, // Required inside ListView
                physics: const NeverScrollableScrollPhysics(), // Disables inner scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 16, 
                  mainAxisSpacing: 16, 
                  childAspectRatio: 0.75,
                ),
                itemCount: folderItems.length,
                itemBuilder: (context, itemIndex) {
                  final data = folderItems[itemIndex].data() as Map<String, dynamic>;
                  final docId = folderItems[itemIndex].id;
                  final title = data['title'] ?? 'Unknown';
                  final imageUrl = data['imageUrl'] ?? '';
                  final type = data['type'] ?? 'game';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          title: title, 
                          imageUrl: imageUrl, 
                          type: type, 
                          description: "This item is securely stored in your personal vault network.",
                        ),
                      ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentColor.withOpacity(0.4)),
                        image: imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(imageUrl), 
                                fit: BoxFit.cover, 
                                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)
                              )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                title, 
                                textAlign: TextAlign.center, 
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), 
                                maxLines: 2, 
                                overflow: TextOverflow.ellipsis
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4, right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white70),
                              onPressed: () => FirebaseFirestore.instance.collection('users').doc(uid).collection('vault').doc(docId).delete(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}