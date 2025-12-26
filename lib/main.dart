import 'package:flutter/material.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await AppSetup.setupLocator();

  await Supabase.initialize(
    url: dotenv.env['YOUR_SUPABASE_URL'] ?? "Error",
    anonKey: dotenv.env['YOUR_SUPABASE_PUBLISHABLE_KEY'] ?? "Error",
  );

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
