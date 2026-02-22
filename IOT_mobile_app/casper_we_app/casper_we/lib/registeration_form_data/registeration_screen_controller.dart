import 'package:casper_we/libraries.dart';
import 'package:http/http.dart' as http;

class RegisterationFormController extends GetxController {
  var password = "".obs;
  var retypePassword = "".obs;
  var registerError = "".obs;
  var name = "".obs;
  var email = "".obs;

  final nametextController = TextEditingController();
  final emailtextController = TextEditingController();
  final passwordtextController = TextEditingController();
  final retypePasswordtextController = TextEditingController();

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
      registerError.value = "send the post registeration request to the server";
    }
    return;
  }

  // FIXED: Changed to async and waits for response
  Future<void> register_button() async {
    // First check if passwords match
    name.value = nametextController.text.trim();
    email.value = emailtextController.text.trim();
    password.value = passwordtextController.text;
    retypePassword.value = retypePasswordtextController.text;

    //store the values also in the global variables for later use in OTP verification
    globalvariables.name.value = name.value;
    globalvariables.email.value = email.value;
    globalvariables.password.value = password.value;
    await checkPasswords();

    // Show loading

    try {
      if (registerError.value ==
          "send the post registeration request to the server") {
        // FIX: Wait for the HTTP request to complete
        loadingOverlayController.show();
        await send_http_user_registeration_data(
          name.value,
          email.value,
          password.value,
        );
      }

      // Note: The toast for success/error is now shown INSIDE
      // send_http_user_registeration_data based on server response
    } catch (error) {
      loadingOverlayController.hide();
      showToast(message: "Registration failed: $error");
    } finally {
      // Ensure loading is hidden in case of any unexpected errors
      loadingOverlayController.hide();
    }
  }

  // FIXED: Now shows toast based on server response
  Future<void> send_http_user_registeration_data(
    String name,
    String email,
    String password,
  ) async {
    String url = "${globalvariables.serverUrl.value}/register.php";
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
          loadingOverlayController.hide();
          showToast(message: "Registration successful! Check email for OTP");
          Get.offNamed('/verify-otp');
        } else if (response.body.contains("already registered")) {
          loadingOverlayController.hide();
          showToast(message: "Email already registered");
        } else {
          // Show whatever PHP returns
          loadingOverlayController.hide();
          showToast(message: response.body);
        }
      } else {
        loadingOverlayController.hide();
        showToast(message: "Server error: ${response.statusCode}");
      }
    } catch (error) {
      loadingOverlayController.hide();
      log('Error during registration: $error');
      showToast(message: "Network error: Please check connection");
    }
  }

  @override
  void onClose() {
    nametextController.dispose();
    emailtextController.dispose();
    passwordtextController.dispose();
    retypePasswordtextController.dispose();
    super.onClose();
  }
}
