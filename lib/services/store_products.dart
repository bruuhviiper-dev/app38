/// Produto da loja. O único é "remover anúncios" (compra única), id `no_ads` —
/// mesmo padrão do app2 "Frases para Status" e do app26.
class StoreProduct {
  const StoreProduct(this.id, {this.fallbackPrice = ''});
  final String id;

  /// Preço de reserva se a Play ainda não retornou (vazio = mostra sem preço;
  /// NUNCA chumbar R$ — o preço real vem localizado da Play).
  final String fallbackPrice;
}

class StoreProducts {
  StoreProducts._();
  static const removeAds = StoreProduct('no_ads');
  static const all = <StoreProduct>[removeAds];
  static Set<String> get ids => {for (final p in all) p.id};
}
