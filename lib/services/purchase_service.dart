import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'app_state.dart';
import 'store_products.dart';

enum PurchaseResult { success, pending, failed, unavailable }

/// Compras In-App (Play/App Store). Produto único "remover anúncios" (no_ads),
/// compra única (não consumível). Concede o direito no [AppState] ao confirmar.
class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, ProductDetails> _products = {};
  AppState? _appState;

  /// Chame no startup. Ouve o fluxo de compras e carrega os produtos.
  Future<void> init(AppState appState) async {
    _appState = appState;
    final available = await _iap.isAvailable();
    if (!available) return;
    _sub ??= _iap.purchaseStream.listen(
      _onPurchases,
      onError: (_) {},
    );
    final response = await _iap.queryProductDetails(StoreProducts.ids);
    for (final p in response.productDetails) {
      _products[p.id] = p;
    }
    // Restaura compras anteriores (não-consumíveis).
    await _iap.restorePurchases();
  }

  /// Preço localizado do produto (vindo da loja); vazio se ainda não carregou.
  String priceOf(String id) =>
      _products[id]?.price ??
      StoreProducts.all.firstWhere((p) => p.id == id).fallbackPrice;

  Future<PurchaseResult> buy(String id) async {
    if (!await _iap.isAvailable()) return PurchaseResult.unavailable;
    final product = _products[id];
    if (product == null) return PurchaseResult.unavailable;
    final param = PurchaseParam(productDetails: product);
    try {
      final ok = await _iap.buyNonConsumable(purchaseParam: param);
      return ok ? PurchaseResult.pending : PurchaseResult.failed;
    } catch (_) {
      return PurchaseResult.failed;
    }
  }

  Future<void> restore() => _iap.restorePurchases();

  void _onPurchases(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _appState?.grantEntitlement(p.productID);
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
