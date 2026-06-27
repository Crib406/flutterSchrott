import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../providers/auth_providers.dart';

/// Konto-Tab: zeigt den angemeldeten Nutzer und den aktiven Mandanten und
/// bietet den Logout (nur dieses Gerät). Ersetzt die frühere Einstellungsseite.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _busy = false;

  Future<void> _logout() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).logout();
      // Erfolg: Router-Redirect wechselt automatisch zum Login.
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Konto')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (session != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: const Text('Angemeldet als'),
              subtitle: Text(session.user.label),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.public),
              title: const Text('Mandant'),
              subtitle: Text(
                '${session.subdomain}.${AppConfig.containerApiDomainSuffix}',
              ),
            ),
            const SizedBox(height: 32),
          ],
          OutlinedButton.icon(
            onPressed: _busy ? null : _logout,
            icon: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('Abmelden'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
