// lib/widgets/company_selection_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/company_model.dart';
import '../providers/company_provider.dart';
import '../providers/menu_provider.dart';
import '../utils/app_router.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

Future<void> showCompanySelectionDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.75),
    builder: (_) => const _CompanySelectionDialog(),
  );
}

class _CompanySelectionDialog extends StatefulWidget {
  const _CompanySelectionDialog();

  @override
  State<_CompanySelectionDialog> createState() =>
      _CompanySelectionDialogState();
}

class _CompanySelectionDialogState extends State<_CompanySelectionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  int? _selectedCode;
  String _search = '';

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
    );


    WidgetsBinding.instance.addPostFrameCallback((_) {
      final companies = context.read<CompanyProvider>().companies;
      if (companies.isNotEmpty) {
        setState(() => _selectedCode = companies.first.companyCode);
      }
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }


  void _done(BuildContext context) {
    if (_selectedCode == null) return;


    context.read<CompanyProvider>().selectCompany(_selectedCode!);


    Navigator.of(context).pop();


    final menuProvider = context.read<MenuProvider>();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardLayout(
          menu: menuProvider.menus,
          router: AppRouter.router,
          sideHeader: 'Real-Dmmfg',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companies = context.watch<CompanyProvider>().companies;

    final filtered = companies.where((c) {
      final q = _search.toLowerCase();
      return q.isEmpty ||
          (c.companyName?.toLowerCase().contains(q) ?? false) ||
          (c.companyCode?.toString().contains(q) ?? false);
    }).toList();

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, __) => FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1330).withOpacity(0.97),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF556EE6).withOpacity(0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF556EE6).withOpacity(0.15),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    _buildHeader(),


                    _buildSearchBar(),


                    _buildDropdownList(filtered),


                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Divider(
                        color: Colors.white.withOpacity(0.08),
                        height: 1,
                      ),
                    ),


                    _buildDoneButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2557), Color(0xFF0A0E2A)],
              ),
              border: Border.all(
                color: const Color(0xFF556EE6).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF556EE6).withOpacity(0.3),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Color(0xFF8B99FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Company',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Choose company to continue',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: const Color(0xFF556EE6),
        decoration: InputDecoration(
          hintText: 'Search company...',
          hintStyle:
          TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded,
              color: Colors.white.withOpacity(0.3), size: 18),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: Color(0xFF556EE6), width: 1.5),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }


  Widget _buildDropdownList(List<CompanyModel> list) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Text(
          'No companies found',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          final company = list[i];
          final isSelected = _selectedCode == company.companyCode;

          return GestureDetector(
            onTap: () => setState(() => _selectedCode = company.companyCode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF556EE6).withOpacity(0.15)
                    : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF556EE6).withOpacity(0.5)
                      : Colors.white.withOpacity(0.06),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [

                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF556EE6).withOpacity(0.2)
                          : Colors.white.withOpacity(0.06),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF556EE6).withOpacity(0.6)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (company.companyName?.isNotEmpty == true
                            ? company.companyName![0]
                            : '?')
                            .toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF8B99FF)
                              : Colors.white.withOpacity(0.45),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),


                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.companyName ?? '—',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.75),
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Code: ${company.companyCode}  •  ${company.state ?? ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),


                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF556EE6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF556EE6).withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildDoneButton(BuildContext context) {
    final canDone = _selectedCode != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedCode == null
                  ? Text(
                'No company selected',
                key: const ValueKey('none'),
                style: TextStyle(
                    color: Colors.white.withOpacity(0.2), fontSize: 12),
              )
                  : Row(
                key: ValueKey(_selectedCode),
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF45D3A0),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Code: $_selectedCode',
                    style: const TextStyle(
                      color: Color(0xFF45D3A0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Done button
          GestureDetector(
            onTap: canDone ? () => _done(context) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
              decoration: BoxDecoration(
                gradient: canDone
                    ? const LinearGradient(
                  colors: [Color(0xFF556EE6), Color(0xFF4055C8)],
                )
                    : null,
                color: canDone ? null : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                boxShadow: canDone
                    ? [
                  BoxShadow(
                    color: const Color(0xFF556EE6).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              child: Text(
                'Done →',
                style: TextStyle(
                  color: canDone ? Colors.white : Colors.white.withOpacity(0.2),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}