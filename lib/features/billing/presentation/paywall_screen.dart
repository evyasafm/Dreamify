import 'package:flutter/material.dart';

/// Paywall screen for premium subscription
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedPlanIndex = 1; // Default to yearly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Unleash Your Creativity',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create unlimited AI-powered images',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Features
            _FeatureItem(
              icon: Icons.flash_on,
              title: 'Unlimited Generations',
              subtitle: 'Create as much as you want',
            ),
            _FeatureItem(
              icon: Icons.hd,
              title: 'High & Ultra Quality',
              subtitle: 'Up to 2048px resolution',
            ),
            _FeatureItem(
              icon: Icons.water_drop_outlined,
              title: 'No Watermark',
              subtitle: 'Clean, professional results',
            ),
            _FeatureItem(
              icon: Icons.layers,
              title: 'Advanced Styles',
              subtitle: 'Access premium style presets',
            ),
            _FeatureItem(
              icon: Icons.speed,
              title: 'Priority Queue',
              subtitle: 'Faster generation times',
            ),
            _FeatureItem(
              icon: Icons.auto_fix_high,
              title: 'Remove Background',
              subtitle: 'One-tap background removal',
            ),
            const SizedBox(height: 32),

            // Plans
            Text(
              'Choose Your Plan',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            _PlanCard(
              title: 'Monthly',
              price: '\$9.99',
              period: '/month',
              isSelected: _selectedPlanIndex == 0,
              onTap: () => setState(() => _selectedPlanIndex = 0),
            ),
            const SizedBox(height: 12),

            Stack(
              clipBehavior: Clip.none,
              children: [
                _PlanCard(
                  title: 'Yearly',
                  price: '\$99.99',
                  period: '/year',
                  subtitle: 'Save 17%',
                  isRecommended: true,
                  isSelected: _selectedPlanIndex == 1,
                  onTap: () => setState(() => _selectedPlanIndex = 1),
                ),
                Positioned(
                  top: -10,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // CTA Button
            ElevatedButton(
              onPressed: _handlePurchase,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text('Start Premium'),
            ),
            const SizedBox(height: 16),

            // Restore purchases
            TextButton(
              onPressed: _handleRestore,
              child: const Text('Restore Purchases'),
            ),
            const SizedBox(height: 8),

            // Terms
            Text(
              'Auto-renewable subscription. Cancel anytime.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Terms'),
                ),
                Text(' • ', style: Theme.of(context).textTheme.bodySmall),
                TextButton(
                  onPressed: () {},
                  child: const Text('Privacy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase() {
    // TODO: Implement purchase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Purchase initiated')),
    );
  }

  void _handleRestore() {
    // TODO: Implement restore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restoring purchases...')),
    );
  }
}

/// Feature list item
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

/// Plan selection card
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    this.subtitle,
    this.isRecommended = false,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String price;
  final String period;
  final String? subtitle;
  final bool isRecommended;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    width: 2,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Plan details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    period,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
