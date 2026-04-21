import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelStyle: AppTypography.labelSmall(color: AppColors.primary),
            unselectedLabelStyle: AppTypography.labelSmall(color: AppColors.grey400),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Bookings'),
              Tab(text: 'Providers'),
              Tab(text: 'Payouts'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            _AdminListTab(title: 'All Bookings', icon: Icons.receipt_long_rounded),
            _AdminListTab(title: 'Providers', icon: Icons.handyman_rounded),
            _AdminListTab(title: 'Payouts', icon: Icons.account_balance_rounded),
            _SettingsTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text('Summary', style: AppTypography.h5(
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
          const SizedBox(height: AppSpacing.md),

          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _StatTile(label: 'Total Revenue', value: '₹1,24,890', color: AppColors.primary, icon: Icons.currency_rupee_rounded),
              _StatTile(label: 'Bookings Today', value: '48', color: AppColors.secondary, icon: Icons.calendar_today_rounded),
              _StatTile(label: 'Active Providers', value: '124', color: AppColors.success, icon: Icons.handyman_rounded),
              _StatTile(label: 'Open Disputes', value: '3', color: AppColors.error, icon: Icons.flag_rounded),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),
          Text('Recent Bookings', style: AppTypography.h5(
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
          const SizedBox(height: AppSpacing.sm),

          ..._mockBookings.map((b) => _AdminBookingTile(data: b)),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  static final _mockBookings = [
    {'id': 'BK001', 'service': 'Pipe Fixing', 'customer': 'Amit', 'status': 'confirmed'},
    {'id': 'BK002', 'service': 'Deep Cleaning', 'customer': 'Priya', 'status': 'completed'},
    {'id': 'BK003', 'service': 'Wiring', 'customer': 'Ravi', 'status': 'disputed'},
  ];
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.color, required this.icon});
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.h4(color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
              Text(label, style: AppTypography.caption(color: AppColors.grey400)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminBookingTile extends StatelessWidget {
  const _AdminBookingTile({required this.data});
  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    final statusColor = _color(data['status'] ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.r12,
        border: Border.all(color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['id'] ?? '',
                    style: AppTypography.labelSmall(color: AppColors.grey400)),
                Text(data['service'] ?? '',
                    style: AppTypography.labelMedium(
                        color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
                Text('Customer: ${data['customer'] ?? ''}',
                    style: AppTypography.bodySmall(color: AppColors.grey500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.5),
              borderRadius: AppRadius.chip,
            ),
            child: Text(data['status'] ?? '',
                style: AppTypography.labelSmall(color: statusColor)),
          ),
        ],
      ),
    );
  }

  Color _color(String status) => switch (status) {
        'confirmed' => AppColors.confirmed,
        'completed' => AppColors.success,
        'disputed' => AppColors.disputed,
        'pending' => AppColors.pending,
        _ => AppColors.grey500,
      };
}

// ─── Simple List Tab ──────────────────────────────────────────────────────────

class _AdminListTab extends StatelessWidget {
  const _AdminListTab({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(title,
              style: AppTypography.h5(color: AppColors.grey500)),
          Text('Connect to backend API',
              style: AppTypography.bodySmall(color: AppColors.grey400)),
        ],
      ),
    );
  }
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
      children: [
        const SizedBox(height: AppSpacing.md),
        Text('App Settings',
            style: AppTypography.h5(
                color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900)),
        const SizedBox(height: AppSpacing.md),
        _SettingsTile(label: 'Platform Commission %', value: '10%', onTap: () {}),
        _SettingsTile(label: 'Max Booking Radius (km)', value: '50', onTap: () {}),
        _SettingsTile(label: 'OTP Expiry (sec)', value: '120', onTap: () {}),
        _SettingsTile(label: 'Payout Schedule', value: 'Weekly', onTap: () {}),
        _SettingsTile(label: 'Support Email', value: 'help@localserve.in', onTap: () {}),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: AppRadius.r12,
          border: Border.all(
              color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppTypography.bodyMedium(
                      color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey800)),
            ),
            Text(value,
                style: AppTypography.labelMedium(color: AppColors.primary)),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.edit_rounded,
                color: AppColors.grey400, size: 16),
          ],
        ),
      ),
    );
  }
}
