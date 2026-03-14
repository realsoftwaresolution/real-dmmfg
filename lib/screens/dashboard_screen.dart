import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rs_dashboard/core/theme/app_color.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      padding: EdgeInsets.all(
        Responsive.isMobile(context) ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildWelcomeCard(context),

          const SizedBox(height: 24),

          Responsive(
            mobile: _buildStatsMobile(context),
            tablet: _buildStatsTablet(context),
            desktop: _buildStatsDesktop(context),
          ),

          const SizedBox(height: 24),

          // Charts Section
          Responsive(
            mobile: _buildChartsMobile(context),
            tablet: _buildChartsTablet(context),
            desktop: _buildChartsDesktop(context),
          ),

          const SizedBox(height: 24),

          // Sales Report & Products
          Responsive(
            mobile: _buildBottomSectionMobile(context),
            desktop: _buildBottomSectionDesktop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return RoundedContainer(
      gradient: AppColors.blueGradient,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Iconsax.emoji_happy,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GOOD DAY,',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Real Soft!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Iconsax.calendar,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Feb 16, 2026',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Icon(
                      Iconsax.clock,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '11:45:09 AM',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // if (!Responsive.isMobile(context))
          //   Image.asset(
          //     'assets/images/welcome_illustration.png',
          //     height: 120,
          //     errorBuilder: (context, error, stackTrace) {
          //       return Container(
          //         width: 120,
          //         height: 120,
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.2),
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: const Icon(
          //           Iconsax.chart,
          //           size: 48,
          //           color: Colors.white,
          //         ),
          //       );
          //     },
          //   ),
        ],
      ),
    );
  }

  Widget _buildStatsDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'ORDERS',
            value: '9,754',
            change: '1.89%',
            changeLabel: 'Since last month',
            isPositive: true,
            icon: Iconsax.shopping_cart,
            iconBgColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'REVENUE',
            value: '\$75.21k',
            change: '5.23%',
            changeLabel: 'Since last month',
            isPositive: false,
            icon: Iconsax.wallet_2,
            iconBgColor: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'GROWTH',
            value: '+ 25.08%',
            change: '4.87%',
            changeLabel: 'Since last month',
            isPositive: true,
            icon: Iconsax.trend_up,
            iconBgColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTablet(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'ORDERS',
                value: '9,754',
                change: '1.89%',
                icon: Iconsax.shopping_cart,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'REVENUE',
                value: '\$75.21k',
                change: '5.23%',
                isPositive: false,
                icon: Iconsax.wallet_2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StatCard(
          title: 'GROWTH',
          value: '+ 25.08%',
          change: '4.87%',
          icon: Iconsax.trend_up,
        ),
      ],
    );
  }

  Widget _buildStatsMobile(BuildContext context) {
    return Column(
      children: [
        StatCard(
          title: 'ORDERS',
          value: '9,754',
          change: '1.89%',
          icon: Iconsax.shopping_cart,
        ),
        const SizedBox(height: 16),
        StatCard(
          title: 'REVENUE',
          value: '\$75.21k',
          change: '5.23%',
          isPositive: false,
          icon: Iconsax.wallet_2,
        ),
        const SizedBox(height: 16),
        StatCard(
          title: 'GROWTH',
          value: '+ 25.08%',
          change: '4.87%',
          icon: Iconsax.trend_up,
        ),
      ],
    );
  }

  Widget _buildChartsDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: LineChartWidget(
            title: 'Weekly Performance Insights',
            data: [
              FlSpot(0, 20),
              FlSpot(1, 30),
              FlSpot(2, 25),
              FlSpot(3, 40),
              FlSpot(4, 35),
              FlSpot(5, 50),
              FlSpot(6, 45),
            ],
            xLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            maxY: 80,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: DonutChartWidget(
            title: 'Store Performance Analytics',
            centerValue: '140',
            centerLabel: 'Total',
            data: [
              ChartData(label: 'Good Sales', value: 60, color: AppColors.success),
              ChartData(label: 'Poor Sales', value: 40, color: AppColors.warning),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartsTablet(BuildContext context) {
    return Column(
      children: [
        DonutChartWidget(
          title: 'Store Performance Analytics',
          centerValue: '140',
          data: [
            ChartData(label: 'Good Sales', value: 60, color: AppColors.success),
            ChartData(label: 'Poor Sales', value: 40, color: AppColors.warning),
          ],
        ),
        const SizedBox(height: 24),
        LineChartWidget(
          title: 'Weekly Performance Insights',
          data: [
            FlSpot(0, 20),
            FlSpot(1, 30),
            FlSpot(2, 25),
            FlSpot(3, 40),
            FlSpot(4, 35),
            FlSpot(5, 50),
            FlSpot(6, 45),
          ],
          xLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          maxY: 80,
        ),
      ],
    );
  }

  Widget _buildChartsMobile(BuildContext context) {
    return _buildChartsTablet(context);
  }

  Widget _buildBottomSectionDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildSalesReport(context),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildTopProducts(context),
        ),
      ],
    );
  }

  Widget _buildBottomSectionMobile(BuildContext context) {
    return Column(
      children: [
        _buildSalesReport(context),
        const SizedBox(height: 24),
        _buildTopProducts(context),
      ],
    );
  }

  Widget _buildSalesReport(BuildContext context) {
    return RoundedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Report',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '(25822 Orders)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildTabButton('Today', true),
                  const SizedBox(width: 8),
                  _buildTabButton('Monthly', false),
                  const SizedBox(width: 8),
                  _buildTabButton('Annual', false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSalesMetric('Revenue', '\$78,224.68', Iconsax.wallet, AppColors.success),
              const SizedBox(width: 24),
              _buildSalesMetric('Orders', '8,541', Iconsax.shopping_cart, AppColors.primaryBlue),
              const SizedBox(width: 24),
              _buildSalesMetric('Growth Rate', '25.30%', Iconsax.trend_up, AppColors.warning),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChartWidget(
              title: "Today's Earning: \$8,975.30",
              data: [
                FlSpot(0, 20),
                FlSpot(1, 35),
                FlSpot(2, 30),
                FlSpot(3, 50),
                FlSpot(4, 60),
                FlSpot(5, 70),
                FlSpot(6, 65),
              ],
              maxY: 100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? null : Border.all(color: AppColors.textTertiary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSalesMetric(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopProducts(BuildContext context) {
    return RoundedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Selling Products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.export_1, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.import, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            _buildProductItem(
              'Modern Fabric Sofa Set',
              'By Homelake',
              '\$499.00',
              '34',
              '\$16,966.00',
              'Low Stock',
              AppColors.warning,
            ),
            _buildProductItem(
              'L-Shaped Sectional Sofa',
              'By ComfortHub',
              '\$899.00',
              '21',
              '\$18,879.00',
              'In Stock',
              AppColors.success,
            ),
            _buildProductItem(
              'Velvet Recliner Chair',
              'By SoftEase',
              '\$379.00',
              '47',
              '\$17,813.00',
              'In Stock',
              AppColors.success,
            ),
            _buildProductItem(
              'Classic Wooden Coffee Table',
              'By WoodCraft',
              '\$259.00',
              '58',
              '\$15,022.00',
              'Out of Stock',
              AppColors.error,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductItem(
      String name,
      String brand,
      String price,
      String quantity,
      String amount,
      String status,
      Color statusColor,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.box, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  brand,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                'Price',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
