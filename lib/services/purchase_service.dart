import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'diamond_service.dart';

/// Google Play In-App Billing servisi
class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  // ⚠️ Bu ID'leri Google Play Console'da oluşturduğunuzla eşleştirin
  static const Map<String, int> productDiamonds = {
    'tarotify_diamonds_100': 100,
    'tarotify_diamonds_300': 300,
    'tarotify_diamonds_700': 700,
    'tarotify_diamonds_2000': 2000,
  };

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    // Purchase akışını dinle
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) => debugPrint('IAP Error: $error'),
    );

    // Ürünleri yükle
    final response = await _iap.queryProductDetails(productDiamonds.keys.toSet());
    if (response.error == null) {
      _products = response.productDetails;
      // Fiyata göre sırala
      _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) return false;
    final param = PurchaseParam(productDetails: product);
    return await _iap.buyConsumable(purchaseParam: param);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Elmasları ver
        final diamonds = productDiamonds[purchase.productID];
        if (diamonds != null) {
          await DiamondService.instance.earn(diamonds);
        }
        // Satın alımı onayla
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase Error: ${purchase.error}');
      }
    }
  }

  void dispose() => _subscription.cancel();
}
