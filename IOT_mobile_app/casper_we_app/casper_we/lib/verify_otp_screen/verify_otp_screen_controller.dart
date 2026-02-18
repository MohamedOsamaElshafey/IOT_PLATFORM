import 'package:casper_we/libraries.dart';
import 'package:http/http.dart' as http;

class OtpController extends GetxController {
  // 6 text controllers
  var textControllers = List.generate(6, (_) => TextEditingController());

  // 6 focus nodes
  var focusNodes = List.generate(6, (_) => FocusNode());

  // OTP value
  var otp_retype_check = ''.obs;

  @override
  void onClose() {
    for (var c in textControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }

  // Call this from TextField's onChanged
  void onOtpChanged(String value, int index) {
    // Move forward
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    }

    // Move backward
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Update OTP string
    otp_retype_check.value = textControllers.map((c) => c.text).join();
  }

  // Call this when "Verify" button is pressed
  void verifyOtp() async {
    await send_http_user_verify_otp_data(
      registerationFormController.email.value,
      otp_retype_check.value,
    );
  }

  Future<void> send_http_user_verify_otp_data(String email, String OTP) async {
    String url = 'https://server.casper-we.site/verify.php';

    Map<String, String> formData = {'email': email, 'otp': OTP};

    try {
      var response = await http.post(
        Uri.parse(url),
        body: formData,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      // FIX: Check the actual response from your PHP
      if (response.statusCode == 200) {
        // Your PHP returns plain text, so check the text content
        if (response.body.contains("verified_ok")) {
          await showToast(message: "ACCOUNT verified");
          Get.offAll(() => const UserDevicesscreenpage());
        } else if (response.body.contains("OTP_expired")) {
          await showToast(message: "OTP expired. Please register again");
          Get.back(); // Go back to registration page
        } else if (response.body.contains("Invalid_OTP")) {
          await showToast(message: "Invalid OTP");
        }
      } else {
        showToast(message: "Server error: ${response.statusCode}");
      }
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (error) {
      log('Error during verification: $error');
      showToast(message: "Network error: Please check connection");
    }
  }
}

// Self-registering instance
final OtpController otpController = Get.put(OtpController());
