class FakeAuthApi {
  // Tài khoản mẫu
  static const String sampleEmail = 'user1@gmail.com';
  static const String samplePassword = 'User@123';
  static const String mockVerificationCode = '123456';

  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == sampleEmail && password == samplePassword) {
      return true;
    }
    return false;
  }

  static Future<bool> checkEmailExists(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return email == sampleEmail;
  }

  static Future<bool> register(String email, String code, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email.isNotEmpty && code == mockVerificationCode && password.isNotEmpty) {
      return true;
    }
    return false;
  }

  static Future<void> sendVerificationCode(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    print("Đã gửi mã $mockVerificationCode đến email $email");
  }
}