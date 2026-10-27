import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/landscapes.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../shared/widgets/brand_logo.dart';
import '../shared/widgets/landscape_image.dart';
import 'main_shell.dart';

/// Boas-vindas (3 páginas): foto + logo + mensagem. "Pular" ou "Começar"
/// concluem e abrem o app. O estado é persistido (não reaparece).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    context.read<AppState>().completeOnboarding();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final slides = <(String, String)>[
      (Landscapes.onboarding, t.onbSubtitle),
      (Landscapes.hero, t.onbSub2),
      (Landscapes.inspiration[2], t.onbSub3),
    ];
    final isLast = _page == slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => _Slide(
              asset: slides[i].$1,
              subtitle: slides[i].$2,
              appName: t.appName,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.x2),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(t.skip,
                          style: AppTextStyles.button
                              .copyWith(color: Colors.white)),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? AppColors.gold
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x5),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.x6, 0,
                      AppSpacing.x6, AppSpacing.x7),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLast
                          ? _finish
                          : () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOut,
                              ),
                      child: Text(isLast ? t.start : t.next),
                    ),
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

class _Slide extends StatelessWidget {
  const _Slide({
    required this.asset,
    required this.subtitle,
    required this.appName,
  });

  final String asset;
  final String subtitle;
  final String appName;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        LandscapeImage(asset: asset),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x66040C16), Color(0x99040C16), Color(0xF2040C16)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.x6, 0, AppSpacing.x6, 170),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BrandLogo(size: 60),
              const SizedBox(height: AppSpacing.x5),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.inspQuote.copyWith(
                      color: Colors.white, fontSize: 18, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
