import 'package:casper_we/libraries.dart';

class RegisterScreen extends GetView<RegisterationFormController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Create TextEditingController for each field

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO IMAGE
                  Image.asset(
                    'assets/Casper-we.png', // <-- Your logo here
                    height: 150,
                  ),

                  const SizedBox(height: 10),

                  // APP NAME
                  const Text(
                    "CASPER-WE",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C6BA4),
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // TITLE
                  const Text(
                    "Create Your Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  // FULL NAME
                  TextField(
                    controller: controller.nametextController,
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // registerationFormController.name.value = value,
                    },
                  ),

                  const SizedBox(height: 15),

                  // EMAIL
                  TextField(
                    controller: controller.emailtextController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      //  controller.email.value = value;
                    },
                  ),

                  const SizedBox(height: 15),

                  // PASSWORD
                  TextField(
                    controller: controller.passwordtextController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // registerationFormController.password.value = value;
                    },
                  ),

                  const SizedBox(height: 15),

                  // CONFIRM PASSWORD
                  TextField(
                    controller: controller.retypePasswordtextController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Retype Password",
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      //  registerationFormController.retypePassword.value = value;
                    },
                  ),

                  const SizedBox(height: 30),

                  // REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.register_button();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4FA3D1), Color(0xFF1C6BA4)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            "REGISTER",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LOGIN TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Get.to(LoginScreen());
                        },
                        child: const Text(
                          "Log In",
                          style: TextStyle(
                            color: Color(0xFF1C6BA4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
