import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gorala/bloc/repositories/authentication_repository.dart';
import 'package:gorala/constants.dart';
import 'package:gorala/screens/loading/loading_screen.dart';
import 'package:gorala/screens/login/login_view.dart';
import 'package:gorala/screens/main/main_screen.dart';
import 'package:gorala/screens/tasks/create_task_view.dart';
import 'package:gorala/screens/tasks/edit_task_view.dart';

import 'bloc/cubits/auth_cubit.dart';
import 'bloc/cubits/task_cubit.dart';
import 'bloc/repositories/task_repository.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => AuthCubit(AuthRepository())), BlocProvider(create: (context) => TaskCubit(TaskRepository()))],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: kTitleTextColor,
          accentColor: kTitleTextColor,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: TextButton.styleFrom(backgroundColor: kTitleTextColor),
          ),
        ),
        title: 'gorala',
        initialRoute: '/',
        routes: {
          '/': (context) => _buildEntryScreen(),
          '/add': (context) => const CreateTaskView(),
          '/edit': (context) => const EditTaskView(),
        },
      ),
    );
  }

  Widget _buildEntryScreen() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Foreign) {
          return LoginView();
        } else if (state is AuthLoading) {
          return LoadingView();
        } else if (state is AuthError) {
          return LoginView(errorMessage: state.message, userName: state.username);
        } else if (state is Authenticated) {
          return MainScreen();
        } else {
          return LoginView(errorMessage: "Weird things are happening..");
        }
      },
    );
  }
}
