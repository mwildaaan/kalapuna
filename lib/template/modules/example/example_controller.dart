import 'package:get/get.dart';

class ExampleController extends GetxController{

  var count = 0;

  incrementCount() {
    count += 1;
    update();
  }

}