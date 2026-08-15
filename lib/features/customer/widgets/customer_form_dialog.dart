import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../models/customer.dart';

class CustomerFormResult {
  final String name;
  final String phone;
  final String address;
  final String email;
  final String password;

  const CustomerFormResult({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.password,
  });
}

class CustomerFormDialog extends StatefulWidget {
  final Customer? customer;

  const CustomerFormDialog({super.key, this.customer});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.customer?.name ?? "",
  );
  late final _phoneController = TextEditingController(
    text: widget.customer?.phone ?? "",
  );
  late final _addressController = TextEditingController(
    text: widget.customer?.address ?? "",
  );
  late final _emailController = TextEditingController(
    text: widget.customer?.email ?? "",
  );
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool get _isEdit => widget.customer != null;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      CustomerFormResult(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
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
        width: 420,
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

                _label("Nama Member"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: AppText.body,
                  decoration: _inputDecoration(
                    hint: "Masukkan nama member",
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? "Nama wajib diisi"
                      : null,
                ),

                const SizedBox(height: 20),
                _label("No. Telepon"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: AppText.body,
                  decoration: _inputDecoration(
                    hint: "Masukkan no. telepon",
                    prefixIcon: Icons.phone_outlined,
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? "No. telepon wajib diisi"
                      : null,
                ),

                const SizedBox(height: 20),
                _label("Alamat (Opsional)"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  style: AppText.body,
                  maxLines: 2,
                  decoration: _inputDecoration(
                    hint: "Masukkan alamat",
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ),

                const SizedBox(height: 20),
                _label("Email (Opsional)"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppText.body,
                  decoration: _inputDecoration(
                    hint: "Masukkan email",
                    prefixIcon: Icons.mail_outline_rounded,
                  ),
                ),

                const SizedBox(height: 20),
                _label("Password (Opsional)"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppText.body,
                  decoration:
                      _inputDecoration(
                        hint: _isEdit
                            ? "Kosongkan jika tidak ingin mengubah"
                            : "Masukkan password",
                        prefixIcon: Icons.lock_outline_rounded,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                ),

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
                        icon: Icon(
                          _isEdit
                              ? Icons.save_outlined
                              : Icons.person_add_alt_1_rounded,
                          size: 20,
                        ),
                        label: Text(_isEdit ? "SIMPAN" : "TAMBAH MEMBER"),
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
            Icons.people_alt_outlined,
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
                _isEdit ? "Edit Member" : "Tambah Member",
                style: AppText.title.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                _isEdit ? "Perbarui data member" : "Daftarkan member baru",
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

  InputDecoration _inputDecoration({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.caption,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
          : null,
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
