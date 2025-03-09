import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:author/service/base/auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future getUserId() async {
    return _auth.currentUser?.uid;
  }

  @override
  Future loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      return user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("User not found.");
      } else if (e.code == "wrong-password") {
        print("Password is wrong.");
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future registerWithEmailAndPassword(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      await user?.updateDisplayName(fullName);
      await user?.sendEmailVerification();
      return user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        print("Password is too weak.");
      } else if (e.code == "email-already-in-use") {
        print("An account has already been created with this e-mail.");
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future loginWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ["email"]);

    GoogleSignInAccount? googleAccount = await googleSignIn.signIn();

    if (googleAccount != null) {
      GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        authCredential,
      );

      User? user = userCredential.user;
      return user?.uid;
    }
    return null;
  }

  @override
  Future loginWithApple() async {
    AuthorizationCredentialAppleID appleId =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
      ],
    );

    OAuthProvider oAuthProvider = OAuthProvider("apple.com");

    AuthCredential authCredential = oAuthProvider.credential(
      accessToken: appleId.authorizationCode,
      idToken: appleId.identityToken,
    );
    UserCredential userCredential = await _auth.signInWithCredential(
      authCredential,
    );

    User? user = userCredential.user;
    return user?.uid;
  }

  @override
  Future<void> sendPhoneVerificationCode(
    String phoneNumber, {
    Function(dynamic userId)? autoVerification,
    Function(String error)? verificationFailed,
    Function(dynamic verificationId)? verificationCodeSent,
    Function()? codeTimeOut,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (
        PhoneAuthCredential authCredential,
      ) async {
        UserCredential userCredential = await _auth.signInWithCredential(
          authCredential,
        );

        User? user = userCredential.user;
        autoVerification?.call(user?.uid);
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed?.call(e.code);
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationCodeSent?.call(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        codeTimeOut?.call();
      },
    );
  }

  @override
  Future confirmPhoneVerificationCode(
    String verificationId,
    String verificationCode,
  ) async {
    try {
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: verificationCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        authCredential,
      );

      User? user = userCredential.user;
      return user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-verification-code") {
        print("Invalid verification code.");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
