import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'push_notification_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '977202851449-f3mmnla6n05kbllrivitm0qh4csonlf3.apps.googleusercontent.com',
  );

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  User? get currentUser => _auth.currentUser;

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToUserChanges(user.uid);
        PushNotificationService().initialize(user.uid);
      } else {
        _userModel = null;
        _userSubscription?.cancel();
        notifyListeners();
      }
    });
  }

  void _subscribeToUserChanges(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
        notifyListeners();
      }
    });
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with Email and Password
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Send email verification link
        await user.sendEmailVerification();

        // Create user profile in Firestore
        final model = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: role,
          verificationMethod: 'email',
          isVerified: false,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(model.toMap());
        return null; // Success
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
    return 'Unknown error occurred';
  }

  // Resend email verification
  Future<String?> resendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Login with Email and Password
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Phone Authentication
  Future<String?> verifyPhoneNumber(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onFailure,
  ) async {
    try {
      debugPrint('AuthService: Starting phone verification for $phoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('AuthService: Auto-verification completed');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('AuthService: Phone Auth FAILED - Code: ${e.code}, Message: ${e.message}');
          onFailure('${e.code}: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('AuthService: OTP code sent! verificationId=$verificationId');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('AuthService: Auto-retrieval timeout');
        },
      );
      return null;
    } catch (e) {
      debugPrint('AuthService: verifyPhoneNumber exception: $e');
      return e.toString();
    }
  }

  Future<String?> signInWithPhoneNumber({
    required String verificationId, 
    required String smsCode,
    String? name,
    UserRole? role,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      
      User? user = result.user;
      if (user != null && name != null && role != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          final model = UserModel(
            uid: user.uid,
            name: name,
            email: user.email ?? '', 
            role: role,
            verificationMethod: 'phone',
            isVerified: true,
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(user.uid).set(model.toMap());
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Update Profile
  Future<String?> updateProfile({String? name, String? bio, String? photoUrl, bool? isVerified}) async {
    try {
      if (currentUser == null) return 'Not logged in';
      
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (isVerified != null) updates['is_verified'] = isVerified;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser!.uid).update(updates);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Google Sign-In
  // Returns null on success, an error string on failure.
  // [role] is only used when the account is brand-new to Firestore.
  // If [role] is null and the user is new, the caller must ask for a role.
  Future<String?> signInWithGoogle({UserRole? role}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'cancelled'; // user dismissed the picker

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
          await _auth.signInWithCredential(credential);
      final User? user = result.user;
      if (user == null) return 'Google sign-in failed';

      // Check if Firestore profile already exists
      final doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        // New user — role is required
        if (role == null) return 'role_required';

        final model = UserModel(
          uid: user.uid,
          name: user.displayName ?? googleUser.displayName ?? 'User',
          email: user.email,
          role: role,
          verificationMethod: 'google',
          isVerified: true,
          createdAt: DateTime.now(),
          photoUrl: user.photoURL,
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(model.toMap());
      }
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Password Reset
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
