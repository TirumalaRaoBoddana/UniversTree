import 'package:firebase_auth/firebase_auth.dart' as fb;

class RegistrationAuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<fb.User> ensureActiveSession() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser;
    }
    try {
      final credential = await _auth.signInAnonymously();
      if (credential.user == null) {
        throw Exception('Failed to establish a secure anonymous session.');
      }
      return credential.user!;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth Error [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('Authentication initialization failed: $e');
    }
  }

  Future<void> ensureFreshSessionToken() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
      await currentUser.getIdToken(true);
    }
  }

  Future<void> linkEmailPasswordCredential({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No active session found. Please restart the registration.');
    }

    try {
      if (user.isAnonymous) {
        final credential = fb.EmailAuthProvider.credential(
          email: email.trim(),
          password: password,
        );
        await user.linkWithCredential(credential);
      } else {
        // 🌟 FIX: Safely update the Auth Email if the user changes it later in the workflow
        if (user.email != email.trim()) {
          await user.verifyBeforeUpdateEmail(email.trim());
        }
      }
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('An account with this official email already exists. Please log in instead.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak. Please use a stronger password.');
      }
      throw Exception(e.message ?? 'Failed to secure account credentials.');
    } catch (e) {
      throw Exception('Unexpected error securing account: $e');
    }
  }

  Future<void> linkPhoneCredential(fb.PhoneAuthCredential credential) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No active session found to link phone credential.');
    }

    try {
      await currentUser.linkWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw Exception('This office phone number is already registered to another account. Please use a different number to verify this institution.');
      } else if (e.code == 'provider-already-linked') {
        await currentUser.reload();
      } else {
        throw Exception('Phone linking failed [${e.code}]: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error linking phone identity: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get currentUid => _auth.currentUser?.uid;

  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;
}