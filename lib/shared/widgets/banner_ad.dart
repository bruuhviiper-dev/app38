import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:provider/provider.dart';

import '../../services/ads_service.dart';
import '../../services/app_state.dart';

/// Banner adaptativo no rodapé. Some para quem removeu anúncios. Mantém o
/// AdsService.adsRemoved em sincronia com o AppState.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  bool get _supported => Platform.isAndroid || Platform.isIOS;

  Future<void> _load() async {
    if (!_supported || _ad != null) return;
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());
    if (size == null) return;
    final ad = BannerAd(
      size: size,
      adUnitId: AdsService.instance.bannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final removed = context.watch<AppState>().adsRemoved;
    AdsService.instance.adsRemoved = removed;
    if (removed || !_supported) return const SizedBox.shrink();
    if (_ad == null) _load();
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
