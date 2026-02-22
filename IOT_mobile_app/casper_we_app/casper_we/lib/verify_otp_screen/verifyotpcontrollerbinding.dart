import 'package:casper_we/libraries.dart';

class VerifyOtpScreenControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
