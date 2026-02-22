import 'package:casper_we/libraries.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Casper-We Login',
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          binding: LoginScreenControllerBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          binding: RegisterationScreenControllerBinding(),
        ),
        GetPage(
          name: '/verify-otp',
          page: () => const OtpVerificationPage(),
          binding: VerifyOtpScreenControllerBinding(),
        ),
        GetPage(
          name: '/userdevices',
          page: () => const UserDevicesscreenpage(),
          binding: UserDevicesPageControllerBinding(),
        ),
      ],
      initialRoute: '/login',
    );
  }
}
