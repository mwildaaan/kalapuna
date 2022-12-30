import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalapuna/template/modules/example/example_controller.dart';

class ExampleArguments {
  final String? id;

  ExampleArguments({this.id});
}

class ExamplePage extends StatelessWidget {
  ExampleArguments? args;
  ExamplePage({Key? key, this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    args = Get.arguments;
    return GetBuilder<ExampleController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Example Page"),
          ),
          body: Center(
            child: Text("Example Page ${controller.count}"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              controller.incrementCount();
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
