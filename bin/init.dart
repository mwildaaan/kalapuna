import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:recase/recase.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';


Future<void> main(List<String> args) async {
  var location = Platform.script.toString();

  var isNewFlutter = location.contains(".snapshot");
  if (isNewFlutter) {
    var sp = Platform.script.toFilePath();
    var sd = sp.split(Platform.pathSeparator);
    sd.removeLast();
    var scriptDir = sd.join(Platform.pathSeparator);
    var packageConfigPath = [scriptDir, '..', '..', '..', 'package_config.json'].join(Platform.pathSeparator);
    // print(packageConfigPath);
    var jsonString = File(packageConfigPath).readAsStringSync();
    // print(jsonString);
    Map<String, dynamic> packages = jsonDecode(jsonString);
    var packageList = packages["packages"];
    String? packageUri;
    for (var package in packageList) {
      if (package["name"] == "kalapuna") {
        packageUri = package["rootUri"];
        break;
      }
    }
    if (packageUri == null) {
      print("error uri");
      return;
    }
    if (packageUri.contains("../../")) {
      packageUri = packageUri.replaceFirst("../", "");
      packageUri = path.absolute(packageUri, "");
    }
    if (packageUri.contains("file:///")) {
      packageUri = packageUri.replaceFirst("file://", "");
      packageUri = path.absolute(packageUri, "");
    }
    location = packageUri;
  }

  ReCase rc = ReCase("DashboardHome");
  String appRootFolder = path.absolute("", "");
  String libPath = "$location/lib";
  String templatePath = "$libPath/template/modules/example";
  String modulesAppPath = "$appRootFolder/lib/modules/${rc.snakeCase}";

  var pubFile = File("$appRootFolder/pubspec.yaml");
  var doc = loadYaml(pubFile.readAsStringSync());
  String appName = doc['name'];

  File mainFile = await File("$appRootFolder/lib/main.dart").create(recursive: true);
  String mainContent = await createFile("$libPath/template/main.dart", rc, appName);
  mainFile.writeAsStringSync(mainContent);

  var list = await dirContents(Directory(templatePath));
  for (var element in list) {
    // CREATE DIRECTORY
    if (element.toString().contains("Directory")) {
      var newFolder = "$modulesAppPath${element.path.replaceFirst(templatePath, "")}";
      if (!Directory(newFolder).existsSync()) {
        print("CREATE FOLDER => $newFolder");
        Directory(newFolder).createSync(recursive: true);
      }
    } else {
      String fileContent = await createFile(element.path, rc, appName);
      var newFile = "$modulesAppPath${element.path.replaceFirst(templatePath, "").replaceAll("example", rc.snakeCase).replaceFirst(".stub", "")}";
      print("CREATE FILE => $newFile");
      var file = await File(newFile).create(recursive: true);
      file.writeAsStringSync(fileContent);
      // File(newFile).writeAsStringSync(fileContent);

      // break;
    }
  }

  //Append routes
  String appendContentImportAppPages = """
import 'package:$appName/modules/${rc.snakeCase}/${rc.snakeCase}_page.dart';
import 'package:$appName/modules/${rc.snakeCase}/${rc.snakeCase}_binding.dart';
""";
  String appendContentAppPages = """
GetPage(
      name: AppRoutes.${rc.camelCase},
      page: () => ${rc.pascalCase}Page(),
      binding: ${rc.pascalCase}Binding(),
    ),
""";

  String appendContentAppRoutes = """
static const ${rc.camelCase} = "/${rc.camelCase}";
""";

  String pagesAppPath = "$appRootFolder/lib/routes";
  if (!Directory(pagesAppPath).existsSync()) {
    print("CREATE FOLDER => $pagesAppPath");
    Directory(pagesAppPath).createSync(recursive: true);
  }

  //Create Pages
  String pagesFilePath = "$pagesAppPath/app_pages.dart";
  File pagesFile = File(pagesFilePath);
  if(!pagesFile.existsSync()){
    pagesFile = await pagesFile.create();
    String pagesContent = await createFile("$libPath/template/routes/app_pages.dart", rc, appName);
    pagesFile.writeAsStringSync(pagesContent);
  }else{
    String pagesFileContent = pagesFile.readAsStringSync();
    String newFilePagesContent = pagesFileContent
        .replaceAll("//Add AppPages Don't Remove This Line", "$appendContentAppPages    //Add AppPages Don't Remove This Line")
        .replaceAll("//Add import AppPages Don't Remove This Line", "$appendContentImportAppPages//Add import AppPages Don't Remove This Line");
    if(!pagesFileContent.contains(appendContentImportAppPages)){
      pagesFile.writeAsStringSync(newFilePagesContent);
    }
  }


  //Create Routes
  String routesFilePath = "$pagesAppPath/app_routes.dart";
  File routesFile = File(routesFilePath);
  if(!routesFile.existsSync()){
    routesFile = await routesFile.create();
    String routesContent = await createFile("$libPath/template/routes/app_routes.dart", rc, appName);
    routesFile.writeAsStringSync(routesContent);
  }else{
    String routesFileContent = routesFile.readAsStringSync();
    String newFileRoutesContent = routesFileContent.replaceAll("//Add AppRoutes Don't Remove This Line", "$appendContentAppRoutes  //Add AppRoutes Don't Remove This Line");
    if(!routesFileContent.contains(appendContentAppRoutes)){
      routesFile.writeAsStringSync(newFileRoutesContent);
    }
  }
}

Future<String> createFile(String path, ReCase rc, String appName) async {
  String result = File(path).readAsStringSync();
  result = result.replaceAll("kalapuna", appName);
  result = result.replaceAll("Example", rc.pascalCase);
  result = result.replaceAll("example", rc.snakeCase);
  result = result.replaceAll("EXAMPLE", rc.constantCase);
  result = result.replaceAll("examplE", rc.camelCase);
  result = result.replaceAll("/template", "");
  return result;
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: true);
  lister.listen((file) => files.add(file),
      // should also register onError
      onDone: () => completer.complete(files));
  return completer.future;
}