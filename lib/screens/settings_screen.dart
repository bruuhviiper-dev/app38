import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/rate_prompt.dart';

/// Endônimos para o seletor de idioma (os não listados mostram o código).
const _endonyms = <String, String>{
  'pt': 'Português', 'en': 'English', 'es': 'Español', 'fr': 'Français',
  'de': 'Deutsch', 'it': 'Italiano', 'nl': 'Nederlands', 'pl': 'Polski',
  'ru': 'Русский', 'uk': 'Українська', 'tr': 'Türkçe', 'ar': 'العربية',
  'fa': 'فارسی', 'he': 'עברית', 'hi': 'हिन्दी', 'bn': 'বাংলা', 'ur': 'اردو',
  'ta': 'தமிழ்', 'te': 'తెలుగు', 'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu',
  'th': 'ไทย', 'vi': 'Tiếng Việt', 'fil': 'Filipino', 'ja': '日本語',
  'ko': '한국어', 'zh': '中文', 'sw': 'Kiswahili', 'el': 'Ελληνικά',
  'sv': 'Svenska', 'ro': 'Română', 'hu': 'Magyar', 'cs': 'Čeština',
};

String _langName(String code) => _endonyms[code] ?? code.toUpperCase();

/// Configurações: preferências reais (idioma, notificações, tema, tamanho da
/// fonte) + ações gerais (sobre, compartilhar, avaliar, privacidade, termos).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    final state = context.watch<AppState>();

    final themeLabel = switch (state.themeMode) {
      ThemeMode.light => t.themeLight,
      ThemeMode.dark => t.themeDark,
      ThemeMode.system => t.themeSystem,
    };
    final fontLabel = state.fontScale <= 0.95
        ? t.fontSmall
        : state.fontScale >= 1.1
            ? t.fontLarge
            : t.fontDefault;
    final langLabel =
        state.localeCode == null ? t.systemDefault : _langName(state.localeCode!);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle), backgroundColor: p.bg),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
            AppSpacing.x2, AppSpacing.screenPadding, AppSpacing.x7),
        children: [
          _SectionLabel(t.preferences),
          _Tile(
            icon: LucideIcons.globe,
            label: t.language,
            value: langLabel,
            onTap: () => _pickLanguage(context, state),
          ),
          _SwitchTile(
            icon: LucideIcons.bell,
            label: t.notificationsLabel,
            desc: t.notificationsDesc,
            value: state.notificationsOn,
            onChanged: (v) {
              context.read<AppState>().setNotificationsOn(v);
            },
          ),
          _Tile(
            icon: LucideIcons.moon,
            label: t.theme,
            value: themeLabel,
            onTap: () => _pickTheme(context, state),
          ),
          _Tile(
            icon: LucideIcons.type,
            label: t.fontSize,
            value: fontLabel,
            onTap: () => _pickFont(context, state),
          ),
          const SizedBox(height: AppSpacing.x4),
          _SectionLabel(t.general),
          _Tile(
            icon: LucideIcons.info,
            label: t.about,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: t.appName,
              applicationVersion: '1.0.0',
              applicationLegalese: '© ${DateTime.now().year} ${t.appName}',
            ),
          ),
          _Tile(
            icon: LucideIcons.share2,
            label: t.shareApp,
            onTap: () => SharePlus.instance.share(
              ShareParams(text: '${t.appName} — ${t.appSubtitle}'),
            ),
          ),
          _Tile(
            icon: LucideIcons.star,
            label: t.rateApp,
            onTap: () => RatePrompt.openReview(),
          ),
          _Tile(
            icon: LucideIcons.shield,
            label: t.privacy,
            onTap: () => _openInfo(context, t.privacy),
          ),
          _Tile(
            icon: LucideIcons.fileText,
            label: t.terms,
            onTap: () => _openInfo(context, t.terms),
          ),
          const SizedBox(height: AppSpacing.x5),
          Center(
            child: Text('${t.version} 1.0.0',
                style: AppTextStyles.caption.copyWith(color: p.textSecondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTheme(BuildContext context, AppState state) async {
    final t = T.of(context);
    final choice = await _chooser<ThemeMode>(
      context,
      title: t.theme,
      options: [
        (ThemeMode.system, t.themeSystem),
        (ThemeMode.light, t.themeLight),
        (ThemeMode.dark, t.themeDark),
      ],
      current: state.themeMode,
    );
    if (choice != null) state.setThemeMode(choice);
  }

  Future<void> _pickFont(BuildContext context, AppState state) async {
    final t = T.of(context);
    final choice = await _chooser<double>(
      context,
      title: t.fontSize,
      options: [
        (0.9, t.fontSmall),
        (1.0, t.fontDefault),
        (1.15, t.fontLarge),
      ],
      current: state.fontScale,
    );
    if (choice != null) state.setFontScale(choice);
  }

  Future<void> _pickLanguage(BuildContext context, AppState state) async {
    const systemSentinel = '__system__';
    final t = T.of(context);
    final options = <(String, String)>[
      (systemSentinel, t.systemDefault),
      for (final code in T.targetLanguages) (code, _langName(code)),
    ];
    final choice = await _chooser<String>(
      context,
      title: t.language,
      options: options,
      current: state.localeCode ?? systemSentinel,
    );
    if (choice == null) return; // dispensado
    state.setLocaleCode(choice == systemSentinel ? null : choice);
  }

  Future<void> _openInfo(BuildContext context, String title) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _InfoScreen(title: title)),
    );
  }
}

Future<E?> _chooser<E>(
  BuildContext context, {
  required String title,
  required List<(E, String)> options,
  required E current,
}) {
  final p = Palette.of(context);
  return showModalBottomSheet<E>(
    context: context,
    backgroundColor: p.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(title,
                  style: AppTextStyles.sectionTitle
                      .copyWith(color: p.textPrimary)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (value, label) in options)
                    ListTile(
                      onTap: () => Navigator.pop(ctx, value),
                      title: Text(label,
                          style: AppTextStyles.body
                              .copyWith(color: p.textPrimary)),
                      trailing: value == current
                          ? const Icon(LucideIcons.check,
                              color: AppColors.gold, size: 20)
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      child: Text(text,
          style: AppTextStyles.overline.copyWith(color: p.textSecondary)),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: p.border),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.gold),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label,
                      style: AppTextStyles.body.copyWith(color: p.textPrimary)),
                ),
                if (value != null)
                  Text(value!,
                      style: AppTextStyles.caption
                          .copyWith(color: p.textSecondary)),
                const SizedBox(width: 6),
                Icon(LucideIcons.chevronRight,
                    size: 18, color: p.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.desc,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: p.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.gold),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          AppTextStyles.body.copyWith(color: p.textPrimary)),
                  Text(desc,
                      style: AppTextStyles.caption
                          .copyWith(color: p.textSecondary)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.bg,
              activeTrackColor: AppColors.gold,
            ),
          ],
        ),
      ),
    );
  }
}

/// Página simples de Política de Privacidade / Termos (texto base do template).
class _InfoScreen extends StatelessWidget {
  const _InfoScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: p.bg),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(
            '${t.appName}\n\n'
            'Este é um texto base do template. O conteúdo definitivo de '
            '"$title" deve ser fornecido antes da publicação na Play Store.\n\n'
            'O aplicativo funciona de forma offline e guarda as suas '
            'preferências e favoritos apenas no seu dispositivo. Não há coleta '
            'de dados pessoais nem envio de informações para servidores.',
            style: AppTextStyles.body.copyWith(
                color: p.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
