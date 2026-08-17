import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/session_storage.dart';

const _routesByKey = {
  'meja': '/meja',
  'pos': '/pos',
  'transaksi': '/transaksi',
  'pengguna': '/pengguna',
  'role': '/role',
  'pengaturan': '/pengaturan',
  'promo': '/promo',
  'produk': '/produk',
  'pembelian': '/pembelian',
  'laporan_billing': '/laporan/billing',
  'laporan_cafe': '/laporan/cafe',
  'laporan_stok': '/laporan/stok',
  'unit': '/unit',
  'kategori': '/kategori',
  'setting_table': '/setting/table',
};

Future<void> navigateToMenu(BuildContext context, String key) async {
  if (key == 'logout') {
    await SessionStorage().clearSession();
    if (context.mounted) context.go('/login');
    return;
  }

  final route = _routesByKey[key];
  if (route == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur ini akan segera hadir")),
    );
    return;
  }

  context.go(route);
}
