import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rs_dashboard/core/theme/app_color.dart';
import '../providers/production_dashboard_provider.dart';

enum ReportType { production, polishStock }

class ProductionNode {
  final int level; // 1, 2, or 3
  final Map<String, dynamic> data;
  bool isExpanded;
  bool isLoading;
  List<ProductionNode> children;
  final bool isFooter;
  final ReportType reportType;

  ProductionNode({
    required this.level,
    required this.data,
    this.isExpanded = false,
    this.isLoading = false,
    required this.children,
    this.isFooter = false,
    required this.reportType,
  });

  String get id {
    final footerSuffix = isFooter ? "_footer" : "";
    if (level == 1) {
      final code = reportType == ReportType.production
          ? data['DeptCode']
          : data['FactoryCode'];
      if (code == null || code == 0) {
        final name = reportType == ReportType.production
            ? data['DeptName']
            : data['FactoryName'];
        return "dept_${name}_${data['ProcessName'] ?? ''}_${data['ManagerName'] ?? ''}$footerSuffix";
      }
      return "dept_$code$footerSuffix";
    } else if (level == 2) {
      final deptCode = reportType == ReportType.production
          ? data['DeptCode']
          : data['FactoryCode'];
      final roughMstId = data['RoughMstID'];
      final kapan = data['KapanNo'];
      return "kapan_${deptCode}_${roughMstId}_$kapan$footerSuffix";
    } else if (level == 3) {
      final idVal = reportType == ReportType.production
          ? data['PacketHistoryMstID']
          : data['FactoryRecDetID'];
      return "packet_${idVal}_${data['BCode']}$footerSuffix";
    } else {
      return "grand_total_footer";
    }
  }
}

class ExpandableProductionTable extends StatefulWidget {
  final String title;
  final ReportType reportType;
  final Function(Map<String, dynamic>)? onRowSelect;

  const ExpandableProductionTable({
    super.key,
    required this.title,
    this.reportType = ReportType.production,
    this.onRowSelect,
  });

  @override
  State<ExpandableProductionTable> createState() =>
      _ExpandableProductionTableState();
}

class _ExpandableProductionTableState extends State<ExpandableProductionTable> {
  List<ProductionNode> _rootNodes = [];
  bool _isLoadingRoot = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRootData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRootData() async {
    setState(() {
      _isLoadingRoot = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<ProductionDashboardProvider>();
      final data = widget.reportType == ReportType.production
          ? await provider.fetchLevel1()
          : await provider.fetchPolishStockLevel1();
      if (data != null) {
        setState(() {
          _rootNodes = data
              .map((e) => ProductionNode(
                    level: 1,
                    data: e,
                    children: [],
                    reportType: widget.reportType,
                  ))
              .toList();
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load ${widget.title.toLowerCase()}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingRoot = false;
      });
    }
  }

  List<ProductionNode> _getFlattenedList() {
    final List<ProductionNode> visible = [];
    void traverse(ProductionNode node) {
      visible.add(node);
      if (node.isExpanded && node.children.isNotEmpty) {
        for (var child in node.children) {
          traverse(child);
        }
        // Append a footer for Level 2 Kapan or Level 1 Department
        if (node.level == 1) {
          visible.add(
            ProductionNode(
              level: 1,
              isFooter: true,
              data: node.data,
              children: [],
              reportType: widget.reportType,
            ),
          );
        } else if (node.level == 2) {
          visible.add(
            ProductionNode(
              level: 2,
              isFooter: true,
              data: node.data,
              children: [],
              reportType: widget.reportType,
            ),
          );
        }
      }
    }

    for (var node in _rootNodes) {
      traverse(node);
    }

    return visible;
  }

  Future<void> _handleRowDoubleTap(ProductionNode node) async {
    if (node.isLoading) return;

    final isProduction = widget.reportType == ReportType.production;

    if (node.level == 1) {
      if (node.children.isEmpty) {
        setState(() {
          node.isLoading = true;
        });
        try {
          final parentCode = isProduction
              ? (node.data['DeptCode'] ?? 0)
              : (node.data['FactoryCode'] ?? 0);
          final provider = context.read<ProductionDashboardProvider>();
          final childrenData = isProduction
              ? await provider.fetchLevel2(parentCode)
              : await provider.fetchPolishStockLevel2(parentCode);
          if (childrenData != null) {
            node.children = childrenData
                .map((e) => ProductionNode(
                      level: 2,
                      data: e,
                      children: [],
                      reportType: widget.reportType,
                    ))
                .toList();
          }
          node.isExpanded = true;
        } catch (e) {
          debugPrint("Error loading level 2: $e");
        } finally {
          setState(() {
            node.isLoading = false;
          });
        }
      } else {
        setState(() {
          node.isExpanded = !node.isExpanded;
        });
      }
    } else if (node.level == 2) {
      if (node.children.isEmpty) {
        setState(() {
          node.isLoading = true;
        });
        try {
          final parentCode = isProduction
              ? (node.data['DeptCode'] ?? 0)
              : (node.data['FactoryCode'] ?? 0);
          final roughMstId = node.data['RoughMstID'] ?? 0;
          final provider = context.read<ProductionDashboardProvider>();
          final childrenData = isProduction
              ? await provider.fetchLevel3(
                  deptCode: parentCode,
                  roughMstID: roughMstId,
                )
              : await provider.fetchPolishStockLevel3(
                  factoryCode: parentCode,
                  roughMstID: roughMstId,
                );
          if (childrenData != null) {
            node.children = childrenData
                .map((e) => ProductionNode(
                      level: 3,
                      data: e,
                      children: [],
                      reportType: widget.reportType,
                    ))
                .toList();
          }
          node.isExpanded = true;
        } catch (e) {
          debugPrint("Error loading level 3: $e");
        } finally {
          setState(() {
            node.isLoading = false;
          });
        }
      } else {
        setState(() {
          node.isExpanded = !node.isExpanded;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRoot) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 3),
              const SizedBox(height: 16),
              Text(
                'Fetching Production Data...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.danger, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadRootData,
                icon: const Icon(Iconsax.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final flattenedList = _getFlattenedList();

    if (flattenedList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No production data found.',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    int grandPc = 0;
    double grandWt = 0.0;
    if (_rootNodes.isNotEmpty) {
      final pcsKey = widget.reportType == ReportType.production ? 'TotalPc' : 'TotalRecPc';
      final wtKey = widget.reportType == ReportType.production ? 'TotalWt' : 'TotalRecWt';
      for (var node in _rootNodes) {
        grandPc += (node.data[pcsKey] as num? ?? 0).toInt();
        grandWt += (node.data[wtKey] as num? ?? 0.0).toDouble();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Title with card header style
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Iconsax.refresh,
                  size: 14,
                  color: AppColors.primaryBlue,
                ),
                onPressed: _loadRootData,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: 'Refresh data',
              ),
            ],
          ),
        ),
        // Header
        _buildHeader(context),
        // List of Tree Nodes
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            interactive: true,
            trackVisibility: true,
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(3),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: flattenedList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final node = flattenedList[index];
                return _buildRow(context, node);
              },
            ),
          ),
        ),
        // Sticky Grand Total Footer
        if (_rootNodes.isNotEmpty)
          _buildGrandTotalFooterRow(context, grandPc, grandWt),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final col1 = widget.reportType == ReportType.production
        ? 'DEPARTMENT'
        : 'FACTORY';
    final col2 = widget.reportType == ReportType.production
        ? 'PROCESS'
        : 'CODE';
    final col3 = widget.reportType == ReportType.production
        ? 'MANAGER'
        : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              col1,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.blueGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              col2,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.blueGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              col3,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.blueGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'PCS',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.blueGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'WT',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.blueGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeConnectors(int level) {
    if (level <= 1) return const SizedBox();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(level - 1, (index) {
        return Container(
          width: 24,
          alignment: Alignment.center,
          child: Container(width: 2, height: 26, color: Colors.grey.shade300),
        );
      }),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor, bool isBold) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildRow(BuildContext context, ProductionNode node) {
    if (node.isFooter) {
      return _buildFooterRow(context, node);
    }
    // Determine row colors based on level
    Color rowBgColor;
    if (node.level == 1) {
      rowBgColor = Colors.transparent;
    } else if (node.level == 2) {
      rowBgColor = Colors.blue.shade50.withOpacity(0.25);
    } else {
      rowBgColor = Colors.green.shade50.withOpacity(0.15);
    }

    // Determine text and values depending on Level
    String title = '';
    String process = '';
    String managerOrDate = '';
    String pcs = '';
    String wt = '';

    final isProduction = widget.reportType == ReportType.production;

    if (node.level == 1) {
      title = isProduction
          ? (node.data['DeptName'] ?? 'UNKNOWN DEPARTMENT')
          : (node.data['FactoryName'] ?? 'UNKNOWN FACTORY');
      process = isProduction ? (node.data['ProcessName'] ?? '-') : '';
      managerOrDate = isProduction ? (node.data['ManagerName'] ?? '-') : '';
      pcs = isProduction
          ? (node.data['TotalPc'] ?? 0).toString()
          : (node.data['TotalRecPc'] ?? 0).toString();
      wt = isProduction
          ? (node.data['TotalWt'] ?? 0.0).toStringAsFixed(3)
          : (node.data['TotalRecWt'] ?? 0.0).toStringAsFixed(3);
    } else if (node.level == 2) {
      final kapan = node.data['KapanNo'] ?? '-';
      final article = node.data['ArticleName'] ?? '';
      title = article.isNotEmpty ? "$kapan ($article)" : kapan;
      process = isProduction ? (node.data['ProcessName'] ?? '-') : '';
      managerOrDate = isProduction ? (node.data['ManagerName'] ?? '-') : '';
      pcs = isProduction
          ? (node.data['TotalPc'] ?? 0).toString()
          : (node.data['TotalRecPc'] ?? 0).toString();
      wt = isProduction
          ? (node.data['TotalWt'] ?? 0.0).toStringAsFixed(3)
          : (node.data['TotalRecWt'] ?? 0.0).toStringAsFixed(3);
    } else if (node.level == 3) {
      final bCode = node.data['BCode'] ?? '-';
      final cutNo = node.data['CutNo'] ?? '';
      title = cutNo.isNotEmpty ? "$bCode [Cut: $cutNo]" : bCode;
      process = isProduction
          ? (node.data['LastProcess'] ?? '-')
          : (node.data['GroupType'] ?? '-');
      managerOrDate = isProduction
          ? _formatDate(node.data['Sdate'] ?? node.data['FormDate'])
          : _formatDate(node.data['FactoryRecDate']);
      pcs = isProduction
          ? (node.data['Pc'] ?? 0).toString()
          : (node.data['RecPc'] ?? 0).toString();
      wt = isProduction
          ? (node.data['Wt'] ?? 0.0).toStringAsFixed(3)
          : (node.data['RecWt'] ?? 0.0).toStringAsFixed(3);
    }

    // Icon for expansion
    Widget expansionIcon;
    if (node.level == 3) {
      expansionIcon = const SizedBox(width: 20);
    } else if (node.isLoading) {
      expansionIcon = const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else {
      expansionIcon = AnimatedRotation(
        turns: node.isExpanded ? 0.25 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          Iconsax.arrow_right_3,
          size: 13,
          color: node.level == 1 ? AppColors.primaryBlue : AppColors.success,
        ),
      );
    }

    // Icon depending on Node type
    Widget typeIcon;
    if (node.level == 1) {
      typeIcon = const Icon(
        Icons.business,
        size: 14,
        color: AppColors.primaryBlue,
      );
    } else if (node.level == 2) {
      typeIcon = const Icon(Icons.folder_open, size: 14, color: Colors.amber);
    } else {
      typeIcon = const Icon(Icons.qr_code_2, size: 14, color: Colors.blueGrey);
    }

    return Container(
      decoration: BoxDecoration(
        color: rowBgColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: InkWell(
        onDoubleTap: () => _handleRowDoubleTap(node),
        onTap: () {
          if (widget.onRowSelect != null) {
            widget.onRowSelect!(node.data);
          }
        },
        hoverColor: Colors.grey.shade100.withOpacity(0.8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
          child: Row(
            children: [
              // Left column with indent tree connectors and type icons
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    _buildTreeConnectors(node.level),
                    expansionIcon,
                    const SizedBox(width: 6),
                    typeIcon,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: node.level == 1
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: node.level == 1 ? 13 : 12,
                          fontFamily: node.level == 3 ? 'Courier' : null,
                          color: node.level == 1
                              ? Colors.black87
                              : node.level == 2
                              ? Colors.black54
                              : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Process
              Expanded(
                flex: 2,
                child: Text(
                  process,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Manager/Date
              Expanded(
                flex: 2,
                child: Text(
                  managerOrDate,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Pcs
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: node.level == 1
                      ? _buildBadge(
                          pcs,
                          Colors.blue.shade50,
                          Colors.blue.shade800,
                          true,
                        )
                      : node.level == 2
                      ? _buildBadge(
                          pcs,
                          Colors.amber.shade50,
                          Colors.amber.shade900,
                          false,
                        )
                      : Text(
                          pcs,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              // Wt
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: node.level == 1
                      ? _buildBadge(
                          wt,
                          Colors.green.shade50,
                          Colors.green.shade800,
                          true,
                        )
                      : node.level == 2
                      ? _buildBadge(
                          wt,
                          Colors.teal.shade50,
                          Colors.teal.shade900,
                          false,
                        )
                      : Text(
                          wt,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr.toString());
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      final parts = dateStr.toString().split('T').first.split('-');
      if (parts.length == 3) {
        return "${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}";
      }
      return dateStr.toString().split('T').first;
    }
  }

  Widget _buildFooterRow(BuildContext context, ProductionNode node) {
    Color rowBgColor;
    String title = '';
    String pcs = '';
    String wt = '';

    final isProduction = widget.reportType == ReportType.production;
    final pcsKey = isProduction ? 'TotalPc' : 'TotalRecPc';
    final wtKey = isProduction ? 'TotalWt' : 'TotalRecWt';

    if (node.level == 1) {
      rowBgColor = Colors.blueGrey.shade50.withOpacity(0.5);
      final name = isProduction
          ? (node.data['DeptName'] ?? 'UNKNOWN')
          : (node.data['FactoryName'] ?? 'UNKNOWN');
      title = "Total for $name";
      pcs = (node.data[pcsKey] ?? 0).toString();
      wt = (node.data[wtKey] ?? 0.0).toStringAsFixed(3);
    } else if (node.level == 2) {
      rowBgColor = Colors.green.shade50.withOpacity(0.3);
      final kapan = node.data['KapanNo'] ?? '-';
      title = "Total for $kapan";
      pcs = (node.data[pcsKey] ?? 0).toString();
      wt = (node.data[wtKey] ?? 0.0).toStringAsFixed(3);
    } else {
      rowBgColor = Colors.blueGrey.shade100.withOpacity(0.6);
      title = "GRAND TOTAL";
      pcs = (node.data[pcsKey] ?? 0).toString();
      wt = (node.data[wtKey] ?? 0.0).toStringAsFixed(3);
    }

    return Container(
      decoration: BoxDecoration(color: rowBgColor),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (node.level > 0) _buildTreeConnectors(node.level + 1),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: node.level == 0 ? 13 : 12,
                    color: node.level == 0
                        ? Colors.black87
                        : node.level == 1
                        ? Colors.blueGrey.shade800
                        : Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(flex: 2, child: SizedBox()),
          const Expanded(flex: 2, child: SizedBox()),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                pcs,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: node.level == 0 ? 12 : 11,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                wt,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: node.level == 0 ? 12 : 11,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalFooterRow(BuildContext context, int totalPcs, double totalWt) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              "GRAND TOTAL",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(flex: 2, child: SizedBox()),
          const Expanded(flex: 2, child: SizedBox()),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                totalPcs.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                totalWt.toStringAsFixed(3),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
