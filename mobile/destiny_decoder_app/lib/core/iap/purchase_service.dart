import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import '../api/api_client.dart';
import '../api/api_providers.dart';

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
  final ApiClient _apiClient;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  PurchaseService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Initialize the purchase service and set up listeners
  Future<void> initialize() async {
    // Check if store is available
    _isAvailable = await _iap.isAvailable();
    
    if (!_isAvailable) {
      // ignore: avoid_print
      Logger.w('⚠️ In-app purchase not available on this device');
      return;
    }

    // Set up purchase listener
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => Logger.e('Purchase stream error: $error'),
    );

    // Load products
    await loadProducts();

    // iOS transactions are handled automatically by StoreKit
  }

  /// Load available products from store
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      ProductIds.all.toSet(),
    );

    if (response.notFoundIDs.isNotEmpty) {
      Logger.w('⚠️ Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      Logger.e('❌ Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
    Logger.i('✅ Loaded ${_products.length} products');
  }

  /// Purchase a product (subscription)
  Future<bool> purchaseProduct(ProductDetails product) async {
    if (!_isAvailable) {
      Logger.e('❌ In-app purchase not available');
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      Logger.e('❌ Purchase error: $e');
      return false;
    }
  }

  /// Restore previous purchases (iOS requirement)
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _iap.restorePurchases();
      Logger.i('✅ Purchases restored');
    } catch (e) {
      Logger.e('❌ Restore error: $e');
    }
  }

  /// Handle purchase updates from the stream
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        Logger.i('⏳ Purchase pending...');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        Logger.e('❌ Purchase error: ${purchaseDetails.error}');
        _iap.completePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        Logger.i('✅ Purchase successful: ${purchaseDetails.productID}');
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        Logger.i('❌ Purchase cancelled');
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
      // Extract receipt and platform for backend validation
      String? receiptData;
      
      if (Platform.isIOS) {
        receiptData = purchaseDetails.verificationData.serverVerificationData;
        // Send receipt to backend for validation
        await _validateReceiptWithBackend(
          receiptData,
          purchaseDetails.productID,
          'ios',
        );
      } else if (Platform.isAndroid) {
        // Get receipt from Google Play purchase
        receiptData = purchaseDetails.verificationData.serverVerificationData;
        // Send receipt to backend for validation
        await _validateReceiptWithBackend(
          receiptData,
          purchaseDetails.productID,
          'android',
        );
      }
      Logger.i('✅ Purchase completed for ${purchaseDetails.productID}');
    } catch (e) {
      Logger.e('❌ Error handling purchase: $e');
    }
  }
  
  /// Send receipt to backend for validation
  Future<void> _validateReceiptWithBackend(
    String receiptData,
    String productId,
    String platform,
  ) async {
    try {
      Logger.i('📤 Validating receipt: product=$productId, platform=$platform');
      
      // Send receipt to backend
      final response = await _apiClient.post(
        '/api/subscriptions/validate-receipt',
        body: {
          "receipt_data": receiptData,
          "product_id": productId,
          "platform": platform,
        },
      );
      
      if (response['success'] == true) {
        Logger.i('✅ Receipt validated successfully');
        Logger.i('   Subscription: ${response['subscription']['tier']}');
        Logger.i('   Expires: ${response['subscription']['expires_at']}');
      } else {
        Logger.e('❌ Receipt validation failed: ${response['message']}');
      }
    } catch (e) {
      Logger.e('❌ Error validating receipt: $e');
      rethrow;
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

/// Riverpod provider for PurchaseService
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final service = PurchaseService(apiClient: apiClient);
  
  // Initialize on first access
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
