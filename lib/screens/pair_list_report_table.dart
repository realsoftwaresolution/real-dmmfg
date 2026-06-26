import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rs_dashboard/core/theme/app_color.dart';
import '../providers/production_dashboard_provider.dart';

class PairListReportTable extends StatefulWidget {
  const PairListReportTable({super.key});

  @override
  State<PairListReportTable> createState() => _PairListReportTableState();
}

class _PairListReportTableState extends State<PairListReportTable> {
  List<dynamic> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<ProductionDashboardProvider>();
      final data = await provider.fetchPairListReport();
      if (data != null) {
        setState(() {
          _items = data;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load pair list report";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 3),
              const SizedBox(height: 16),
              Text(
                'Fetching Pair List Data...',
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
                onPressed: _loadData,
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

    if (_items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No pair list data found.',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    // Calculate Grand Totals
    int totalPcs = 0;
    double totalWt = 0.0;
    for (var item in _items) {
      totalPcs += (item['RecPc'] as num? ?? 0).toInt();
      totalWt += (item['RecWt'] as num? ?? 0.0).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Row with card header style
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
                  const Text(
                    'Pair List Report',
                    style: TextStyle(
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
                onPressed: _loadData,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: 'Refresh data',
              ),
            ],
          ),
        ),
        // Header
        _buildHeader(context),
        // Data List
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            interactive: true,
            thickness: 6,
            trackVisibility: true,
            thumbVisibility: true,
            radius: const Radius.circular(3),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _items.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final item = _items[index];
                return _buildRow(context, item);
              },
            ),
          ),
        ),
        // Grand Total Footer
        _buildFooterRow(context, totalPcs, totalWt),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'PAIR / BARCODE',
              style: TextStyle(
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
              'ARTICLE / TYPE',
              style: TextStyle(
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
              'FACTORY / DATE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.blueGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
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
          Expanded(
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

  Widget _buildRow(BuildContext context, Map<String, dynamic> item) {
    final pairNo = item['PairNo'] ?? '-';
    final bCode = item['BCode'] ?? '-';
    final cutNo = item['CutNo'] ?? '';
    final kapan = item['KapanNo'] ?? '-';
    final article = item['ArticleName'] ?? '';
    final groupType = item['GroupType'] ?? '-';
    final factoryName = item['FactoryName'] ?? 'UNKNOWN FACTORY';
    final dateStr = _formatDate(item['FactoryRecDate']);

    final pcs = (item['RecPc'] ?? 0).toString();
    final wt = (item['RecWt'] ?? 0.0).toDouble().toStringAsFixed(3);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () {},
        hoverColor: Colors.grey.shade100.withOpacity(0.8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            children: [
              // Column 1: Pair / Barcode info
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 14, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pair $pairNo [BCode: $bCode]",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'Courier',
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Kapan: $kapan${cutNo.isNotEmpty ? ' | Cut: $cutNo' : ''}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Column 2: Article / Type
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      groupType,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Column 3: Factory / Date
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factoryName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Column 4: Pcs
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    pcs,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Column 5: Wt
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    wt,
                    style: const TextStyle(
                      fontSize: 12,
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

  Widget _buildFooterRow(BuildContext context, int totalPcs, double totalWt) {
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
