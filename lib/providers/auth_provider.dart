import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: '316749649272-1u94uobo0mrgs11e9huvh8cq613vb4eb.apps.googleusercontent.com',
      );

      // Đã bỏ dấu '?' và code kiểm tra null vì hàm này luôn trả về đối tượng
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      user = userCredential.user;
      
      notifyListeners(); 
      
    } catch (e) {
      // Đã thay print() bằng debugPrint() chuẩn của Flutter
      debugPrint("Lỗi đăng nhập Google: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    user = null;
    notifyListeners();
  }
}