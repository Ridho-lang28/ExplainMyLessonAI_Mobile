import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Auto-detect backend URL: coba emulator (10.0.2.2) dulu, fallback ke IP LAN PC
  // Ini memastikan reset poin & sinkronisasi bekerja di HP fisik maupun emulator
  await ApiService.initBaseUrl();

  // Set system navigation & status bar style (Dana / Modern Fintech style)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ExplainMyLessonApp());
}

class ExplainMyLessonApp extends StatefulWidget {
  const ExplainMyLessonApp({super.key});

  @override
  State<ExplainMyLessonApp> createState() => _ExplainMyLessonAppState();
}

class _ExplainMyLessonAppState extends State<ExplainMyLessonApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        if (_appState.isLoading) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppTheme.danaBlue,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("🤖", style: TextStyle(fontSize: 64)),
                    SizedBox(height: 16),
                    Text(
                      "ExplainMyLesson",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Ruang Belajar Pintar Siswa SD",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: "ExplainMyLesson SD",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _appState.themeMode,
          home: _appState.isLoggedIn
              ? MainNavigationScreen(state: _appState)
              : LoginScreen(state: _appState),
        );
      },
    );
  }
}
