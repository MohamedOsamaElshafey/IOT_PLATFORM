import 'package:casper_we/libraries.dart';

class RegisterationScreenControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterationFormController>(
      () => RegisterationFormController(),
    );
  }
}
