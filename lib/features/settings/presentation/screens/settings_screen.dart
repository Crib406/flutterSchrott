import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../containers/presentation/providers/container_providers.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_providers.dart';

/// Einstellungen: zwei Backend-Profile (je Subdomain + API-Key) hinterlegen und
/// das aktive auswählen. Das aktive Profil wird für die gesamte Kommunikation
/// verwendet. Der Nutzer gibt NUR die Subdomain ein (z. B. `kraus`); Schema und
/// Domain (`https://….fe.creimann.cc`) ergänzt die App.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final List<TextEditingController> _subdomain;
  late final List<TextEditingController> _apiKey;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsControllerProvider);
    _subdomain = [
      for (final p in settings.profiles)
        TextEditingController(text: p.subdomain),
    ];
    _apiKey = [
      for (final p in settings.profiles) TextEditingController(text: p.apiKey),
    ];
    _activeIndex = settings.activeIndex;
  }

  @override
  void dispose() {
    for (final c in [..._subdomain, ..._apiKey]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Übernimmt beide Profile + aktiven Index, persistiert und lädt neu.
  void _persist(String message) {
    final settings = AppSettings(
      profiles: [
        for (var i = 0; i < AppSettings.profileCount; i++)
          BackendProfile(
            subdomain: _subdomain[i].text.trim(),
            apiKey: _apiKey[i].text.trim(),
          ),
      ],
      activeIndex: _activeIndex,
    );
    ref.read(settingsControllerProvider.notifier).save(settings);
    // Aktive Anbindung sofort wirksam: Container-Liste frisch laden.
    unawaited(ref.read(containerListProvider.notifier).refresh());
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onActiveChanged(int index) {
    setState(() => _activeIndex = index);
    _persist('Aktiv: ${_segmentLabel(index)}');
  }

  String _segmentLabel(int i) {
    final s = _subdomain[i].text.trim();
    return s.isEmpty ? 'Profil ${i + 1}' : s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Aktives Profil', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: [
                for (var i = 0; i < AppSettings.profileCount; i++)
                  ButtonSegment(value: i, label: Text(_segmentLabel(i))),
              ],
              selected: {_activeIndex},
              onSelectionChanged: (s) => _onActiveChanged(s.first),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Das aktive Profil wird für alle Server-Aufrufe genutzt.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          for (var i = 0; i < AppSettings.profileCount; i++) ..._profile(i),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _persist('Einstellungen gespeichert.'),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  List<Widget> _profile(int i) {
    final theme = Theme.of(context);
    final preview =
        _subdomain[i].text.trim().isEmpty ? '<subdomain>' : _subdomain[i].text.trim();
    return [
      const SizedBox(height: 28),
      Row(
        children: [
          Text('Profil ${i + 1}', style: theme.textTheme.titleMedium),
          if (i == _activeIndex) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
          ],
        ],
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _subdomain[i],
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.next,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          labelText: 'Subdomain (Mandant)',
          hintText: 'z. B. kraus',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.public),
          suffixText: '.${AppConfig.containerApiDomainSuffix}',
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'URL: https://$preview.${AppConfig.containerApiDomainSuffix}',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _apiKey[i],
        autocorrect: false,
        enableSuggestions: false,
        decoration: const InputDecoration(
          labelText: 'API-Key',
          hintText: 'prefix.secret',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.key),
        ),
      ),
    ];
  }
}
