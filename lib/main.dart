import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gorala/bloc/repositories/authentication_repository.dart';
import 'package:gorala/screens/main/main_screen.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'gorala',
      theme: ThemeData(),
      home: RepositoryProvider(
          create: (context) => AuthenticationRepository(), child: MainScreen()),
    );
  }
}
