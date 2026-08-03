import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_pro/models/admin_model.dart';
import 'package:service_pro/models/staff_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Handle post-signin logic (check admins/staff collections)
      await _handleUserSignIn(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  Future<void> _handleUserSignIn(User user) async {
    // 1. Check if user is already an admin
    final adminDoc = await _firestore.collection('admins').doc(user.uid).get();
    if (adminDoc.exists) return; // Already an admin

    // 2. Check if user is already staff
    final staffDoc = await _firestore.collection('staff').doc(user.uid).get();
    if (staffDoc.exists) return; // Already staff

    // 3. Check if there's a staff invite for this email
    final inviteQuery = await _firestore
        .collection('staff_invites')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (inviteQuery.docs.isNotEmpty) {
      // Create staff profile from invite
      final inviteData = inviteQuery.docs.first.data();
      final adminId = inviteData['adminId'];
      final role = inviteData['role'];

      final newStaff = StaffModel(
        uid: user.uid,
        adminId: adminId,
        email: user.email!,
        name: user.displayName ?? 'Staff User',
        phone: '', // Needs to be updated by user
        role: role,
        isActive: true,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('staff').doc(user.uid).set(newStaff.toMap());
      await inviteQuery.docs.first.reference.delete(); // Remove invite
      return;
    }

    // 4. Default: Register as a new Admin
    final newAdmin = AdminModel(
      uid: user.uid,
      email: user.email!,
      name: user.displayName ?? 'New Admin',
      phone: '', // Needs update
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('admins').doc(user.uid).set(newAdmin.toMap());
  }

  Future<String?> getUserRole() async {
    final user = currentUser;
    if (user == null) return null;

    final adminDoc = await _firestore.collection('admins').doc(user.uid).get();
    if (adminDoc.exists) return 'admin';

    final staffDoc = await _firestore.collection('staff').doc(user.uid).get();
    if (staffDoc.exists) return 'staff';

    return null;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
