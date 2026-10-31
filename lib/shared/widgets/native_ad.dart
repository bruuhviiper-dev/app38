import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/ads_service.dart';
import '../../services/app_state.dart';

/// Anúncio NATIVO "disfarçado" no feed (template do google_mobile_ads, sem
/// factory nativa). Combina com o tema; some para quem removeu anúncios.
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _ad;
  bool _loaded = false;

  bool get _supported => Platform.isAndroid || Platform.isIOS;

  void _load() {
    if (!_supported || _ad != null) return;
    final p = Palette.of(context);
    _ad = NativeAd(
      adUnitId: AdsService.instance.nativeUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: p.surface,
        cornerRadius: AppRadii.card,
        primaryTextStyle: NativeTemplateTextStyle(
            textColor: p.textPrimary, size: 15),
        secondaryTextStyle: NativeTemplateTextStyle(
            textColor: p.textSecondary, size: 13),
        callToActionTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.bg, backgroundColor: AppColors.gold, size: 14),
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    );
    _ad!.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final removed = context.watch<AppState>().adsRemoved;
    if (removed || !_supported) return const SizedBox.shrink();
    if (_ad == null) _load();
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(minHeight: 280, maxHeight: 340),
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: AdWidget(ad: _ad!),
    );
  }
}
