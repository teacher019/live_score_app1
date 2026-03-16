import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:live_score_app/sign_in_screen.dart';
import 'package:live_score_app/sign_up_screen.dart';

import 'home_screen.dart';

class FootballLiveScoreApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

  const FootballLiveScoreApp({super.key});

  @override
  State<FootballLiveScoreApp> createState() => _FootballLiveScoreAppState();
}

class _FootballLiveScoreAppState extends State<FootballLiveScoreApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // optional: removes debug banner
      title: 'Football Live Score',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          // 🔄 Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Logged-in user
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // 🚪 Not logged in
          return const SignInScreen();
        },
      ),
    );
  }
}