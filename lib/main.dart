import 'package:cianfafire/_core/my_colors.dart';
import 'package:cianfafire/authentication/screens/auth_screen.dart';
import 'package:cianfafire/firestore/presentation/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // linha que precisa ser adicionada porque transformamos nossa main em assincrona
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  // firestore.collection("Só para testar").doc("Estou testando").set({
  //   "funcionou?": true,
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listin - Lista Colaborativa',
      theme: ThemeData(
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: MyColors.red,
          ),
          listTileTheme: const ListTileThemeData(
            iconColor: MyColors.blue,
          ),
          appBarTheme: const AppBarTheme(
            toolbarHeight: 72,
            centerTitle: true,
            elevation: 0,
            backgroundColor: MyColors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          )),
      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
