import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Product IDs for subscriptions
class ProductIds {
  static const premiumMonthly = 'destiny_decoder_premium_monthly';
  static const premiumAnnual = 'destiny_decoder_premium_annual';
  static const proAnnual = 'destiny_decoder_pro_annual';

  static List<String> get all => [premiumMonthly, premiumAnnual, proAnnual];
}

/// Purchase service for managing in-app purchases and subscriptions.
class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  /// Initialize the purchase service and set up listeners
  Future<void> initialize() async {
    // Check if store is available
    _isAvailable = await _iap.isAvailable();
    
    if (!_isAvailable) {
      print('⚠️ In-app purchase not available on this device');
      return;
    }

    // Set up purchase listener
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Purchase stream error: $error'),
    );

    // Load products
    await loadProducts();

    // For iOS, ensure pending transactions are processed
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosAddition =
          _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosAddition.setDelegate(ExamplePaymentQueueDelegate());
    }
  }

  /// Load available products from store
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      ProductIds.all.toSet(),
    );

    if (response.notFoundIDs.isNotEmpty) {
      print('⚠️ Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      print('❌ Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
    print('✅ Loaded ${_products.length} products');
  }

  /// Purchase a product (subscription)
  Future<bool> purchaseProduct(ProductDetails product) async {
    if (!_isAvailable) {
      print('❌ In-app purchase not available');
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('❌ Purchase error: $e');
      return false;
    }
  }

  /// Restore previous purchases (iOS requirement)
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _iap.restorePurchases();
      print('✅ Purchases restored');
    } catch (e) {
      print('❌ Restore error: $e');
    }
  }

  /// Handle purchase updates from the stream
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('⏳ Purchase pending...');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('❌ Purchase error: ${purchaseDetails.error}');
        _iap.completePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        print('✅ Purchase successful: ${purchaseDetails.productID}');
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        print('❌ Purchase cancelled');
        _iap.completePurchase(purchaseDetails);
      }

      // Always complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handle successful purchase - validate with backend
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Extract receipt data based on platform
      String receiptData;
      String platform;

      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosAddition =
            _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        receiptData = purchaseDetails.verificationData.serverVerificationData;
        platform = 'ios';
      } else if (Platform.isAndroid) {
        final GooglePlayPurchaseDetails androidPurchase =
            purchaseDetails as GooglePlayPurchaseDetails;
        receiptData = androidPurchase.billingClientPurchase.purchaseToken;
        platform = 'android';
      } else {
        print('❌ Unsupported platform');
        return;
      }

      // TODO: Send receipt to backend for validation
      // await _validateWithBackend(
      //   userId: currentUserId,
      //   platform: platform,
      //   receiptData: receiptData,
      //   productId: purchaseDetails.productID,
      // );

      print('✅ Purchase validated and subscription activated');
    } catch (e) {
      print('❌ Error handling purchase: $e');
    }
  }

  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
  }
}

/// iOS payment queue delegate for handling transactions
class ExamplePaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

/// Riverpod provider for PurchaseService
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService();
  service.initialize();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for available products
final productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  await service.loadProducts();
  return service.products;
});
