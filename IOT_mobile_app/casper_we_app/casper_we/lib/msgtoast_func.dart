import 'libraries.dart';

Future<void> showToast({required String message}) async {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: Color.fromRGBO(0, 0, 0, 0.8), // Black with 80% opacity
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
