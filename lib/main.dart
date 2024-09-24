import 'package:flutter/material.dart';
import 'package:tweaki/chat_screen.dart';
import 'package:tweaki/login_screen.dart';
import 'package:tweaki/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tweaki/welcome_screen.dart';
import 'firebase_options.dart';

/*
Firebase Initialization:
The main() function initializes Firebase by calling
Firebase.initializeApp()
with the default Firebase options.
This ensures Firebase services are ready before running the app.
* */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(TextChat());
}

class TextChat extends StatelessWidget {
  const TextChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}
