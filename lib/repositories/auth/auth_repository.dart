import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rocket_chat_flutter_demo/repositories/auth/base_auth_repository.dart';

class AuthRepository extends BaseAuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final FirebaseFirestore _firebaseFirestore;
  // final auth.FirebaseAuth _firebaseAuth;
  // final usersRef = FirebaseFirestore.instance.collection('users');

  AuthRepository();
  // AuthRepository({
  //   FirebaseFirestore? firebaseFirestore,
  //   auth.FirebaseAuth? firebaseAuth,
  // })  : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
  //       _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  // @override
  // Stream<auth.User?> get user => _firebaseAuth.userChanges();

  // @override
  // Future<bool> checkUserDataExists({required String userId}) async {
  //   String _errorMessage = 'Something went wrong';
  //   try {
  //     final user = await usersRef.doc(userId).get();
  //     return user.exists;
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     debugPrint(e.toString());
  //   }
  //   throw Exception(_errorMessage);
  // }

  @override
  Future<GoogleSignInAuthentication> signInByGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final googleAuth = await user.authentication;
        // final credential = auth.GoogleAuthProvider.credential(
        //     accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        return googleAuth;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    throw Exception('something went wrong');
  }

  // String _verificationId = "";
  // int? _resendToken;
  // @override
  // Future<bool> sendOTP({required String phone}) async {
  //   await _firebaseAuth.verifyPhoneNumber(
  //     phoneNumber: phone,
  //     verificationCompleted: (auth.PhoneAuthCredential credential) {},
  //     verificationFailed: (auth.FirebaseAuthException e) {},
  //     codeSent: (String verificationId, int? resendToken) async {
  //       _verificationId = verificationId;
  //       _resendToken = resendToken;
  //     },
  //     timeout: const Duration(seconds: 25),
  //     forceResendingToken: _resendToken,
  //     codeAutoRetrievalTimeout: (String verificationId) {
  //       verificationId = _verificationId;
  //     },
  //   );
  //   debugPrint("_verificationId: $_verificationId");
  //   return true;
  // }

  // @override
  // Future<auth.UserCredential> verifyOTP({required String otp}) async {
  //   auth.PhoneAuthCredential credential = auth.PhoneAuthProvider.credential(
  //       verificationId: _verificationId, smsCode: otp);
  //   return await _firebaseAuth.signInWithCredential(credential);
  // }

  @override
  Future<void> logOut() async {
    await _googleSignIn.signOut();
    // await _firebaseAuth.signOut();
  }
}
