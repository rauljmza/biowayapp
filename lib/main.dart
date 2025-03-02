import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Se requiere para SystemChrome y DeviceOrientation
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:biowayapp/services/auth_service.dart';
import 'package:biowayapp/services/notification_service.dart';
import 'package:biowayapp/screens/splash_screen.dart';
import 'package:biowayapp/screens/auth/login_screen.dart';
import 'package:biowayapp/screens/auth/register_screen.dart';
import 'package:biowayapp/screens/home/main_activity.dart';
import 'package:biowayapp/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bloquea la orientación horizontal, permitiendo únicamente el modo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  await NotificationService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Eliminamos el constructor const para evitar el error
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'BioWay',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/main_activity': (context) => MainActivity(),
          // '/recolector_dashboard': (context) => RecolectorDashboard(),
        },
      ),
    );
  }
}
