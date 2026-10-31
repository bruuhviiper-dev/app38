import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Consentimento de privacidade (UMP — Google User Messaging Platform). Coleta
/// o consentimento quando exigido (ex.: Europa/GDPR) ANTES de carregar anúncios.
/// Configure o formulário no painel do AdMob (Privacidade e mensagens).
class ConsentService {
  ConsentService._();

  /// Reúne o consentimento (se necessário) e chama [onCanRequestAds] quando já
  /// é permitido pedir anúncios. Nunca bloqueia o app: em erro, segue mesmo assim.
  static void gather(void Function() onCanRequestAds) {
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
            await _maybeRequestAds(onCanRequestAds);
          });
        } catch (_) {
          onCanRequestAds();
        }
      },
      (error) => onCanRequestAds(), // falha na atualização: segue sem bloquear
    );
  }

  static Future<void> _maybeRequestAds(void Function() onCanRequestAds) async {
    try {
      if (await ConsentInformation.instance.canRequestAds()) {
        onCanRequestAds();
      } else {
        onCanRequestAds(); // ainda assim inicializa (anúncios não-personalizados)
      }
    } catch (_) {
      onCanRequestAds();
    }
  }
}
