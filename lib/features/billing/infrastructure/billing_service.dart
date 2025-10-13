import 'package:logger/logger.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../domain/entities/subscription.dart' as domain;
import '../domain/repositories/billing_repository.dart';

/// Mock billing service (implement with actual IAP logic)
class BillingService implements BillingRepository {
  BillingService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;
  final InAppPurchase _iap = InAppPurchase.instance;

  // Mock subscription state
  domain.UserSubscription _currentSubscription = const domain.UserSubscription(
    tier: domain.SubscriptionTier.free,
    credits: 3,
  );

  static const String monthlyProductId = 'dreamify_premium_monthly';
  static const String yearlyProductId = 'dreamify_premium_yearly';

  @override
  Future<domain.UserSubscription> getCurrentSubscription() async {
    return _currentSubscription;
  }

  @override
  Future<List<domain.SubscriptionProduct>> getProducts() async {
    try {
      // TODO: Implement actual product fetching from stores
      return const [
        domain.SubscriptionProduct(
          id: monthlyProductId,
          name: 'Premium Monthly',
          price: 9.99,
          duration: domain.SubscriptionDuration.monthly,
          features: [
            'Unlimited generations',
            'No watermark',
            'High quality (1536px)',
            'Ultra quality (2048px)',
            'Priority queue',
            'Advanced styles',
            'Remove background',
          ],
        ),
        domain.SubscriptionProduct(
          id: yearlyProductId,
          name: 'Premium Yearly',
          price: 99.99,
          duration: domain.SubscriptionDuration.yearly,
          features: [
            'Unlimited generations',
            'No watermark',
            'High quality (1536px)',
            'Ultra quality (2048px)',
            'Priority queue',
            'Advanced styles',
            'Remove background',
            'Save 17%',
          ],
          discount: 17,
        ),
      ];
    } catch (e) {
      _logger.e('Error fetching products', error: e);
      return [];
    }
  }

  @override
  Future<domain.PurchaseTransaction> purchaseSubscription(String productId) async {
    try {
      _logger.i('Initiating purchase: $productId');

      // TODO: Implement actual purchase flow
      // This is a mock implementation
      await Future.delayed(const Duration(seconds: 2));

      final transaction = domain.PurchaseTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        status: domain.PurchaseStatus.completed,
        createdAt: DateTime.now(),
      );

      // Update subscription
      _currentSubscription = domain.UserSubscription(
        tier: domain.SubscriptionTier.premium,
        credits: 999,
        expiresAt: productId == monthlyProductId
            ? DateTime.now().add(const Duration(days: 30))
            : DateTime.now().add(const Duration(days: 365)),
        autoRenew: true,
      );

      _logger.i('Purchase completed');
      return transaction;
    } catch (e) {
      _logger.e('Error during purchase', error: e);
      return domain.PurchaseTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        status: domain.PurchaseStatus.failed,
        createdAt: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  @override
  Future<List<domain.PurchaseTransaction>> restorePurchases() async {
    try {
      _logger.i('Restoring purchases');

      // TODO: Implement actual restore logic
      await Future.delayed(const Duration(seconds: 1));

      return [];
    } catch (e) {
      _logger.e('Error restoring purchases', error: e);
      return [];
    }
  }

  @override
  Future<void> cancelSubscription() async {
    try {
      _logger.i('Cancelling subscription');

      // TODO: Implement actual cancellation
      // Note: iOS/Android handle this differently
      _currentSubscription = _currentSubscription.copyWith(
        autoRenew: false,
      );

      _logger.i('Subscription cancelled (will not auto-renew)');
    } catch (e) {
      _logger.e('Error cancelling subscription', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> hasFeatureAccess(String featureId) async {
    if (_currentSubscription.isPremium && _currentSubscription.isActive) {
      return true;
    }

    // Free tier features
    const freeFeatures = ['basic_generation', 'watermark'];
    return freeFeatures.contains(featureId);
  }

  @override
  Future<domain.UserSubscription> useCredits(int amount) async {
    if (_currentSubscription.credits < amount) {
      throw Exception('Insufficient credits');
    }

    _currentSubscription = _currentSubscription.useCredits(amount);
    _logger.i('Used $amount credits, remaining: ${_currentSubscription.credits}');

    return _currentSubscription;
  }

  @override
  Future<domain.UserSubscription> grantFreeTrial() async {
    if (_currentSubscription.tier != domain.SubscriptionTier.free) {
      throw Exception('User already has a subscription');
    }

    _currentSubscription = domain.UserSubscription(
      tier: domain.SubscriptionTier.premium,
      credits: 999,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      autoRenew: false,
    );

    _logger.i('Free trial granted');
    return _currentSubscription;
  }
}
