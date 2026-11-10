import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../services/ads_service.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../shared/widgets/banner_ad.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'image_editor_screen.dart';
import 'settings_screen.dart';

/// Casca principal com as 4 abas: Início, Categorias, Favoritos, Mais.
/// Banner nas listas; intersticial ao trocar de aba (com trava no AdsService);
/// FAB "Criar imagem" na Início.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _select(int i) {
    setState(() => _index = i);
    AdsService.instance.registerActionAndMaybeShow();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final showBanner = _index == 1 || _index == 2;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeBody(),
          const CategoriesScreen(),
          const FavoritesScreen(),
          const SettingsScreen(),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ImageEditorScreen(verse: VerseData.ofToday(t.lang)),
                ),
              ),
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.bg,
              tooltip: t.createImage,
              child: const Icon(LucideIcons.imagePlus),
            )
          : null,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBanner) const BannerAdWidget(),
          AppBottomNav(currentIndex: _index, onTap: _select),
        ],
      ),
    );
  }
}
