import 'package:flutter/material.dart';
import 'package:passman/screens/first_screen.dart';
import 'package:passman/screens/home_page.dart';
import 'package:passman/screens/splash_screen.dart';
import 'package:passman/settings/settings_controller.dart';
import 'package:passman/settings/settings_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:passman/support/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();
  runApp(MyApp(settingsController: settingsController));
}

const String set = "/settings";

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  final SettingsController settingsController;

  const MyApp({Key? key, required this.settingsController}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  // Locale? _locale;
  //
  // void setLocale(Locale value) {
  //   Future.delayed(Duration.zero, () {
  //     setState(() {
  //       _locale = value;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'PassMan',
            restorationScopeId: 'app',
            localeListResolutionCallback: (locales, supportedLocales) {
              // print('device locales=$locales supported locales=$supportedLocales');
              for (Locale locale in locales!) {
                if (supportedLocales.contains(locale)) {
                  debugPrint('supported');
                  return locale;
                }
              }
              return const Locale('en', '');
            },
            supportedLocales: const [
              Locale('en', ''),
              Locale('cs', 'CZ'),
            ],
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: Themes.lightTheme,
            darkTheme: Themes.darkTheme,
            themeMode: widget.settingsController.themeMode,
            onGenerateRoute: generateRoute,
            initialRoute: '/',
            routes: {
              // '/auth': (context) => RisetPasswordScreen(),
              '/home': (context) => HomePage(settingsController: widget.settingsController,),
              '/': (context) => SplashScreen(settingsController: widget.settingsController,),
              // '/second': (context) => SecondPage(),
            },
          );
        });
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    var uri = Uri.parse(settings.name!);
    switch (uri.path) {
      case HomePage.route:
        // Prolnuti je lepsi prechod nez default
        return MaterialPageRoute(
            builder: (_) => HomePage(
                  settingsController: widget.settingsController,
                ));
      default:
        return MaterialPageRoute(builder: (_) => const FirstScreen());
    }
  }
}
