import 'package:get/get.dart';
import 'package:kalapuna/template/modules/example/example_controller.dart';

class ExampleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExampleController());
  }

}