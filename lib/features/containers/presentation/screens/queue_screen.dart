import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/container_status.dart';
import '../../domain/entities/pending_operation.dart';
import '../providers/container_providers.dart';

/// Warteschlange: zeigt alle Update-Vorgänge mit Live-Status – wartend,
/// in Verarbeitung, erledigt, abgelehnt oder fehlgeschlagen.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(operationQueueProvider);
    final hasFinished = operations.any((op) => op.isFinished);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warteschlange'),
        actions: [
          if (hasFinished)
            TextButton(
              onPressed: () =>
                  ref.read(operationQueueProvider.notifier).clearFinished(),
              child: const Text('Erledigte entfernen'),
            ),
        ],
      ),
      body: operations.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              itemCount: operations.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final op = operations[index];
                return _OperationTile(
                  operation: op,
                  onRetry: op.status == PendingOpStatus.failed
                      ? () =>
                          ref.read(operationQueueProvider.notifier).retry(op.id)
                      : null,
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text('Keine Vorgänge', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Gescannte Updates erscheinen hier mit ihrem Status.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({required this.operation, this.onRetry});

  final PendingOperation operation;

  /// Rückruf für „Erneut versuchen" (gleiche UUID); `null` blendet den Button aus.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = ContainerStatus.fromCode(operation.statusCode).label;
    final subtitle = operation.message ??
        'Status: $statusLabel  ·  '
            '${operation.latitude.toStringAsFixed(5)}, '
            '${operation.longitude.toStringAsFixed(5)}';
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          operation.imageBytes,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      ),
      title: Text('Update · ${_formatTime(operation.capturedAt)}'),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: _statusColor(operation.status, theme)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null)
            IconButton(
              tooltip: 'Erneut versuchen',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
            ),
          _statusIndicator(operation.status, theme),
        ],
      ),
    );
  }

  Widget _statusIndicator(PendingOpStatus status, ThemeData theme) {
    switch (status) {
      case PendingOpStatus.processing:
        return const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case PendingOpStatus.queued:
        return const Icon(Icons.schedule, size: 22);
      case PendingOpStatus.done:
        return const Icon(Icons.check_circle, size: 22, color: Colors.green);
      case PendingOpStatus.rejected:
        return const Icon(Icons.block, size: 22, color: Colors.orange);
      case PendingOpStatus.failed:
        return Icon(Icons.error_outline,
            size: 22, color: theme.colorScheme.error);
    }
  }

  Color? _statusColor(PendingOpStatus status, ThemeData theme) {
    switch (status) {
      case PendingOpStatus.done:
        return Colors.green;
      case PendingOpStatus.rejected:
        return Colors.orange;
      case PendingOpStatus.failed:
        return theme.colorScheme.error;
      case PendingOpStatus.queued:
      case PendingOpStatus.processing:
        return null;
    }
  }

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
