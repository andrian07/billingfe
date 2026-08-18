import 'dart:async';

import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../core/utils/formatters.dart';
import '../models/cashier_summary.dart';
import 'printer_filter.dart';

class CashierSummaryPrinterException implements Exception {
  final String message;

  const CashierSummaryPrinterException(this.message);

  @override
  String toString() => message;
}

/// Prints the "Tutup Kas" (close register) ticket for a cashier's
/// today-so-far summary, via the same USB ESC/POS flow as
/// [ReceiptPrinterService].
class CashierSummaryPrinterService {
  Future<void> printSummary(
    CashierClosingSummary summary, {
    required String cashierName,
  }) async {
    final manager = PrinterManager();

    try {
      await _run(manager, summary, cashierName).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw const CashierSummaryPrinterException(
          "Printer tidak merespon dalam 15 detik. Periksa kabel USB, "
          "pastikan printer menyala, lalu coba lagi.",
        ),
      );
    } on PrinterException catch (e) {
      throw CashierSummaryPrinterException(e.message);
    } finally {
      // Fire-and-forget with its own timeout: if the hang that triggered
      // the timeout above is inside the plugin's native call, dispose()
      // would queue behind it and never return either — that must not
      // block this method from returning the error to the caller.
      unawaited(
        manager.dispose().timeout(const Duration(seconds: 3), onTimeout: () {}),
      );
    }
  }

  Future<void> _run(
    PrinterManager manager,
    CashierClosingSummary summary,
    String cashierName,
  ) async {
    final printers = excludeVirtualPrinters(
      await manager.scanPrinters(types: {PrinterConnectionType.usb}),
    );

    if (printers.isEmpty) {
      throw const CashierSummaryPrinterException(
        "Printer USB tidak ditemukan. Pastikan printer terhubung dan menyala.",
      );
    }

    await manager.connect(printers.first);
    await manager.printTicket(await _buildTicket(summary, cashierName));
    await manager.disconnect();
  }

  Future<Ticket> _buildTicket(
    CashierClosingSummary summary,
    String cashierName,
  ) async {
    final ticket = await Ticket.create(PaperSize.mm80);

    ticket.text(
      "TUTUP KAS",
      align: PrintAlign.center,
      style: const PrintTextStyle(bold: true),
    );
    ticket.text(formatFullDate(summary.businessDate), align: PrintAlign.center);
    ticket.separator(char: '.');
    ticket.feed(1);

    ticket.row([
      PrintColumn(text: "Kasir", flex: 3),
      PrintColumn(text: ": $cashierName", flex: 5),
    ]);

    ticket.feed(1);
    ticket.text("Billing", style: const PrintTextStyle(bold: true));
    _kv(ticket, "Jumlah Nota", "${summary.billing.invoiceCount}");
    _kv(
      ticket,
      "Total Transaksi",
      formatThousands(summary.billing.totalTransaction),
    );
    _byPayment(ticket, summary.billing.byPayment);

    ticket.feed(1);
    ticket.text("Cafe / POS", style: const PrintTextStyle(bold: true));
    _kv(ticket, "Jumlah Nota", "${summary.cafe.invoiceCount}");
    _kv(
      ticket,
      "Total Transaksi",
      formatThousands(summary.cafe.totalTransaction),
    );
    _byPayment(ticket, summary.cafe.byPayment);

    ticket.separator(char: '.');
    _kv(ticket, "Total Nota", "${summary.totalInvoiceCount}", bold: true);
    _kv(
      ticket,
      "Grand Total",
      formatThousands(summary.totalTransaction),
      bold: true,
    );

    ticket.feed(3);
    ticket.cut();

    return ticket;
  }

  void _byPayment(Ticket ticket, List<CashierPaymentBreakdown> byPayment) {
    for (final payment in byPayment) {
      _kv(
        ticket,
        "  ${payment.paymentName}",
        "${formatThousands(payment.totalTransaction)} (${payment.invoiceCount})",
      );
    }
  }

  void _kv(Ticket ticket, String label, String value, {bool bold = false}) {
    ticket.row([
      PrintColumn(
        text: label,
        flex: 3,
        style: PrintTextStyle(bold: bold),
      ),
      PrintColumn(
        text: ": $value",
        flex: 5,
        align: PrintAlign.right,
        style: PrintTextStyle(bold: bold),
      ),
    ]);
  }
}
