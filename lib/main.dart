import 'package:chat_online_flutter/controllers/login_controller.dart';
import 'package:chat_online_flutter/views/home/home_screen.dart';
import 'package:chat_online_flutter/views/login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final LoginController lc = Get.put(LoginController());
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //cc.verifyPresense(true);
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat Flutter',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
        ),
        home:
            lc.estaLogado.value ? HomeScreen() : LoginScreen());
  }
}
