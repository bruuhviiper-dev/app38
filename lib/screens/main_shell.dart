import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../data/verses.dart';
import '../l10n/strings.dart';
import '../shared/widgets/app_bottom_nav.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'image_editor_screen.dart';
import 'settings_screen.dart';

/// Casca principal com as 4 abas: Início, Categorias, Favoritos, Mais.
/// Mantém o estado de cada aba (IndexedStack). Na Início, um botão "Criar
/// imagem" abre o editor com a frase do dia.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeBody(onOpenCategories: () => _select(1)),
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
      bottomNavigationBar:
          AppBottomNav(currentIndex: _index, onTap: _select),
    );
  }
}
