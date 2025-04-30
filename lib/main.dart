import 'package:flutter/material.dart';
import 'package:stour/screens/main_screen.dart';
import 'package:stour/util/const.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stour/util/places.dart';
import 'screens/splash_screen.dart';
import 'package:stour/model/place.dart';
import 'package:stour/screens/home.dart';
import 'firebase_options.dart';
import 'package:stour/screens/sign_in.dart';
import 'package:stour/screens/sign_up.dart';
import 'package:stour/screens/role_selection.dart';
import 'package:stour/screens/profile.dart';
import 'package:stour/screens/createMiniGame_screen.dart';
import 'package:stour/screens/coupon_screen.dart';
import 'package:stour/screens/forgot_password.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  getAllPlaceFood('stourplace1');
  getAllPlaceFood('food');
  const GoogleMapsController();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      home: const SplashScreen(),
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      routes: {
        '/home': (context) => const MainScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/role': (context) => const RoleSelectionScreen(),
        '/profile': (context) => const Profile(),
        '/coupon': (context) => const CouponScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
