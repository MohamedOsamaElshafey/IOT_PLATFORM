import 'package:casper_we/libraries.dart';

class LoginScreenControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginScreenController>(() => LoginScreenController());
  }
}
