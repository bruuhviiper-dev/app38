import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'rate_prompt.dart';

/// Estado global: favoritos + preferências (tema, idioma, tamanho de fonte,
/// notificações, onboarding). Tudo persistido localmente (SharedPreferences).
/// Favoritar é AÇÃO POSITIVA → alimenta o prompt de avaliação do Google.
class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;

  static const _kFavorites = 'favorites';
  static const _kThemeMode = 'theme_mode';
  static const _kLocale = 'locale_code';
  static const _kFontScale = 'font_scale';
  static const _kNotifications = 'notifications_on';
  static const _kOnboarding = 'onboarding_done';

  final Set<String> _favorites = {};
  ThemeMode _themeMode = ThemeMode.dark;
  String? _localeCode; // null = seguir o aparelho
  double _fontScale = 1.0;
  bool _notificationsOn = false;
  bool _onboardingDone = false;

  // ----- favoritos -----
  Set<String> get favorites => Set.unmodifiable(_favorites);
  bool get hasFavorites => _favorites.isNotEmpty;
  bool isFavorite(String id) => _favorites.contains(id);

  /// Alterna o favorito e persiste. Retorna `true` se ficou FAVORITADO.
  bool toggleFavorite(String id) {
    final bool added;
    if (_favorites.remove(id)) {
      added = false;
    } else {
      _favorites.add(id);
      added = true;
    }
    _prefs.setStringList(_kFavorites, _favorites.toList());
    notifyListeners();
    if (added) RatePrompt.registerPositiveAction();
    return added;
  }

  // ----- tema -----
  ThemeMode get themeMode => _themeMode;
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setInt(_kThemeMode, mode.index);
    notifyListeners();
  }

  // ----- idioma -----
  /// `null` = seguir o idioma do aparelho.
  String? get localeCode => _localeCode;
  Locale? get localeOverride =>
      _localeCode == null ? null : Locale(_localeCode!);
  void setLocaleCode(String? code) {
    _localeCode = code;
    if (code == null) {
      _prefs.remove(_kLocale);
    } else {
      _prefs.setString(_kLocale, code);
    }
    notifyListeners();
  }

  // ----- tamanho da fonte -----
  double get fontScale => _fontScale;
  void setFontScale(double scale) {
    _fontScale = scale;
    _prefs.setDouble(_kFontScale, scale);
    notifyListeners();
  }

  // ----- notificações (preferência; agendamento no NotificationService) -----
  bool get notificationsOn => _notificationsOn;
  void setNotificationsOn(bool on) {
    _notificationsOn = on;
    _prefs.setBool(_kNotifications, on);
    notifyListeners();
  }

  // ----- onboarding -----
  bool get onboardingDone => _onboardingDone;
  void completeOnboarding() {
    _onboardingDone = true;
    _prefs.setBool(_kOnboarding, true);
    notifyListeners();
  }

  void _load() {
    _favorites.addAll(_prefs.getStringList(_kFavorites) ?? const []);
    final tm = _prefs.getInt(_kThemeMode);
    if (tm != null && tm >= 0 && tm < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[tm];
    }
    _localeCode = _prefs.getString(_kLocale);
    _fontScale = _prefs.getDouble(_kFontScale) ?? 1.0;
    _notificationsOn = _prefs.getBool(_kNotifications) ?? false;
    _onboardingDone = _prefs.getBool(_kOnboarding) ?? false;
  }
}
