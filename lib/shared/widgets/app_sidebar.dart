import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import 'app_menu_item.dart';

class AppSidebar extends StatelessWidget {
  final String activeKey;
  final ValueChanged<String> onSelect;

  /// `menuKey`s the current user's role may view. Null means unrestricted
  /// (superadmin, or permission data hasn't loaded yet) and shows every
  /// item; sections left with no visible items are hidden entirely. Logout
  /// is rendered separately below and is always shown regardless.
  final Set<String>? allowedMenuKeys;

  const AppSidebar({
    super.key,
    required this.activeKey,
    required this.onSelect,
    this.allowedMenuKeys,
  });

  static const _sections = [
    SidebarSection(
      title: "TRANSAKSI",
      items: [
        AppMenuItem(
          title: "Meja",
          icon: Icons.table_bar_rounded,
          menuKey: "meja",
        ),
        AppMenuItem(
          title: "POS",
          icon: Icons.point_of_sale_rounded,
          menuKey: "pos",
        ),
        AppMenuItem(
          title: "Transaksi",
          icon: Icons.receipt_long_rounded,
          menuKey: "transaksi",
        ),
      ],
    ),
    SidebarSection(
      title: "MASTER",
      items: [
        AppMenuItem(
          title: "Pengguna",
          icon: Icons.manage_accounts_outlined,
          menuKey: "pengguna",
        ),
        AppMenuItem(
          title: "Role & Akses",
          icon: Icons.admin_panel_settings_outlined,
          menuKey: "role",
        ),
        AppMenuItem(
          title: "Promo",
          icon: Icons.local_offer_outlined,
          menuKey: "promo",
        ),
      ],
    ),
    SidebarSection(
      title: "PRODUK",
      items: [
        AppMenuItem(
          title: "Produk",
          icon: Icons.inventory_2_outlined,
          menuKey: "produk",
        ),
        AppMenuItem(
          title: "Pembelian",
          icon: Icons.shopping_cart_checkout_rounded,
          menuKey: "pembelian",
        ),
        AppMenuItem(
          title: "Unit",
          icon: Icons.straighten_outlined,
          menuKey: "unit",
        ),
        AppMenuItem(
          title: "Kategori",
          icon: Icons.category_outlined,
          menuKey: "kategori",
        ),
      ],
    ),
    SidebarSection(
      title: "LAPORAN",
      items: [
        AppMenuItem(
          title: "Laporan Billing",
          icon: Icons.table_chart_outlined,
          menuKey: "laporan_billing",
        ),
        AppMenuItem(
          title: "Laporan Cafe",
          icon: Icons.local_cafe_outlined,
          menuKey: "laporan_cafe",
        ),
        AppMenuItem(
          title: "Laporan Stok",
          icon: Icons.bar_chart_rounded,
          menuKey: "laporan_stok",
        ),
      ],
    ),
    SidebarSection(
      title: "SETTING",
      items: [
        AppMenuItem(
          title: "Harga Meja",
          icon: Icons.settings_outlined,
          menuKey: "pengaturan",
        ),
        AppMenuItem(
          title: "Table",
          icon: Icons.settings_input_component_rounded,
          menuKey: "setting_table",
        ),
      ],
    ),
  ];

  static const _logoutItem = AppMenuItem(
    title: "Keluar",
    icon: Icons.logout_rounded,
    menuKey: "logout",
  );

  List<SidebarSection> get _visibleSections {
    final allowed = allowedMenuKeys;
    if (allowed == null) return _sections;

    return [
      for (final section in _sections)
        SidebarSection(
          title: section.title,
          items: [
            for (final item in section.items)
              if (allowed.contains(item.menuKey)) item,
          ],
        ),
    ].where((section) => section.items.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      color: AppColors.sidebar,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Logo
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "8",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Billing",
                  style: AppText.title,
                  maxLines: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          /// Menu
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final section in _visibleSections) ...[
                    _SectionHeader(title: section.title),
                    const SizedBox(height: 6),
                    for (final item in section.items) ...[
                      _MenuTile(
                        item: item,
                        active: activeKey == item.menuKey,
                        onTap: () => onSelect(item.menuKey),
                      ),
                      const SizedBox(height: 4),
                    ],
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),

          const Divider(),
          const SizedBox(height: 4),

          /// Logout
          _MenuTile(
            item: _logoutItem,
            active: false,
            color: AppColors.danger,
            onTap: () => onSelect(_logoutItem.menuKey),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: AppText.caption.copyWith(
          letterSpacing: .8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final AppMenuItem item;
  final bool active;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({
    required this.item,
    required this.active,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? (active ? Colors.white : AppColors.textSecondary);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: fg, size: AppSizes.iconSmall),
            const SizedBox(width: 12),
            Text(item.title, style: AppText.body.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}
