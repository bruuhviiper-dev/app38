import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'l10n/strings.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  final prefs = await SharedPreferences.getInstance();
  runApp(FrasesDiariasApp(appState: AppState(prefs)));
}

class FrasesDiariasApp extends StatelessWidget {
  const FrasesDiariasApp({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            onGenerateTitle: (ctx) => T.of(ctx).appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            locale: state.localeOverride,
            localizationsDelegates: const [
              TDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: T.supportedLocales,
            localeResolutionCallback: (device, supported) =>
                T.resolve(state.localeOverride ?? device, supported),
            builder: (context, child) {
              // Respeita o tamanho de fonte do SISTEMA (acessibilidade) e
              // combina com o escolhido nas Configurações.
              final mq = MediaQuery.of(context);
              final systemScale = mq.textScaler.scale(1.0);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler:
                      TextScaler.linear(systemScale * state.fontScale),
                ),
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
