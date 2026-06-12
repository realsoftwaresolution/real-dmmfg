// ── Data classes ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class PanelItem {
  final int id;
  final String name;

  const PanelItem({required this.id, required this.name});
}

class PanelConfig {
  final String title;
  final List<PanelItem> items;
  final Set<int> selectedIds;
  final void Function(Set<int>) onChanged;

  const PanelConfig({
    required this.title,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
  });
}

// ── Stateless panel row widget ────────────────────────────────────────────────

class DetailPanels extends StatelessWidget {
  final List<PanelConfig> panels;
  final double childAspectRatio;


  const DetailPanels({super.key, required this.panels, required this.childAspectRatio});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF1D9E75);
    final selBg = const Color(0xFFE1F5EE);
    final selTxt = const Color(0xFF085041);
    final headerBg = Theme.of(context).colorScheme.surfaceContainerHighest;

    return GridView.builder(
      shrinkWrap: true,        // ← add this
      physics: const NeverScrollableScrollPhysics(), // ← add this too (parent scrolls)
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: panels.length,
      itemBuilder: (context, index) {
        final panel = panels[index];
        final all = panel.items.length;
        final selCount = panel.selectedIds.length;
        final allSelected = all > 0 && selCount == all;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.25),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: headerBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.25),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        panel.title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: selCount > 0 ? selBg : const Color(0xFFE6F1FB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        selCount > 0 ? '$selCount/$all' : '$all',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: selCount > 0 ? selTxt : const Color(0xFF0C447C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Select All row ──────────────────────────────────
              InkWell(
                onTap: () {
                  final next = Set<int>.from(panel.selectedIds);
                  if (allSelected) {
                    next.clear();
                  } else {
                    for (final it in panel.items) next.add(it.id);
                  }
                  panel.onChanged(next);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Checkbox(
                          value: allSelected ? true : (selCount > 0 ? null : false),
                          tristate: true,
                          activeColor: accent,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) {
                            final next = Set<int>.from(panel.selectedIds);
                            if (allSelected) {
                              next.clear();
                            } else {
                              for (final it in panel.items) next.add(it.id);
                            }
                            panel.onChanged(next);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select all',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Item list ───────────────────────────────────────
              Expanded(
                child: panel.items.isEmpty
                    ? Center(
                  child: Text(
                    'No items',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: panel.items.length,
                  itemBuilder: (_, i) {
                    final it = panel.items[i];
                    final isSelected = panel.selectedIds.contains(it.id);
                    return InkWell(
                      onTap: () {
                        final next = Set<int>.from(panel.selectedIds);
                        isSelected ? next.remove(it.id) : next.add(it.id);
                        panel.onChanged(next);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        color: isSelected ? selBg : Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: isSelected,
                                activeColor: accent,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onChanged: (v) {
                                  final next = Set<int>.from(panel.selectedIds);
                                  v == true ? next.add(it.id) : next.remove(it.id);
                                  panel.onChanged(next);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                it.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                  color: isSelected ? selTxt : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
