import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalapuna/template/modules/example/example_binding.dart';
import 'package:kalapuna/template/modules/example/example_page.dart';
import 'package:kalapuna/template/routes/app_pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Kalapuna GetX',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialBinding: ExampleBinding(),
      home: ExamplePage(),
      getPages: AppPages.pages,
    );
  }
}
