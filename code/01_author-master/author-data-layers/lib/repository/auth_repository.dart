import 'package:author/main.dart';
import 'package:author/service/auth_service_firebase.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:author/base/auth_base.dart';
import 'package:author/service/base/auth_service.dart';

class AuthRepository implements AuthBase {
  final AuthService _service = locator<FirebaseAuthService>();

  @override
  Future getUserId() async {
    return await _service.getUserId();
  }

  @override
  Future loginWithEmailAndPassword(String email, String password) async {
    return await _service.loginWithEmailAndPassword(email, password);
  }

  @override
  Future registerWithEmailAndPassword(
    String fullName,
    String email,
    String password,
  ) async {
    return await _service.registerWithEmailAndPassword(
      fullName,
      email,
      password,
    );
  }

  @override
  Future loginWithGoogle() async {
    return await _service.loginWithGoogle();
  }

  @override
  Future loginWithApple() async {
    return await _service.loginWithApple();
  }

  @override
  Future<void> sendPhoneVerificationCode(
    String phoneNumber, {
    Function(dynamic userId)? autoVerification,
    Function(String error)? verificationFailed,
    Function(dynamic verificationId)? verificationCodeSent,
    Function()? codeTimeOut,
  }) async {
    return await _service.sendPhoneVerificationCode(
      phoneNumber,
      autoVerification: autoVerification,
      verificationFailed: verificationFailed,
      verificationCodeSent: verificationCodeSent,
      codeTimeOut: codeTimeOut,
    );
  }

  @override
  Future confirmPhoneVerificationCode(
    String verificationId,
    String verificationCode,
  ) async {
    return await _service.confirmPhoneVerificationCode(
      verificationId,
      verificationCode,
    );
  }

  @override
  Future<void> resetPassword(String email) async {
    return await _service.resetPassword(email);
  }

  @override
  Future<void> logout() async {
    await GoogleSignIn().signOut();
    return await _service.logout();
  }
}
