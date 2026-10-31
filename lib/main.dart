import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'l10n/strings.dart';
import 'screens/splash_screen.dart';
import 'services/ads_service.dart';
import 'services/app_state.dart';
import 'services/consent_service.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'services/widget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  final prefs = await SharedPreferences.getInstance();
  final appState = AppState(prefs);
  runApp(FrasesDiariasApp(appState: appState));

  // Monetização: compras (no_ads) + anúncios após o consentimento (UMP).
  AdsService.instance.adsRemoved = appState.adsRemoved;
  PurchaseService.instance.init(appState);
  ConsentService.gather(() => AdsService.instance.init());

  // Idioma atual (override ou do aparelho) para notificação + widget.
  final device = WidgetsBinding.instance.platformDispatcher.locale;
  final loc = appState.localeOverride ?? T.resolve(device, T.supportedLocales);
  final t = T(loc);

  // Atualiza o widget de tela inicial com a frase do dia.
  await WidgetService.updateDailyQuote(lang: t.lang, appName: t.appName);

  // Reagenda o lembrete diário (se ligado) com o idioma atual.
  if (appState.notificationsOn) {
    await NotificationService.instance.scheduleDaily(
      title: t.appName,
      body: t.notifBody,
    );
  }
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
