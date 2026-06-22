import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_score_app/screens/home_screen.dart';
import 'package:live_score_app/screens/sign_in_screen.dart';

import 'analytics_route_observer.dart';
import 'crashlytics-route_observer.dart';
import 'fcm_utils.dart';
import 'firebase_options.dart';
import 'screens/sign_up_screen.dart';

Future<void> main() async {
  // Ensure initialization
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await FcmUtils.initialize();

  print(await FcmUtils.getFcmToken());

  FcmUtils.onRefreshToken();

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          // While in progress
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // When stream hase data(User object)
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // When stream is null
          return const SignInScreen();
        },
      ),
      navigatorObservers: [
        CrashlyticsRouteObserver(),
        AnalyticsRouteObserver(),
      ],
      routes: {
        '/sign-in': (_) => const SignInScreen(),
        '/sign-up': (_) => const SignUpScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}