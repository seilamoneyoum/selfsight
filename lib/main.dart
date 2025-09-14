import 'package:flutter/material.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:selfsight/presentation/app/app_setup.dart';

Future<void> main() async {
  // Ensure initialization before the app starts
  //await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await AppSetup.setupLocator();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.homeView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
    );
  }
}
