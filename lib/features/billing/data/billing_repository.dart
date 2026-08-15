import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/pool_table.dart';
import '../../../models/saved_customer_time.dart';

class BillingRepositoryException implements Exception {
  final String message;

  const BillingRepositoryException(this.message);

  @override
  String toString() => message;
}

class PriceCalculation {
  final int totalBilling;
  final int totalPromo;
  final int totalTax;
  final int totalPembulatan;
  final int totalTransaksi;

  const PriceCalculation({
    required this.totalBilling,
    required this.totalPromo,
    required this.totalTax,
    required this.totalPembulatan,
    required this.totalTransaksi,
  });

  factory PriceCalculation.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? "") ?? 0;
    }

    return PriceCalculation(
      totalBilling: asInt(json['total_billing']),
      totalPromo: asInt(json['total_promo']),
      totalTax: asInt(json['total_tax']),
      totalPembulatan: asInt(json['total_pembulatan']),
      totalTransaksi: asInt(json['total_transaksi']),
    );
  }
}

/// Books/starts table sessions and computes their bill via the Billing/*
/// endpoints.
class BillingRepository {
  final Dio _dio = Dio();

  Future<void> bookTable({
    required String tableId,
    required SessionType mode,
    required DateTime startTime,
    int? customerId,
    int? promoId,
    DateTime? endTime,
    Duration? duration,
    bool? useSavedTime,
  }) async {
    final payload = <String, dynamic>{
      "table_id": tableId,
      "table_mode": mode == SessionType.timer ? "Timer" : "Reguler",
      "table_start_time": formatApiDateTime(startTime),
      if (customerId != null) "table_customer_id": "$customerId",
      if (promoId != null) "table_promo_id": "$promoId",
      if (endTime != null) "table_end_time": formatApiDateTime(endTime),
      if (duration != null) "table_duration": formatDuration(duration),
      if (useSavedTime != null) "use_saved_time": useSavedTime ? "Y" : "N",
    };

    await _post(ApiEndpoints.bookTable, payload);
  }

  /// Looks up a customer's banked play time for the given table's category
  /// via Master/get_save_customer_time — used by the start-session dialog to
  /// offer "pakai waktu tersisa?" when a member with a balance is selected.
  /// Returns null when the lookup itself fails (e.g. table/category not
  /// set up), since that just means no saved-time offer should be shown.
  Future<SavedCustomerTime?> getSavedCustomerTime({
    required int customerId,
    required String tableId,
  }) async {
    try {
      final data = await _post(ApiEndpoints.getSaveCustomerTime, {
        "customer_id": customerId,
        "table_id": int.tryParse(tableId) ?? tableId,
      });

      final result = data['result'];
      if (result is! Map<String, dynamic>) return null;
      return SavedCustomerTime.fromJson(result);
    } on BillingRepositoryException {
      return null;
    }
  }

  Future<PriceCalculation> calculatePrice({required String tableId}) async {
    final data = await _post(ApiEndpoints.calculationPrice, {
      "table_id": tableId,
    });

    final result = data['result'];
    if (result is! Map<String, dynamic>) {
      throw const BillingRepositoryException(
        "Format hasil kalkulasi harga tidak valid.",
      );
    }

    return PriceCalculation.fromJson(result);
  }

  /// Checks whether the "simpan sisa waktu" (save remaining time) choice
  /// should be offered on the payment summary for timer-mode tables.
  Future<bool> checkTimeSave() async {
    final data = await _post(ApiEndpoints.checkTimeSave, const {});

    final result = data['result'];
    final flag = result is Map<String, dynamic>
        ? result['check_time_save']
        : data['check_time_save'];

    return flag?.toString().toUpperCase() == "Y";
  }

  Future<void> addDuration({
    required String tableId,
    required Duration additionalDuration,
  }) async {
    await _post(ApiEndpoints.addDuration, {
      "table_id": int.tryParse(tableId) ?? tableId,
      "additional_duration": formatDuration(additionalDuration),
    });
  }

  Future<void> cancelTable({
    required String tableId,
    required String createdBy,
    required int paidBy,
  }) async {
    await _post(ApiEndpoints.cancelTable, {
      "table_id": int.tryParse(tableId) ?? tableId,
      "created_by": createdBy,
      "paid_by": paidBy,
    });
  }

  Future<void> moveTable({
    required String fromTableId,
    required String toTableId,
  }) async {
    await _post(ApiEndpoints.moveTable, {
      "from_table_id": int.tryParse(fromTableId) ?? fromTableId,
      "to_table_id": int.tryParse(toTableId) ?? toTableId,
    });
  }

  Future<void> submitPayment({
    required String tableId,
    required SessionType? mode,
    required DateTime startTime,
    required DateTime endTime,
    required Duration duration,
    required int subTotal,
    required int tax,
    required int totalBill,
    required String createdBy,
    required int paidBy,
    required int paymentId,
    int? customerId,
    int? promoId,
    bool? saveTime,
    Duration? remainingTime,
    bool? usedSavedTime,
  }) async {
    await _post(ApiEndpoints.payment, {
      if (mode != null)
        "transaction_mode": mode == SessionType.timer ? "Timer" : "Reguler",
      if (customerId != null) "transaction_customer_id": "$customerId",
      "transaction_payment_id": "$paymentId",
      if (promoId != null) "transaction_promo_id": "$promoId",
      "transaction_start_time": formatApiDateTime(startTime),
      "transaction_end_time": formatApiDateTime(endTime),
      "transaction_duration": formatDuration(duration),
      if (remainingTime != null)
        "transaction_remaining_time": formatDuration(remainingTime),
      "transaction_sub_total": "$subTotal",
      "transaction_tax": "$tax",
      "transaction_total_bill": "$totalBill",
      "transaction_table": tableId,
      "created_by": createdBy,
      "paid_by": "$paidBy",
      if (saveTime != null) "save_time": saveTime ? "Y" : "N",
      if (usedSavedTime != null)
        "used_save_time": usedSavedTime ? "Y" : "N",
    });
  }

  Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(url, data: payload);

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          throw const BillingRepositoryException("Format respons tidak valid.");
        }
      }
      if (data is! Map<String, dynamic>) {
        throw const BillingRepositoryException("Format respons tidak valid.");
      }

      final code = data['code'];
      if (code != null && code.toString() != "200") {
        throw BillingRepositoryException(
          data['message']?.toString() ??
              data['result']?.toString() ??
              "Permintaan gagal.",
        );
      }

      return data;
    } on BillingRepositoryException {
      rethrow;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        throw BillingRepositoryException(responseData['message'].toString());
      }
      throw const BillingRepositoryException(
        "Tidak dapat terhubung ke server. Periksa koneksi Anda.",
      );
    }
  }
}
