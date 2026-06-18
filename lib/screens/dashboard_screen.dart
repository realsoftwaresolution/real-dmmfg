import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rs_dashboard/core/theme/app_color.dart';
import '../providers/production_dashboard_provider.dart';
import '../providers/rough_provider.dart';
import '../providers/article_provider.dart';
import '../models/rough_model.dart';
import '../models/article_model.dart';
import 'expandable_production_table.dart';
import 'pair_list_report_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<RoughModel> _selectedRoughs = [];
  List<ArticleModel> _selectedArticles = [];
  int _filterVersion = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoughProvider>().loadRoughs();
      context.read<ArticleProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterBar(context),
          const SizedBox(height: 16),
          Expanded(
            child: Responsive(
              mobile: _buildMobileLayout(context),
              tablet: _buildTabletLayout(context),
              desktop: _buildDesktopLayout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final roughProvider = context.watch<RoughProvider>();
    final articleProvider = context.watch<ArticleProvider>();

    final roughs = roughProvider.roughs;
    final articles = articleProvider.list;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Kapan Dropdown
          MultiSelectDropdownButton<RoughModel>(
            label: "Kapan No",
            items: roughs,
            selectedItems: _selectedRoughs,
            itemLabel: (item) => item.kapanNo ?? 'N/A',
            searchMatcher: (item, query) => (item.kapanNo ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()),
            onChanged: (selected) {
              setState(() {
                _selectedRoughs = selected;
              });
            },
          ),
          // Article Dropdown
          MultiSelectDropdownButton<ArticleModel>(
            label: "Article",
            items: articles,
            selectedItems: _selectedArticles,
            itemLabel: (item) => item.articalName ?? 'N/A',
            searchMatcher: (item, query) => (item.articalName ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()),
            onChanged: (selected) {
              setState(() {
                _selectedArticles = selected;
              });
            },
          ),
          // Apply Button
          ElevatedButton.icon(
            onPressed: () {
              final pMstIds = _selectedRoughs
                  .map((e) => e.roughMstID ?? 0)
                  .where((id) => id > 0)
                  .toList()
                  .cast<int>();
              final aCodes = _selectedArticles
                  .map((e) => e.articalCode ?? 0)
                  .where((c) => c > 0)
                  .toList()
                  .cast<int>();

              context.read<ProductionDashboardProvider>().setFilters(
                roughMstIDs: pMstIds,
                articleCodes: aCodes,
              );

              setState(() {
                _filterVersion++;
              });
            },
            icon: const Icon(Icons.filter_list, size: 16),
            label: const Text('Apply Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Reset Button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedRoughs = [];
                _selectedArticles = [];
              });
              context.read<ProductionDashboardProvider>().resetFilters();
              setState(() {
                _filterVersion++;
              });
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset Filter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    // Fit the screen layout dynamically, ensuring a minimum layout height
    double layoutHeight = screenHeight > 680 ? screenHeight - 200 : 560;

    return SizedBox(
      height: layoutHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Section - 50% width
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Left Section (Box 1) - 50% height
                Expanded(
                  flex: 1,
                  child: DashboardBox(
                    child: ExpandableProductionTable(
                      key: ValueKey('prod_$_filterVersion'),
                      title: 'Production Report',
                      reportType: ReportType.production,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Bottom Left Section (Box 2) - 50% height
                Expanded(
                  flex: 1,
                  child: DashboardBox(
                    child: ExpandableProductionTable(
                      key: ValueKey('polish_$_filterVersion'),
                      title: 'Office Polish Stock',
                      reportType: ReportType.polishStock,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Section - 50% width
          Expanded(
            flex: 1,
            child: DashboardBox(
              child: PairListReportTable(key: ValueKey('pair_$_filterVersion')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 300,
            child: DashboardBox(
              child: ExpandableProductionTable(
                key: ValueKey('prod_tab_$_filterVersion'),
                title: 'Production Report',
                reportType: ReportType.production,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: DashboardBox(
              child: ExpandableProductionTable(
                key: ValueKey('polish_tab_$_filterVersion'),
                title: 'Office Polish Stock',
                reportType: ReportType.polishStock,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 500,
            child: DashboardBox(
              child: PairListReportTable(
                key: ValueKey('pair_tab_$_filterVersion'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildTabletLayout(context);
  }
}

class DashboardBox extends StatelessWidget {
  final Widget child;

  const DashboardBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: child,
      ),
    );
  }
}

// ── MULTI SELECT DIALOG & BUTTON ──────────────────────────────────────────────
class MultiSelectDropdownButton<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final bool Function(T, String) searchMatcher;
  final ValueChanged<List<T>> onChanged;

  const MultiSelectDropdownButton({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.searchMatcher,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = label;
    if (selectedItems.isNotEmpty) {
      if (selectedItems.length == items.length) {
        displayText = "$label: All";
      } else if (selectedItems.length <= 2) {
        displayText =
            "$label: ${selectedItems.map((e) => itemLabel(e)).join(', ')}";
      } else {
        displayText = "$label: ${selectedItems.length} selected";
      }
    }

    return InkWell(
      onTap: () async {
        final result = await showDialog<List<T>>(
          context: context,
          builder: (context) => MultiSelectDialog<T>(
            title: "Select $label",
            items: items,
            selectedItems: selectedItems,
            itemLabel: itemLabel,
            searchMatcher: searchMatcher,
          ),
        );
        if (result != null) {
          onChanged(result);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class MultiSelectDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final bool Function(T, String) searchMatcher;

  const MultiSelectDialog({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.searchMatcher,
  });

  @override
  State<MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  late List<T> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      if (_searchQuery.isEmpty) return true;
      return widget.searchMatcher(item, _searchQuery);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selected = List<T>.from(widget.items);
                    });
                  },
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selected.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final isChecked = _selected.contains(item);
                  return CheckboxListTile(
                    title: Text(widget.itemLabel(item)),
                    value: isChecked,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selected.add(item);
                        } else {
                          _selected.remove(item);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
