import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../shared/widgets/brand_logo.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

/// Splash da marca (navy + logo dourado). Após uma breve pausa, abre o
/// Onboarding (primeira vez) ou direto o app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), _go);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _go() {
    if (!mounted) return;
    final done = context.read<AppState>().onboardingDone;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => done ? const MainShell() : const OnboardingScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bg2, AppColors.bg],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandLogo(size: 84),
              const SizedBox(height: AppSpacing.x4),
              Text(t.splashTagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
