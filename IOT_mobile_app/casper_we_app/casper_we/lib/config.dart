import 'package:casper_we/libraries.dart';

//String serverUrl = 'https://server.casper-we.site/register.php';
//String serverUrl = 'http://10.19.41.149:80/register.php'; //for local testing

class Globalvariables extends GetxController {
  // This class can hold any global variables or methods you want to access across the app
  // For example, you can store the server URL here if you want to change it easily in one place
  var password = "".obs;
  var name = "".obs;
  var email = "".obs;
  var serverUrl = 'http://192.168.1.18:80'.obs;
  //var serverUrl = 'http://10.19.41.149:80'.obs;
}

final globalvariables = Get.put(Globalvariables());
