import '../entities/subscription.dart';

/// Repository for billing and subscription management
abstract class BillingRepository {
  /// Get current user subscription
  Future<UserSubscription> getCurrentSubscription();

  /// Get available subscription products
  Future<List<SubscriptionProduct>> getProducts();

  /// Purchase a subscription
  Future<PurchaseTransaction> purchaseSubscription(String productId);

  /// Restore previous purchases
  Future<List<PurchaseTransaction>> restorePurchases();

  /// Cancel subscription
  Future<void> cancelSubscription();

  /// Check if feature is available for current tier
  Future<bool> hasFeatureAccess(String featureId);

  /// Deduct credits for generation
  Future<UserSubscription> useCredits(int amount);

  /// Grant free trial
  Future<UserSubscription> grantFreeTrial();
}
