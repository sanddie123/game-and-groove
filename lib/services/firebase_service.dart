import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  // v7+ requires initialization before authenticating
  

  // Sign Up with Email/Password
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Log In with Email/Password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Google Sign-In (Updated for v7+)
  Future<User?> signInWithGoogle() async {
    try {
      await _initGoogle();
      
      // signIn() is now authenticate()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      // authentication is now a synchronous property
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      // accessToken is no longer needed/available here
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> _initGoogle() async {
    if (!_isGoogleInitialized) {
      await _googleSignIn.initialize(
        // Paste your Web Client ID here
        serverClientId: '668899329541-5289mj0dghba8rrdr9aaomuian0k4cgm.apps.googleusercontent.com', 
      );
      _isGoogleInitialized = true;
    }
  }
}