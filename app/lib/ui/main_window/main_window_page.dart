import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_window_view_model.dart';
import '../../domain/entities/entities.dart';

/// Main window page displaying clipboard history list and preview.
///
/// Layout: Search bar at top, list on left, preview on right.
/// See Memory 09: UI/UX Guidelines.
class MainWindowPage extends StatelessWidget {
  const MainWindowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _SearchBar(),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 350, child: _ClipboardList()),
                const VerticalDivider(width: 1),
                const Expanded(child: _PreviewPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search clipboard history...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          context.read<ClipboardViewModel>().setSearchQuery(value);
        },
      ),
    );
  }
}

class _ClipboardList extends StatelessWidget {
  const _ClipboardList();

  @override
  Widget build(BuildContext context) {
    return Consumer<ClipboardViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.content_paste_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No clipboard history yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Copy something to get started',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: vm.items.length,
          itemBuilder: (context, index) {
            final item = vm.items[index];
            final isSelected = vm.selectedItem?.id == item.id;

            return _ClipboardItemTile(
              item: item,
              isSelected: isSelected,
              onTap: () => vm.selectItem(item),
            );
          },
        );
      },
    );
  }
}

class _ClipboardItemTile extends StatelessWidget {
  final ClipboardItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClipboardItemTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      leading: _buildIcon(theme),
      title: Text(
        _getPreviewText(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTimestamp(item.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          if (item.category != null || item.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (item.category != null)
                    _buildAIChip(context, item.category!, Colors.blue),
                  ...item.tags
                      .take(2)
                      .map((tag) => _buildAIChip(context, tag, Colors.grey)),
                ],
              ),
            ),
        ],
      ),
      trailing: item.isPinned
          ? Icon(Icons.push_pin, size: 16, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildAIChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    IconData iconData;
    switch (item.type) {
      case ClipboardItemType.text:
        iconData = Icons.text_snippet_outlined;
        break;
      case ClipboardItemType.image:
        iconData = Icons.image_outlined;
        break;
      case ClipboardItemType.files:
        iconData = Icons.folder_outlined;
        break;
    }
    return Icon(iconData, color: theme.colorScheme.primary);
  }

  String _getPreviewText() {
    switch (item.type) {
      case ClipboardItemType.text:
        return item.plainText ?? '';
      case ClipboardItemType.image:
        return '[Image]';
      case ClipboardItemType.files:
        final count = item.filePaths?.length ?? 0;
        return '[$count file${count != 1 ? 's' : ''}]';
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel();

  @override
  Widget build(BuildContext context) {
    return Consumer<ClipboardViewModel>(
      builder: (context, vm, child) {
        final item = vm.selectedItem;

        if (item == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.preview_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select an item to preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAIInsights(context, item),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PreviewHeader(item: item, vm: vm),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Expanded(child: _PreviewContent(item: item)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAIInsights(BuildContext context, ClipboardItem item) {
    final hasAI =
        item.summary != null ||
        item.tags.isNotEmpty ||
        item.language != null ||
        item.category != null;

    if (!hasAI) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'AI INSIGHTS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          if (item.summary != null) ...[
            const SizedBox(height: 8),
            Text(
              item.summary!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (item.category != null)
                _buildInsightChip(
                  context,
                  Icons.category_outlined,
                  'Category: ${item.category}',
                ),
              if (item.language != null)
                _buildInsightChip(
                  context,
                  Icons.translate,
                  'Language: ${item.language!.toUpperCase()}',
                ),
              ...item.tags.map(
                (tag) => _buildInsightChip(context, Icons.tag, tag),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  final ClipboardItem item;
  final ClipboardViewModel vm;

  const _PreviewHeader({required this.item, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _getTitle(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: Icon(item.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: () => vm.togglePin(item),
          tooltip: item.isPinned ? 'Unpin' : 'Pin',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => vm.deleteItem(item),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  String _getTitle() {
    switch (item.type) {
      case ClipboardItemType.text:
        return 'Text';
      case ClipboardItemType.image:
        return 'Image';
      case ClipboardItemType.files:
        return 'Files';
    }
  }
}

class _PreviewContent extends StatelessWidget {
  final ClipboardItem item;

  const _PreviewContent({required this.item});

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case ClipboardItemType.text:
        return SingleChildScrollView(
          child: SelectableText(
            item.plainText ?? '',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
          ),
        );

      case ClipboardItemType.image:
        if (item.imagePath == null) {
          return const Center(child: Text('Image not available'));
        }
        return Center(
          child: Image.file(
            File(item.imagePath!),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 64),
          ),
        );

      case ClipboardItemType.files:
        final files = item.filePaths ?? [];
        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text(files[index].split('/').last),
              subtitle: Text(files[index]),
            );
          },
        );
    }
  }
}
