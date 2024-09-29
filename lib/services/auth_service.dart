import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Logger _logger = Logger();

  static Future<User?> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Error en inicio de sesión con correo: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Error en inicio de sesión con correo: $e');
      rethrow;
    }
  }

  static Future<User?> registerWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Error en registro con correo: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Error en registro con correo: $e');
      rethrow;
    }
  }

  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(user!.uid).set({
          'email': user.email,
          'name': user.displayName,
          'createdAt': Timestamp.now(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Error en inicio de sesión con Google: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Error en inicio de sesión con Google: $e');
      rethrow;
    }
  }

  static Future<void> createUserInFirestore(User user) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'createdAt': Timestamp.now(),
        });
      }
    } catch (e) {
      _logger.e('Error al crear usuario en Firestore: $e');
      rethrow;
    }
  }
}
