import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:jyoti_ai/providers/jyoti_provider.dart';
import 'package:jyoti_ai/theme/app_theme.dart';
import 'package:jyoti_ai/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  runApp(const JyotiApp());
}

class JyotiApp extends StatelessWidget {
  const JyotiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => JyotiProvider())],
      child: Consumer<JyotiProvider>(
        builder: (context, provider, _) {
          final isDark = provider.isDarkMode;

          // Update status bar to match theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor:
                  isDark ? JyotiTheme.surface : JyotiTheme.lightSurface,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'Jyoti AI',
            debugShowCheckedModeBanner: false,
            theme: JyotiTheme.lightTheme,
            darkTheme: JyotiTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
