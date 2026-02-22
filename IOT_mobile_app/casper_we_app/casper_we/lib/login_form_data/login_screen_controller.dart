import 'package:casper_we/libraries.dart';
import 'package:http/http.dart' as http;

class LoginScreenController extends GetxController {
  var email = "".obs;
  var password = "".obs;
  var server_response = "".obs;

  final emailtextController = TextEditingController();
  final passwordtextController = TextEditingController();

  //this function is called after receiving the response from the server to show success or error messages based on the login result
  Future<void> login_process() async {
    email.value = emailtextController.text.trim();
    password.value = passwordtextController.text;
    await check_login_data();
    log(
      'Login process completed with server response: ${server_response.value}',
    );
    if (server_response.value.contains("LOGIN_SUCCESS")) {
      await showToast(message: "Login successful");
      Get.toNamed('/userdevices'); // Navigate to user devices page
    } else if (server_response.value.contains(
      "Account not verified. Please verify your email",
    )) {
      showToast(message: "Account not verified");
      showToast(message: "Please verify your email");
    } else if (server_response.value.contains("Invalid password")) {
      showToast(message: "Invalid password");
    } else if (server_response.value.contains("You are not registered")) {
      showToast(message: "You are not registered");
    } else {}
  }

  //this function is called when the user clicks the login button, it checks if the fields are not empty and then sends the login request to the server
  Future<void> check_login_data() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      await showToast(message: "all fields are required");
    } else {
      await send_http_user_login_data(email.value, password.value);
    }
  }

  Future<void> send_http_user_login_data(String email, String password) async {
    Map<String, String> formData = {'email': email, 'password': password};

    String url = "${globalvariables.serverUrl.value}/login.php";

    try {
      var response = await http.post(
        Uri.parse(url),
        body: formData,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );
      server_response.value = response.body;

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      // FIX: Check the actual response from your PHP
      if (response.statusCode == 200) {
        // Your PHP returns plain text, so check the text content
      }
    } catch (error) {
      loadingOverlayController.hide();
      log('Error during registration: $error');
      showToast(message: "Network error: Please check connection");
    }
  }
}
