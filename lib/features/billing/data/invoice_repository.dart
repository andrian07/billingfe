import '../../../core/constants/business_info.dart';
import '../../../models/pool_table.dart';
import '../../../models/receipt.dart';
import '../widgets/payment_dialog.dart';

/// Builds invoice data for the receipt printer.
///
/// Amounts are not computed here — there is no pricing engine in this app
/// yet, so totals are placeholders until this reads from the billing API.
class InvoiceRepository {
  int _localSequence = 0;

  Future<Receipt> generateInvoice(PoolTable table, PaymentResult payment) {
    final now = DateTime.now();
    final start = table.startAt ?? now;
    final duration = now.difference(start);

    _localSequence++;

    return Future.value(
      Receipt(
        businessName: BusinessInfo.name,
        businessAddress: BusinessInfo.address,
        invoiceNumber: _buildInvoiceNumber(now),
        tableLabel: "${_tableNumber(table)} - ${_sessionLabel(table)}",
        periods: const [],
        date: now,
        startAt: start,
        endAt: now,
        totalDuration: duration.isNegative ? Duration.zero : duration,
        totalTable: 0,
        nettoTable: 0,
        subtotal: 0,
        discountPercent: 0,
        grandTotal: 0,
        cashierName: "owner",
      ),
    );
  }

  String _buildInvoiceNumber(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    final date = "${now.year}-${two(now.month)}-${two(now.day)}";
    return "INV/${BusinessInfo.outletCode}/$date/${_localSequence.toString().padLeft(10, '0')}";
  }

  String _tableNumber(PoolTable table) =>
      table.name.replaceAll(RegExp(r'[^0-9]'), '');

  String _sessionLabel(PoolTable table) {
    switch (table.sessionType) {
      case SessionType.timer:
        return "Timer";
      case SessionType.reguler:
        return "Reguler";
      case null:
        return "-";
    }
  }
}
