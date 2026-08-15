import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/thousands_input_formatter.dart';
import '../../../models/price_setting.dart';

class PriceEditResult {
  final int price1;
  final int price2;
  final int price3;
  final int price4;
  final int price5;

  const PriceEditResult({
    required this.price1,
    required this.price2,
    required this.price3,
    required this.price4,
    required this.price5,
  });
}

class PriceEditDialog extends StatefulWidget {
  final String dayLabel;
  final String hourLabel;
  final PriceSetting item;

  const PriceEditDialog({
    super.key,
    required this.dayLabel,
    required this.hourLabel,
    required this.item,
  });

  @override
  State<PriceEditDialog> createState() => _PriceEditDialogState();
}

class _PriceEditDialogState extends State<PriceEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controllers = [
    TextEditingController(text: formatThousands(widget.item.price1)),
    TextEditingController(text: formatThousands(widget.item.price2)),
    TextEditingController(text: formatThousands(widget.item.price3)),
    TextEditingController(text: formatThousands(widget.item.price4)),
    TextEditingController(text: formatThousands(widget.item.price5)),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      PriceEditResult(
        price1: parseThousands(_controllers[0].text) ?? 0,
        price2: parseThousands(_controllers[1].text) ?? 0,
        price3: parseThousands(_controllers[2].text) ?? 0,
        price4: parseThousands(_controllers[3].text) ?? 0,
        price5: parseThousands(_controllers[4].text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      backgroundColor: AppColors.card,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(color: AppColors.border),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 22),

                for (var i = 0; i < 5; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _label("Harga ${i + 1}"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _controllers[i],
                    keyboardType: TextInputType.number,
                    inputFormatters: const [ThousandsInputFormatter()],
                    style: AppText.body,
                    decoration: _inputDecoration(),
                    validator: (value) {
                      final parsed = parseThousands(value ?? "");
                      if (parsed == null || parsed < 0) {
                        return "Masukkan angka yang valid";
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                        ),
                        child: const Text("BATAL"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_outlined, size: 20),
                        label: const Text("SIMPAN"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          textStyle: AppText.button,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: const Icon(
            Icons.sell_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Harga",
                style: AppText.title.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                "${widget.dayLabel} • ${widget.hourLabel}",
                style: AppText.caption,
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: AppText.bodySecondary.copyWith(fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: "0",
      hintStyle: AppText.caption,
      prefixText: "Rp ",
      prefixStyle: AppText.body.copyWith(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }
}
