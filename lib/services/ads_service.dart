import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob (Android/iOS): banner, intersticial, app-open e premiado — com travas
/// p/ NÃO incomodar. Hoje usa IDs de TESTE do Google. Na publicação: troque
/// `_useTestAds` p/ false e preencha os IDs reais (e o APP ID no manifest).
/// NUNCA clique nos próprios anúncios reais.
class AdsService with WidgetsBindingObserver {
  AdsService._();
  static final AdsService instance = AdsService._();

  /// Produção: IDs reais. Ligue `true` só p/ testar sem risco de clicar no
  /// próprio anúncio real.
  static const bool _useTestAds = false;
  static const bool _fullScreenAdsEnabled = true;

  // IDs de TESTE oficiais do Google
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const _testAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const _testNative = 'ca-app-pub-3940256099942544/2247696110';

  // IDs REAIS — Frases Diárias (AdMob app ca-app-pub-5880219350817278~5241847601).
  static const _realBanner = 'ca-app-pub-5880219350817278/8201559573';
  static const _realInterstitial = 'ca-app-pub-5880219350817278/2615684267';
  static const _realRewarded = 'ca-app-pub-5880219350817278/2949232897';
  static const _realAppOpen = 'ca-app-pub-5880219350817278/1636151225';
  static const _realNative = 'ca-app-pub-5880219350817278/2674946906';
  static bool _ph(String id) => id.contains('0000000000');

  bool _initialized = false;
  bool get _supported => Platform.isAndroid || Platform.isIOS;

  /// Sincronizado pelo banner (lê o AppState): pagante não vê anúncios.
  bool adsRemoved = false;

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  AppOpenAd? _appOpenAd;
  DateTime? _lastAppOpenShown;
  bool _showingFullScreenAd = false;

  static const int interstitialEvery = 10;
  int _actionsSinceLastAd = 0;
  DateTime? _lastInterstitialShown;

  String get bannerUnitId =>
      (_useTestAds || _ph(_realBanner)) ? _testBanner : _realBanner;
  String get _interstitialUnitId =>
      (_useTestAds || _ph(_realInterstitial)) ? _testInterstitial : _realInterstitial;
  String get _rewardedUnitId =>
      (_useTestAds || _ph(_realRewarded)) ? _testRewarded : _realRewarded;
  String get _appOpenUnitId =>
      (_useTestAds || _ph(_realAppOpen)) ? _testAppOpen : _realAppOpen;
  String get nativeUnitId =>
      (_useTestAds || _ph(_realNative)) ? _testNative : _realNative;

  /// Chamado depois do consentimento (UMP). Inicializa o SDK e pré-carrega.
  void init() {
    if (_initialized || !_supported) return;
    _initialized = true;
    MobileAds.instance.initialize();
    WidgetsBinding.instance.addObserver(this);
    if (_fullScreenAdsEnabled) {
      _preloadInterstitial();
      _loadAppOpen();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_fullScreenAdsEnabled && state == AppLifecycleState.resumed) {
      maybeShowAppOpen();
    }
  }

  // ----- Premiado (opt-in) -----
  Future<bool> showRewarded(void Function() onReward) async {
    if (!_supported) {
      onReward();
      return true;
    }
    final completer = Completer<bool>();
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          var earned = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) {
              _showingFullScreenAd = true;
              _lastAppOpenShown = DateTime.now();
            },
            onAdDismissedFullScreenContent: (ad) {
              _showingFullScreenAd = false;
              ad.dispose();
              if (!completer.isCompleted) completer.complete(earned);
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              _showingFullScreenAd = false;
              ad.dispose();
              if (!completer.isCompleted) completer.complete(false);
            },
          );
          ad.show(onUserEarnedReward: (ad, reward) {
            earned = true;
            onReward();
          });
        },
        onAdFailedToLoad: (err) {
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    return completer.future;
  }

  // ----- Intersticial -----
  void _preloadInterstitial() {
    if (!_supported || _loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (err) {
          _interstitial = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  /// Conta uma ação e exibe o intersticial ao atingir o limite (intervalo
  /// mínimo de 90s). Nunca para quem removeu anúncios.
  void registerActionAndMaybeShow() {
    if (!_fullScreenAdsEnabled) return;
    if (!_supported || adsRemoved || _showingFullScreenAd) return;
    _actionsSinceLastAd++;
    if (_actionsSinceLastAd < interstitialEvery) return;
    final now = DateTime.now();
    if (_lastInterstitialShown != null &&
        now.difference(_lastInterstitialShown!) < const Duration(seconds: 90)) {
      return;
    }
    final ad = _interstitial;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _showingFullScreenAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _showingFullScreenAd = false;
        ad.dispose();
        _interstitial = null;
        _preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _showingFullScreenAd = false;
        ad.dispose();
        _interstitial = null;
        _preloadInterstitial();
      },
    );
    ad.show();
    _interstitial = null;
    _actionsSinceLastAd = 0;
    _lastInterstitialShown = now;
    _lastAppOpenShown = now; // evita app-open logo após o intersticial
  }

  // ----- App Open (só no retorno ao app) -----
  void _loadAppOpen() {
    if (!_supported || _appOpenAd != null) return;
    AppOpenAd.load(
      adUnitId: _appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => _appOpenAd = ad,
        onAdFailedToLoad: (err) => _appOpenAd = null,
      ),
    );
  }

  void maybeShowAppOpen() {
    if (!_fullScreenAdsEnabled) return;
    if (!_supported || adsRemoved || _showingFullScreenAd) return;
    final now = DateTime.now();
    if (_lastAppOpenShown != null &&
        now.difference(_lastAppOpenShown!) < const Duration(minutes: 4)) {
      return;
    }
    final ad = _appOpenAd;
    if (ad == null) {
      _loadAppOpen();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _showingFullScreenAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _showingFullScreenAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _showingFullScreenAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpen();
      },
    );
    ad.show();
    _appOpenAd = null;
    _lastAppOpenShown = now;
  }
}
