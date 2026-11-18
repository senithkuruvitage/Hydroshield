import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/cleaning/cleaning_screen.dart';
import '../../features/leak_detection/leak_detection_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tank_level/owner_home_screen.dart';
import '../../features/tank_level/renter_home_screen.dart';
import '../../features/usage_billing/usage_billing_screen.dart';
import '../constants/app_constants.dart';
import '../session.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const owner = '/owner';
  static const renter = '/renter';
  static const cleaning = '/owner/cleaning';
  static const usage = '/owner/usage';
  static const leak = '/owner/leak';
  static const settings = '/owner/settings';
  static const renterUsage = '/renter/usage';
  static const renterPayments = '/renter/payments';
  static const renterProfile = '/renter/profile';
}

GoRouter createRouter() {
  final session = SessionStore.instance;
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: Listenable.merge([session.role]),
    redirect: (context, state) {
      final loggedIn = session.isLoggedIn;
      final loc = state.matchedLocation;
      final loggingIn = loc == AppRoutes.login || loc == AppRoutes.register;
      if (!loggedIn) return loggingIn ? null : AppRoutes.login;
      if (loggingIn) {
        return session.role.value == UserRole.owner
            ? AppRoutes.owner
            : AppRoutes.renter;
      }
      if (loc.startsWith('/owner') && session.role.value != UserRole.owner) {
        return AppRoutes.renter;
      }
      if (loc.startsWith('/renter') && session.role.value != UserRole.renter) {
        return AppRoutes.owner;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _OwnerShell(shell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.owner,
              builder: (context, state) => const OwnerHomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.usage,
              builder: (context, state) => const UsageBillingScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.cleaning,
              builder: (context, state) => const CleaningScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.leak,
              builder: (context, state) => const LeakDetectionScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _RenterShell(shell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.renter,
              builder: (context, state) => const RenterHomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.renterUsage,
              builder: (context, state) => const UsageBillingScreen(renterView: true),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.renterPayments,
              builder: (context, state) => const _RenterPaymentsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.renterProfile,
              builder: (context, state) => const _RenterProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}

class _OwnerShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _OwnerShell({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Usage'),
          NavigationDestination(icon: Icon(Icons.cleaning_services_outlined), selectedIcon: Icon(Icons.cleaning_services), label: 'Cleaning'),
          NavigationDestination(icon: Icon(Icons.warning_amber_outlined), selectedIcon: Icon(Icons.warning), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _RenterShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _RenterShell({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Charges'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Payments'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _RenterPaymentsScreen extends StatelessWidget {
  const _RenterPaymentsScreen();

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Owner Payment Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.account_balance), title: Text('Bank: Hydro Bank'), subtitle: Text('Account: 1234 5678 9012\nBranch: Main City')),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.phone_android), title: Text('Mobile/Other'), subtitle: Text('e.g. Cash / Bank transfer / Online (if integrated)')),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your Payment Status', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.pending_actions, color: Colors.orange), title: Text('Current bill: Pending'), subtitle: Text('Amount payable shown in Charges tab')),
                FilledButton.icon(onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Online payment gateway not integrated in this demo.')));
                }, icon: const Icon(Icons.payment), label: const Text('Pay Online (demo)')),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Previous Payment Records', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Oct 2026 - Paid'), subtitle: Text('Rs. 1,250.00 • Bank transfer')),
                const ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Sep 2026 - Paid'), subtitle: Text('Rs. 1,180.00 • Cash')),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RenterProfileScreen extends StatelessWidget {
  const _RenterProfileScreen();

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(session.userName.value ?? 'Tenant'),
              subtitle: Text(session.propertyName.value ?? 'Assigned property'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(children: [
              const ListTile(leading: Icon(Icons.home_work_outlined), title: Text('Property'), subtitle: Text('Linked to owner-managed property (demo)')),
              const ListTile(leading: Icon(Icons.shield_outlined), title: Text('Role permissions'), subtitle: Text('View tank/usage/charges/payments. No hardware or pricing controls.')),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  session.logout();
                  context.go(AppRoutes.login);
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
