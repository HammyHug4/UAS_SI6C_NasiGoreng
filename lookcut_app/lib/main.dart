import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:lookcut_app/l10n/generated/app_localizations.dart';
import 'package:lookcut_app/provider/language_provider.dart';
import 'package:lookcut_app/provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await ThemeProvider.instance.initializeTheme();
  await LanguageProvider.instance.initializeLanguage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.instance;
    final languageProvider = LanguageProvider.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([
        themeProvider,
        languageProvider,
      ]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LookCut Maps',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.currentTheme,
          locale: languageProvider.currentLocale,
          supportedLocales:
              AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const HomeScreen();
              }

              return const SignInScreen();
            },
          ),
        );
      },
    );
  }
}
