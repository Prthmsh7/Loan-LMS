import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;

  // Login form data
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void updateEmail(String value) {
    email.value = value;
    errorMessage.value = '';
  }

  void updatePassword(String value) {
    password.value = value;
    errorMessage.value = '';
  }

  bool validateForm() {
    if (email.value.isEmpty) {
      errorMessage.value = 'Please enter your email';
      return false;
    }

    if (!GetUtils.isEmail(email.value)) {
      errorMessage.value = 'Please enter a valid email';
      return false;
    }

    if (password.value.isEmpty) {
      errorMessage.value = 'Please enter your password';
      return false;
    }

    return true;
  }

  Future<void> login() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authService.signIn(
        email: email.value,
        password: password.value,
      );

      if (user != null) {
        // Navigate to dashboard after successful login
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        errorMessage.value = 'Invalid email or password';
      }
    } catch (e) {
      if (e.toString().contains('Access denied: Admin privileges required')) {
        errorMessage.value = 'Access denied: Admin privileges required';
      } else if (e.toString().contains('user-not-found') ||
          e.toString().contains('wrong-password')) {
        errorMessage.value = 'Invalid email or password';
      } else {
        errorMessage.value = 'Login failed: ${e.toString()}';
      }
    } finally {
      isLoading.value = false;
    }
  }
} 