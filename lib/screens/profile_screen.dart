import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("USER PROFILE", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar & Identity
            Center(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                  boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
                ),
                child: const Icon(Icons.person, size: 50, color: Color(0xFF00E5FF)),
              ),
            ),
            const SizedBox(height: 24),
            
            // Network Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1C1C23), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("NETWORK IDENTITY:", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? "UNKNOWN USER", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text("SYSTEM ID:", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(user?.uid ?? "N/A", style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace')),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Real-time Vault Analytics
            const Text("VAULT ANALYTICS", style: TextStyle(color: Color(0xFFB300FF), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('vault').snapshots(),
              builder: (context, snapshot) {
                int gameCount = 0;
                int ostCount = 0;
                
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['type'] == 'game') gameCount++;
                    if (data['type'] == 'ost') ostCount++;
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1C1C23), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3))),
                        child: Column(
                          children: [
                            const Icon(Icons.gamepad, color: Color(0xFF00E5FF)),
                            const SizedBox(height: 8),
                            Text("$gameCount", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            const Text("GAMES SAVED", style: TextStyle(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1C1C23), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFF0055).withOpacity(0.3))),
                        child: Column(
                          children: [
                            const Icon(Icons.music_note, color: Color(0xFFFF0055)),
                            const SizedBox(height: 8),
                            Text("$ostCount", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            const Text("MUSIC SAVED", style: TextStyle(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),

            

            const SizedBox(height: 40),
            
            // Disconnect Button
            SizedBox(
              width: double.infinity, height: 55,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authService.signOut();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.power_settings_new, color: Color(0xFFFF0055)),
                label: const Text("DISCONNECT SYSTEM", style: TextStyle(color: Color(0xFFFF0055), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF0055), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}