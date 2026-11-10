import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../constants/app_colors.dart';
import 'glass_widgets.dart';

enum PaletteItemType {
  student,
  module,
  action,
  specialist,
}

class PaletteItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final PaletteItemType type;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onSelect;

  const PaletteItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    required this.type,
    this.badge,
    this.badgeColor,
    required this.onSelect,
  });
}

/// Raycast / Linear uslubidagi universal tezkor qidiruv va buyruqlar paneli (Command Palette)
class UniversalCommandPaletteDialog extends StatefulWidget {
  final List<PaletteItem> items;
  final String initialQuery;

  const UniversalCommandPaletteDialog({
    super.key,
    required this.items,
    this.initialQuery = '',
  });

  static Future<void> show({
    required BuildContext context,
    required List<PaletteItem> items,
    String initialQuery = '',
  }) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x520A1A3F),
      builder: (ctx) => UniversalCommandPaletteDialog(
        items: items,
        initialQuery: initialQuery,
      ),
    );
  }

  @override
  State<UniversalCommandPaletteDialog> createState() =>
      _UniversalCommandPaletteDialogState();
}

class _UniversalCommandPaletteDialogState
    extends State<UniversalCommandPaletteDialog> {
  late final TextEditingController _searchCtrl;
  late final FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();

  String _filterCategory = 'Barchasi';
  int _highlightedIndex = 0;

  static const List<String> _categories = [
    'Barchasi',
    'O‘quvchilar',
    'Bo‘limlar',
    'Amallar',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<PaletteItem> _getFilteredItems() {
    final q = _searchCtrl.text.trim().toLowerCase();

    return widget.items.where((item) {
      // 1. Kategoriya filtri
      if (_filterCategory == 'O‘quvchilar' &&
          item.type != PaletteItemType.student) {
        return false;
      }
      if (_filterCategory == 'Bo‘limlar' &&
          item.type != PaletteItemType.module) {
        return false;
      }
      if (_filterCategory == 'Amallar' && item.type != PaletteItemType.action) {
        return false;
      }

      // 2. Qidiruv matni
      if (q.isEmpty) return true;

      final matchTitle = item.title.toLowerCase().contains(q);
      final matchSubtitle = item.subtitle.toLowerCase().contains(q);
      final matchBadge = item.badge?.toLowerCase().contains(q) ?? false;

      return matchTitle || matchSubtitle || matchBadge;
    }).toList();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final filtered = _getFilteredItems();
    if (filtered.isEmpty) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1) % filtered.length;
      });
      _scrollToHighlighted();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _highlightedIndex =
            (_highlightedIndex - 1 + filtered.length) % filtered.length;
      });
      _scrollToHighlighted();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < filtered.length) {
        filtered[_highlightedIndex].onSelect();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _scrollToHighlighted() {
    // 58px o'rtacha bir element balandligi
    final targetOffset = (_highlightedIndex * 58.0) - 100.0;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredItems();
    final isDark = AppColors.isDark;

    if (_highlightedIndex >= filtered.length) {
      _highlightedIndex = filtered.isEmpty ? 0 : filtered.length - 1;
    }

    // Guruhlarga ajratish
    final students =
        filtered.where((i) => i.type == PaletteItemType.student).toList();
    final actions =
        filtered.where((i) => i.type == PaletteItemType.action).toList();
    final modules =
        filtered.where((i) => i.type == PaletteItemType.module).toList();

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 640,
            maxHeight: 560,
          ),
          child: GlassSurface(
            borderRadius: 22,
            blur: 24,
            opacity: 0.98,
            boxShadow: AppColors.elevatedShadow,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Tepa qidiruv maydoni
                _buildSearchInputHeader(context),

                // 2. Kategoriya tanlov pill bar
                _buildCategoryPillBar(),

                const Divider(height: 1, thickness: 0.8),

                // 3. Natijalar ro'yxati
                Flexible(
                  child: filtered.isEmpty
                      ? _buildEmptyResultsView()
                      : ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          children: [
                            if (actions.isNotEmpty) ...[
                              _buildSectionHeader('TEZKOR AMALLAR', actions.length),
                              ...actions.map((item) => _buildItemTile(item, filtered)),
                              const SizedBox(height: 8),
                            ],
                            if (modules.isNotEmpty) ...[
                              _buildSectionHeader('BO‘LIMLAR VA NAVIGATSIYA', modules.length),
                              ...modules.map((item) => _buildItemTile(item, filtered)),
                              const SizedBox(height: 8),
                            ],
                            if (students.isNotEmpty) ...[
                              _buildSectionHeader('O‘QUVCHILAR BAZASI', students.length),
                              ...students.map((item) => _buildItemTile(item, filtered)),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                ),

                // 4. Pastki klaviatura ishoralari paneli
                _buildFooterBar(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInputHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.search,
              size: 17,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
              decoration: InputDecoration(
                hintText: 'O‘quvchi, bo‘lim yoki amalni qidiring...',
                hintStyle: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (_) {
                setState(() {
                  _highlightedIndex = 0;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          if (_searchCtrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.x, size: 16),
              color: AppColors.textMuted,
              splashRadius: 16,
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _highlightedIndex = 0);
              },
            ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.border,
                  width: 0.8,
                ),
              ),
              child: Text(
                'ESC',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPillBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _filterCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                setState(() {
                  _filterCategory = cat;
                  _highlightedIndex = 0;
                });
              },
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: 0.85,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 5),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(PaletteItem item, List<PaletteItem> flatList) {
    final itemIndex = flatList.indexOf(item);
    final isHighlighted = itemIndex == _highlightedIndex;
    final isDark = AppColors.isDark;

    final accent = item.iconColor ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3.5),
      child: MouseRegion(
        onEnter: (_) => setState(() => _highlightedIndex = itemIndex),
        child: InkWell(
          onTap: item.onSelect,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? (isDark
                      ? AppColors.primary.withValues(alpha: 0.20)
                      : AppColors.primaryLight)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighlighted
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : Colors.transparent,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? AppColors.surface
                        : accent.withValues(alpha: isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    size: 17,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.8,
                          fontWeight:
                              isHighlighted ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.8,
                          color: AppColors.textMuted,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isHighlighted)
                  StatusPill(
                    label: 'Tanlash',
                    icon: LucideIcons.cornerDownLeft,
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                  )
                else if (item.badge != null)
                  StatusPill(
                    label: item.badge!,
                    color: item.badgeColor ?? AppColors.textSecondary,
                    backgroundColor: AppColors.surfaceMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResultsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.searchX,
              size: 34,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Mos keluvchi natijalar topilmadi',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Boshqa so‘z yoki toifani tekshirib ko‘ring.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceRaised : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.85,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildShortcutChip('↑↓', 'Harakatlanish'),
          const SizedBox(width: 14),
          _buildShortcutChip('↵', 'Ochish'),
          const SizedBox(width: 14),
          _buildShortcutChip('ESC', 'Yopish'),
          const Spacer(),
          Text(
            'Tezkor Command Palette',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutChip(String keySymbol, String action) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4.5),
            border: Border.all(
              color: AppColors.border,
              width: 0.8,
            ),
          ),
          child: Text(
            keySymbol,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          action,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
