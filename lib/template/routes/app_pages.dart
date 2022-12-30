import 'package:get/get.dart';
import 'package:kalapuna/template/modules/example/example_binding.dart';
import 'package:kalapuna/template/modules/example/example_page.dart';
import 'package:kalapuna/template/routes/app_routes.dart';
//Add import AppPages Don't Remove This Line

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.examplE,
      page: () => ExamplePage(
        args: ExampleArguments(),
      ),
      binding: ExampleBinding(),
    ),
    //Add AppPages Don't Remove This Line
  ];
}
