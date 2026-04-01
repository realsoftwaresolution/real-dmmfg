import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/core/theme/app_color.dart';
import '../models/admin_menu_model.dart';
import '../providers/admin_menu_provider.dart';

class AdminMenuCreateScreen extends StatefulWidget {
  const AdminMenuCreateScreen({super.key});

  @override
  State<AdminMenuCreateScreen> createState() => _AdminMenuCreateScreenState();
}

class _AdminMenuCreateScreenState extends State<AdminMenuCreateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminMenuProvider>().loadMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor:  AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create Menu',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Menus',
            onPressed: () => context.read<AdminMenuProvider>().loadMenus(),
          ),
        ],
      ),
      body: Consumer<AdminMenuProvider>(
        builder: (context, provider, _) {
          if (provider.loadState == MenuLoadState.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (provider.loadState == MenuLoadState.error) {
            return _ErrorView(
              message: provider.errorMessage,
              onRetry: () => provider.loadMenus(),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _FormPanel(provider: provider),
              ),
              Container(width: 1, color: const Color(0xFFDDE1EA)),
              Expanded(
                flex: 4,
                child: _MenuListPanel(provider: provider),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════
// FORM PANEL
// ════════════════════════════════════════════════
class _FormPanel extends StatelessWidget {
  final AdminMenuProvider provider;
  const _FormPanel({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: provider.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Menu Details'),
            const SizedBox(height: 16),

            // ── Row 1: Main Menu Group + Menu Name ────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DropdownField<MainMenuGroup>(
                    label: 'Main Menu Group *',
                    hint: 'Select Master or Transaction',
                    value: provider.selectedMainMenu,
                    items: mainMenuGroups,
                    itemLabel: (g) => g.name,
                    onChanged: (g) => provider.setSelectedMainMenu(g),
                    validator: (_) => provider.selectedMainMenu == null
                        ? 'Please select a main menu group'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TextInputField(
                    label: 'Menu Name *',
                    hint: 'e.g. StockEntry',
                    initialValue: provider.menuName,
                    onChanged: provider.setMenuName,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Menu name is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // ── Row 2: Form Name + Sort ID ────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TextInputField(
                    label: 'Form Name *',
                    hint: 'e.g. TrnFirm_StockEntry',
                    initialValue: provider.formName,
                    onChanged: provider.setFormName,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Form name is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _NumberInputField(
                    label: 'Sort ID *',
                    initialValue: provider.sortID,
                    onChanged: provider.setSortID,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // ── Row 3: Dashboard Action + Status ──────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DropdownField<String>(
                    label: 'Dashboard Action',
                    hint: 'Select action',
                    value: provider.dashBoard,
                    items: const ['CLICK', 'NONE'],
                    itemLabel: (s) => s,
                    onChanged: (v) => provider.setDashBoard(v ?? 'CLICK'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DropdownField<int>(
                    label: 'Status',
                    hint: 'Active / Inactive',
                    value: provider.valid,
                    items: const [1, 0],
                    itemLabel: (v) => v == 1 ? 'Active' : 'Inactive',
                    onChanged: (v) => provider.setValid(v ?? 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── IMAGE UPLOAD ──────────────────────────
            _sectionHeader('Menu Image'),
            const SizedBox(height: 12),
            _ImageUploadWidget(provider: provider),
            const SizedBox(height: 28),

            // ── Error banner ──────────────────────────
            if (provider.errorMessage.isNotEmpty && !provider.isSaving)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Action Buttons ────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isSaving ? null : provider.resetForm,
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor:  AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed:
                    provider.isSaving ? null : () => _onSave(context, provider),
                    icon: provider.isSaving
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.save_rounded),
                    label: Text(provider.isSaving ? 'Saving...' : 'Save Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave(BuildContext context, AdminMenuProvider provider) async {
    final success = await provider.saveMenu();
    if (!context.mounted) return;
    if(success){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✅ Menu created successfully!' : '❌ Failed to create menu.',
          ),
          backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

// ════════════════════════════════════════════════
// IMAGE UPLOAD WIDGET
// ════════════════════════════════════════════════
class _ImageUploadWidget extends StatelessWidget {
  final AdminMenuProvider provider;
  const _ImageUploadWidget({required this.provider});

  @override
  Widget build(BuildContext context) {
    final bool hasImage = provider.hasImage;
    final imageBytes = provider.pickedImageBytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Preview Box ───────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasImage
                  ?  AppColors.primaryBlue
                  :  Color(0xFFDDE1EA),
              width: hasImage ? 2 : 1,
            ),
          ),
          child: hasImage && imageBytes != null
              ? Stack(
            children: [
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.memory(
                  Uint8List.fromList(imageBytes),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              // Remove button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: provider.removeImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
              // File name badge
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    provider.pickedImageFile?.name ?? '',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined,
                    size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  'No image selected',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG or JPG, max 512×512',
                  style: TextStyle(
                      color: Colors.grey.shade300, fontSize: 11),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Pick Buttons ──────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: _ImagePickButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: provider.isPickingImage
                    ? null
                    : () => provider.pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),

        if (provider.isPickingImage)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              backgroundColor: Color(0xFFDDE1EA),
              color: AppColors.primaryBlue,
            ),
          ),
      ],
    );
  }
}

class _ImagePickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ImagePickButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor:  AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.primaryBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// MENU LIST PANEL (right side)
// ════════════════════════════════════════════════
class _MenuListPanel extends StatefulWidget {
  final AdminMenuProvider provider;
  const _MenuListPanel({required this.provider});

  @override
  State<_MenuListPanel> createState() => _MenuListPanelState();
}

class _MenuListPanelState extends State<_MenuListPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final masters =
    widget.provider.allMenus.where((m) => m.mainMenuMstID == 0).toList();
    final transactions =
    widget.provider.allMenus.where((m) => m.mainMenuMstID != 0).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor:  AppColors.primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor:  AppColors.primaryBlue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Masters (${masters.length})'),
              Tab(text: 'Transactions (${transactions.length})'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _MenuGroupList(menus: masters, groupLabel: 'Master'),
              _MenuGroupList(menus: transactions, groupLabel: 'Transaction'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuGroupList extends StatelessWidget {
  final List<AdminMenuModel> menus;
  final String groupLabel;
  const _MenuGroupList({required this.menus, required this.groupLabel});

  @override
  Widget build(BuildContext context) {
    if (menus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_open_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No $groupLabel menus yet',
                style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: menus.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) => _MenuTile(menu: menus[index]),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final AdminMenuModel menu;
  const _MenuTile({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEF0F5)),
      ),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor:  AppColors.primaryBlue.withOpacity(0.08),
          child: Text(
            '${menu.menuMstID}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        title: Text(
          menu.menuName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          menu.formName,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: menu.valid == 1 ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            menu.valid == 1 ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: menu.valid == 1 ? Colors.green.shade700 : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// REUSABLE FORM WIDGETS
// ════════════════════════════════════════════════
Widget _sectionHeader(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 4),
  child: Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryBlue,
    ),
  ),
);

class _TextInputField extends StatelessWidget {
  final String label;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;

  const _TextInputField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          decoration: _inputDecoration(hint),
          onChanged: onChanged,
          validator: validator,
          onSaved: (v) => onChanged(v ?? ''),
        ),
      ],
    );
  }
}

class _NumberInputField extends StatelessWidget {
  final String label;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const _NumberInputField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue.toString(),
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('Enter sort order'),
          onChanged: (v) => onChanged(int.tryParse(v) ?? 1),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Sort ID is required';
            if (int.tryParse(v) == null) return 'Must be a number';
            return null;
          },
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          decoration: _inputDecoration(hint),
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e))))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

Widget _label(String text) => Text(
  text,
  style: const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF3D3D3D),
  ),
);

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),

  isDense: true, // ✅ IMPORTANT (reduces height)

  contentPadding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 10, // 👈 controls height
  ),

  filled: true,
  fillColor: Colors.white,

  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: Color(0xFFDDE1EA)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: Color(0xFFDDE1EA)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: Colors.red),
  ),
);

// ════════════════════════════════════════════════
// ERROR VIEW
// ════════════════════════════════════════════════
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor:  AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}