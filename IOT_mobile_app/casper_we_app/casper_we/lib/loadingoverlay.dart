import 'libraries.dart';

class LoadingOverlay extends StatelessWidget {
  final bool status;
  final Alignment alignment;

  const LoadingOverlay({
    super.key,
    required this.status,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (status == false) {
      return SizedBox.shrink();
    }
    return Container(
      color: Colors.black54,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class LoadingOverlayController extends GetxController {
  var isLoading = false.obs;

  void show() {
    isLoading.value = true;
  }

  void hide() {
    isLoading.value = false;
  }
}

final loadingOverlayController = Get.put(LoadingOverlayController());
