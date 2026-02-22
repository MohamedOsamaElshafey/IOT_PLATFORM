import 'package:casper_we/libraries.dart';

class UserDevicesPageControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserDevicesPageController>(() => UserDevicesPageController());
  }
}
