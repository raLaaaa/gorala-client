import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gorala/bloc/repositories/authentication_repository.dart';
import 'package:gorala/constants.dart';
import 'package:gorala/screens/loading/loading_screen.dart';
import 'package:gorala/screens/login/forgot_password_view.dart';
import 'package:gorala/screens/login/login_view.dart';
import 'package:gorala/screens/login/successful_reset_request.dart';
import 'package:gorala/screens/main/main_screen.dart';
import 'package:gorala/screens/registration/registration_view.dart';
import 'package:gorala/screens/registration/successful_registration_view.dart';
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
        onGenerateRoute: generateRoute,
        initialRoute: '/',
      ),
    );
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) =>  _buildEntryScreen(settings.arguments),);
      case '/success':
        return MaterialPageRoute(builder: (_) => SuccessfulRegistrationView(),);
      case '/successreset':
        return MaterialPageRoute(builder: (_) => SuccessfulResetView(),);
      case '/register':
        return MaterialPageRoute(builder: (_) => _buildRegisterScreen(settings.arguments),);
      case '/resetpassword':
        return MaterialPageRoute(builder: (_) => _buildForogtPasswordScreen(settings.arguments),);
      case '/add':
        return MaterialPageRoute(builder: (_) => _buildCreateTaskScreen(settings.arguments),);
      case '/edit':
        return MaterialPageRoute(builder: (_) => _buildEditTaskScreen(settings.arguments),);

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }

  Widget _buildEntryScreen(args) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Foreign) {
          return LoginView();
        } else if (state is AuthLoading) {
          return LoadingView();
        } else if (state is AuthError) {
          return LoginView(errorMessage: state.message, userName: state.username);
        } else if (state is Authenticated) {
          return MainScreen(args: args);
        } else {
          return LoginView(errorMessage: "Weird things are happening..");
        }
      },
    );
  }

  Widget _buildCreateTaskScreen(args) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Foreign) {
          return LoginView();
        } else if (state is AuthLoading) {
          return LoadingView();
        } else if (state is AuthError) {
          return LoginView(errorMessage: state.message, userName: state.username);
        } else if (state is Authenticated) {
          return CreateTaskView(args: args);
        } else {
          return LoginView(errorMessage: "Weird things are happening..");
        }
      },
    );
  }

  Widget _buildForogtPasswordScreen(args) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Foreign) {
          return ForgotPasswordView();
        } else if (state is Authenticated) {
          return _buildEntryScreen(args);
        } else if (state is AuthLoading) {
          return LoadingView();
        } else if (state is AuthError) {
          return ForgotPasswordView();
        } else {
          return LoginView(errorMessage: "Weird things are happening..");
        }
      },
    );
  }

  Widget _buildRegisterScreen(args) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Foreign) {
          return RegistrationView();
        } else if (state is Authenticated) {
          return _buildEntryScreen(args);
        } else if (state is AuthLoading) {
          return LoadingView();
        } else if (state is AuthError) {
          return RegistrationView();
        } else {
          return LoginView(errorMessage: "Weird things are happening..");
        }
      },
    );
  }

  Widget _buildEditTaskScreen(args) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Foreign) {
          return LoginView();
        } else if (state is AuthLoading) {
          return LoadingView();
        } else if (state is AuthError) {
          return LoginView(errorMessage: state.message, userName: state.username);
        } else if (state is Authenticated) {
          return EditTaskView(args: args);
        } else {
          return LoginView(errorMessage: "Weird things are happening..");
        }
      },
    );
  }
}
