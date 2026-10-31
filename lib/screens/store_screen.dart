import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../l10n/strings.dart';
import '../services/ads_service.dart';
import '../services/app_state.dart';
import '../services/purchase_service.dart';
import '../services/store_products.dart';

/// Loja enxuta: produto único "Remover anúncios" (compra única, no_ads) +
/// opção de assistir um vídeo p/ 24h sem anúncios. Todo o resto é grátis.
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  Future<void> _buy(BuildContext context) async {
    final t = T.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t.processing)));
    final res = await PurchaseService.instance.buy(StoreProducts.removeAds.id);
    if (!context.mounted) return;
    // sucesso real chega pelo stream (grantEntitlement); aqui só feedback de erro
    if (res == PurchaseResult.failed || res == PurchaseResult.unavailable) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.purchaseFailed)));
    }
  }

  Future<void> _watchVideo(BuildContext context) async {
    final t = T.of(context);
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final granted = await AdsService.instance.showRewarded(() {
      state.grantTemporaryPro(const Duration(hours: 24));
    });
    if (!context.mounted) return;
    if (granted) {
      messenger.showSnackBar(SnackBar(content: Text(t.adFreeFor24h)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    final removed = state.adsRemoved;
    final price = PurchaseService.instance.priceOf(StoreProducts.removeAds.id);

    return Scaffold(
      appBar: AppBar(title: Text(t.removeAdsTitle), backgroundColor: p.bg),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 20,
            AppSpacing.screenPadding, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.x6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bg2, AppColors.surfaceHigh],
              ),
              borderRadius: BorderRadius.circular(AppRadii.hero),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.goldPill,
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                  ),
                  child: Icon(removed ? LucideIcons.check : LucideIcons.ban,
                      color: AppColors.gold, size: 26),
                ),
                const SizedBox(height: 14),
                Text(removed ? t.adsRemovedTitle : t.removeAdsHero,
                    style: AppTextStyles.heroQuote
                        .copyWith(color: Colors.white, fontSize: 23)),
                const SizedBox(height: 8),
                Text(removed ? t.adsRemovedDesc : t.removeAdsDesc,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
                if (!removed) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _buy(context),
                      child: Text(price.isEmpty
                          ? t.removeAdsCta
                          : '${t.removeAdsCta}  •  $price'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _watchVideo(context),
                      icon: const Icon(LucideIcons.play, size: 18),
                      label: Text(t.watchVideoAdFree),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () => PurchaseService.instance.restore(),
                      child: Text(t.restorePurchase,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.gold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: p.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.freeBenefitsTitle,
                    style: AppTextStyles.overline
                        .copyWith(color: AppColors.gold)),
                const SizedBox(height: 12),
                for (final (icon, label) in <(IconData, String)>[
                  (LucideIcons.moon, t.benefitThemes),
                  (LucideIcons.wand, t.benefitEditor),
                  (LucideIcons.layoutGrid, t.benefitContent),
                  (LucideIcons.globe, t.benefitOffline),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: AppColors.gold),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(label,
                              style: AppTextStyles.body
                                  .copyWith(color: p.textPrimary)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
