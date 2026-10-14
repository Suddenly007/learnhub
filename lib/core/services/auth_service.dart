import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> register(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  /// Reads the `admin` custom claim (set with tools/set_admin.js).
  Future<bool> isAdmin(User user) async {
    final token = await user.getIdTokenResult(true);
    return token.claims?['admin'] == true;
  }
}
