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
      subtitle: Text(
        _formatTimestamp(item.createdAt),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      trailing: item.isPinned
          ? Icon(Icons.push_pin, size: 16, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
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

        return Padding(
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
        );
      },
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
