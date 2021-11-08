import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gorala/bloc/repositories/authentication_repository.dart';
import 'package:gorala/screens/loading/loading_screen.dart';
import 'package:gorala/screens/login/login_view.dart';
import 'package:gorala/screens/main/main_screen.dart';

import 'bloc/cubits/auth_cubit.dart';

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
      home: BlocProvider(
        create: (context) => AuthCubit(AuthRepository()),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Foreign) {
              return LoginView();
            } else if (state is AuthLoading) {
              return LoadingView();
            } else if (state is AuthError) {
              return LoginView(state.message);
            } else if (state is Authenticated) {
              return MainScreen();
            }
            else {
              return LoginView("Weird things are happening..");
            }
          },
        ),
      ),
    );
  }
}
