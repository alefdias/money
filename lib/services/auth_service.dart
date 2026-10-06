import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth? _authInstance;
  FirebaseAuth get _auth {
    try {
      return _authInstance ??= FirebaseAuth.instance;
    } catch (_) {
      throw Exception('Firebase não inicializado');
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '134959488780-em03ct2erll6ef409cj9e694907bhjr7.apps.googleusercontent.com',
  );
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  // Login com E-mail e Senha Real
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _saveBiometricLoginState(true);
    return credential;
  }

  // Cadastro Real com E-mail e Senha
  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _saveBiometricLoginState(true);
    return credential;
  }

  // Login com Google Real
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        await _saveBiometricLoginState(true);
        return userCredential;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Usuário cancelou

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _saveBiometricLoginState(true);
      return userCredential;
    } catch (e) {
      debugPrint('Erro no Google Sign-In: $e');
      rethrow;
    }
  }

  // Verifica se o dispositivo possui suporte a biometria/impressão digital
  Future<bool> canCheckBiometrics() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics.timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => false,
      );
      return canAuthenticate;
    } catch (_) {
      return false;
    }
  }

  // Autenticação por Impressão Digital após primeiro login
  Future<bool> authenticateWithBiometrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasLoggedIn = prefs.getBool('money_has_logged_in') ?? false;

      if (!hasLoggedIn) return false;

      final isAvailable = await canCheckBiometrics();
      if (!isAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Toque na impressão digital para acessar o Money',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('Erro na autenticação biométrica: $e');
      return false;
    }
  }

  Future<void> _saveBiometricLoginState(bool state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('money_has_logged_in', state);
  }

  Future<bool> hasPreviousLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('money_has_logged_in') ?? false;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
