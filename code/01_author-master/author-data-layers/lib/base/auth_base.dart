abstract class AuthBase {
  Future<dynamic> getUserId();

  Future<dynamic> loginWithEmailAndPassword(
    String email,
    String password,
  );

  Future<dynamic> registerWithEmailAndPassword(
    String fullName,
    String email,
    String password,
  );

  Future<dynamic> loginWithGoogle();

  Future<dynamic> loginWithApple();

  Future<void> sendPhoneVerificationCode(
    String phoneNumber, {
    Function(dynamic userId)? autoVerification,
    Function(String error)? verificationFailed,
    Function(dynamic verificationId)? verificationCodeSent,
    Function()? codeTimeOut,
  });

  Future<dynamic> confirmPhoneVerificationCode(
    String verificationId,
    String verificationCode,
  );

  Future<void> resetPassword(String email);

  Future<void> logout();
}
