import 'dart:async';

import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../core/utils/formatters.dart';
import '../models/cashier_summary.dart';
import 'printer_filter.dart';
import 'printer_preference_storage.dart';
import 'ticket_layout.dart';

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
      throw CashierSummaryPrinterException(
        e.cause != null ? "${e.message} — ${e.cause}" : e.message,
      );
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
    final printers = await manager.scanPrinters(
      types: {PrinterConnectionType.usb},
    );

    if (printers.isEmpty) {
      throw const CashierSummaryPrinterException(
        "Printer USB tidak ditemukan. Pastikan printer terhubung dan menyala.",
      );
    }

    final preferredId = await PrinterPreferenceStorage()
        .getSelectedPrinterIdentifier();
    await manager.connect(pickPrinter(printers, preferredId));
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
    ticket.separator(char: '=', linesAfter: 1);

    TicketLayout.row(ticket, "Kasir", cashierName);

    TicketLayout.sectionTitle(ticket, "Billing");
    TicketLayout.row(ticket, "Jumlah Nota", "${summary.billing.invoiceCount}");
    TicketLayout.row(
      ticket,
      "Total Transaksi",
      formatCurrency(summary.billing.totalTransaction),
    );
    _byPayment(ticket, summary.billing.byPayment);

    TicketLayout.sectionTitle(ticket, "Cafe / POS");
    TicketLayout.row(ticket, "Jumlah Nota", "${summary.cafe.invoiceCount}");
    TicketLayout.row(
      ticket,
      "Total Transaksi",
      formatCurrency(summary.cafe.totalTransaction),
    );
    _byPayment(ticket, summary.cafe.byPayment);

    ticket.separator(char: '-', linesAfter: 1);
    TicketLayout.row(ticket, "Total Nota", "${summary.totalInvoiceCount}");

    TicketLayout.grandTotal(ticket, "GRAND TOTAL", summary.totalTransaction);

    ticket.feed(3);
    ticket.cut();

    return ticket;
  }

  void _byPayment(Ticket ticket, List<CashierPaymentBreakdown> byPayment) {
    for (final payment in byPayment) {
      TicketLayout.row(
        ticket,
        "  ${payment.paymentName}",
        "${formatCurrency(payment.totalTransaction)} (${payment.invoiceCount})",
      );
    }
  }
}
