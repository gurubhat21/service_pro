import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_pro/models/admin_model.dart';
import 'package:service_pro/models/staff_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // google_sign_in 7.x: authenticate() returns GoogleSignInAccount
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return null;

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Use idToken for Firebase credential (accessToken may not be available in 7.x)
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(authCredential);

      if (userCredential.user != null) {
        await _handleUserSignIn(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _handleUserSignIn(User user) async {
    final adminDoc = await _firestore.collection('admins').doc(user.uid).get();
    if (adminDoc.exists) return;

    final staffDoc = await _firestore.collection('staff').doc(user.uid).get();
    if (staffDoc.exists) return;

    final inviteQuery = await _firestore
        .collection('staff_invites')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (inviteQuery.docs.isNotEmpty) {
      final inviteData = inviteQuery.docs.first.data();
      final adminId = inviteData['adminId'] as String;
      final role = inviteData['role'];

      final newStaff = StaffModel(
        uid: user.uid,
        adminId: adminId,
        email: user.email!,
        name: user.displayName ?? 'Staff User',
        phone: inviteData['phone'] as String? ?? '',
        role: role,
        isActive: true,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('staff').doc(user.uid).set(newStaff.toMap());
      await inviteQuery.docs.first.reference.delete();
    }
  }

  Future<void> registerAdmin({
    required String name,
    required String phone,
    String? businessName,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not signed in');

    final newAdmin = AdminModel(
      uid: user.uid,
      email: user.email!,
      name: name,
      phone: phone,
      businessName: businessName,
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

  Future<AdminModel?> getAdminModel() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('admins').doc(user.uid).get();
    if (!doc.exists) return null;
    return AdminModel.fromMap(doc.data()!);
  }

  Future<StaffModel?> getStaffModel() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('staff').doc(user.uid).get();
    if (!doc.exists) return null;
    return StaffModel.fromMap(doc.data()!);
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.disconnect();
    await _auth.signOut();
  }
}
