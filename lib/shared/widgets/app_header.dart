import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../features/attendance/widgets/absensi_scan_dialog.dart';
import '../../features/cashier/widgets/tutup_kas_dialog.dart';
import '../../services/session_storage.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showSearch;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.header,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppText.heading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppText.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          if (showSearch) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],

          OutlinedButton.icon(
            onPressed: () => _openAbsensiScan(context),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: const Text("Absensi"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
            ),
          ),

          const SizedBox(width: 8),

          OutlinedButton.icon(
            onPressed: () => _openTutupKas(context),
            icon: const Icon(Icons.summarize_rounded, size: 18),
            label: const Text("Tutup Kas"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            tooltip: "Test Lampu Meja",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Menguji lampu meja...")),
              );
            },
            icon: const Icon(Icons.lightbulb_outline),
          ),

          const SizedBox(width: 8),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Kasir 1",
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text("Admin", style: AppText.caption),
                ],
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openAbsensiScan(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AbsensiScanDialog(),
    );
  }

  Future<void> _openTutupKas(BuildContext context) async {
    final session = await SessionStorage().getSession();
    final userId = int.tryParse(session?['id']?.toString() ?? "") ?? 0;
    final cashierName = session?['username']?.toString() ?? "Kasir";

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => TutupKasDialog(userId: userId, cashierName: cashierName),
    );
  }
}
