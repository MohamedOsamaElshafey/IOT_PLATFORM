import 'package:casper_we/libraries.dart';

class UserDevicesscreenpage extends StatelessWidget {
  const UserDevicesscreenpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Devices')),
      body: const Center(
        child: Text('List of user devices will be shown here.'),
      ),
    );
  }
}
