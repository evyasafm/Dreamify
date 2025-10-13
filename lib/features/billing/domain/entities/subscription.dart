import 'package:equatable/equatable.dart';

/// User's subscription status
class UserSubscription extends Equatable {
  const UserSubscription({
    required this.tier,
    required this.credits,
    this.expiresAt,
    this.autoRenew = false,
  });

  final SubscriptionTier tier;
  final int credits;
  final DateTime? expiresAt;
  final bool autoRenew;

  bool get isPremium => tier == SubscriptionTier.premium;
  bool get isActive {
    if (tier == SubscriptionTier.free) return true;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }

  bool get hasCredits => credits > 0;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  UserSubscription copyWith({
    SubscriptionTier? tier,
    int? credits,
    DateTime? expiresAt,
    bool? autoRenew,
  }) {
    return UserSubscription(
      tier: tier ?? this.tier,
      credits: credits ?? this.credits,
      expiresAt: expiresAt ?? this.expiresAt,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }

  /// Deduct credits
  UserSubscription useCredits(int amount) {
    return copyWith(credits: credits - amount);
  }

  /// Add credits
  UserSubscription addCredits(int amount) {
    return copyWith(credits: credits + amount);
  }

  @override
  List<Object?> get props => [tier, credits, expiresAt, autoRenew];
}

enum SubscriptionTier {
  free,
  premium;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }
}

/// Available subscription products
class SubscriptionProduct extends Equatable {
  const SubscriptionProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    this.discount,
  });

  final String id;
  final String name;
  final double price;
  final SubscriptionDuration duration;
  final List<String> features;
  final double? discount; // Percentage discount

  double get discountedPrice {
    if (discount == null) return price;
    return price * (1 - discount! / 100);
  }

  String get pricePerMonth {
    switch (duration) {
      case SubscriptionDuration.monthly:
        return price.toStringAsFixed(2);
      case SubscriptionDuration.yearly:
        return (price / 12).toStringAsFixed(2);
    }
  }

  @override
  List<Object?> get props => [id, name, price, duration, features, discount];
}

enum SubscriptionDuration {
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case SubscriptionDuration.monthly:
        return 'Monthly';
      case SubscriptionDuration.yearly:
        return 'Yearly';
    }
  }
}

/// Purchase transaction
class PurchaseTransaction extends Equatable {
  const PurchaseTransaction({
    required this.id,
    required this.productId,
    required this.status,
    required this.createdAt,
    this.error,
  });

  final String id;
  final String productId;
  final PurchaseStatus status;
  final DateTime createdAt;
  final String? error;

  bool get isPending => status == PurchaseStatus.pending;
  bool get isCompleted => status == PurchaseStatus.completed;
  bool get isFailed => status == PurchaseStatus.failed;

  @override
  List<Object?> get props => [id, productId, status, createdAt, error];
}

enum PurchaseStatus {
  pending,
  completed,
  failed,
  cancelled,
  restored,
}
