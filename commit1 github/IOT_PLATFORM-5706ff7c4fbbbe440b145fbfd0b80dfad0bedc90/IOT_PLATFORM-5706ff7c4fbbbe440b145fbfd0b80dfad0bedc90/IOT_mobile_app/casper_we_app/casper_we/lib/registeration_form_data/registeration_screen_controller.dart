import 'package:casper_we/libraries.dart';
import 'package:http/http.dart' as http;

class RegisterationFormController extends GetxController {
  var password = "".obs;
  var retypePassword = "".obs;
  var registerError = "".obs;
  var name = "".obs;
  var email = "".obs;
  var isLoading = false.obs;

  // Live validation
  Future<void> checkPasswords() async {
    // Check if fields are not empty
    if (password.value.isEmpty ||
        retypePassword.value.isEmpty ||
        name.value.isEmpty ||
        email.value.isEmpty) {
      registerError.value = "All fields are required";
    } else if ((password.value.length < 6)) {
      registerError.value = "Password must be at least 6 characters";
    } else if (password.value != retypePassword.value) {
      registerError.value = "Passwords do not match";
    } else {
      registerError.value =
          "waiting for server response..."; // Temporary message while waiting for server
    }
    showToast(message: registerError.value);
    return;
  }

  // FIXED: Changed to async and waits for response
  Future<void> register_button() async {
    // First check if passwords match

    await checkPasswords();

    // Show loading
    isLoading.value = true;

    try {
      if (registerError.value == "waiting for server response...") {
        // FIX: Wait for the HTTP request to complete
        await send_http_user_registeration_data(
          name.value,
          email.value,
          password.value,
        );
      }

      // Note: The toast for success/error is now shown INSIDE
      // send_http_user_registeration_data based on server response
    } catch (error) {
      showToast(message: "Registration failed: $error");
    } finally {
      isLoading.value = false;
    }

    log("Password: ${password.value}");
    log("Retype: ${retypePassword.value}");
    log("Error: ${registerError.value}");
  }

  // FIXED: Now shows toast based on server response
  Future<void> send_http_user_registeration_data(
    String name,
    String email,
    String password,
  ) async {
    String url = 'https://server.casper-we.site/register.php';
    //good
    Map<String, String> formData = {
      'name': name,
      'email': email,
      'password': password,
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        body: formData,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      // FIX: Check the actual response from your PHP
      if (response.statusCode == 200) {
        // Your PHP returns plain text, so check the text content
        if (response.body.contains("Registration successful")) {
          showToast(message: "Registration successful! Check email for OTP");
          Get.to(() => OtpVerificationPage());
        } else if (response.body.contains("already registered")) {
          showToast(message: "Email already registered");
        } else if (response.body.contains("All fields are required")) {
          showToast(message: "Please fill all fields");
        } else {
          // Show whatever PHP returns
          showToast(message: response.body);
        }
      } else {
        showToast(message: "Server error: ${response.statusCode}");
      }
    } catch (error) {
      log('Error during registration: $error');
      showToast(message: "Network error: Please check connection");
    }
  }
}

final RegisterationFormController registerationFormController = Get.put(
  RegisterationFormController(),
);
