import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../core/utils/formatters.dart';
import '../models/receipt.dart';
import '../models/saldo_receipt.dart';

class ReceiptPrinterException implements Exception {
  final String message;

  const ReceiptPrinterException(this.message);

  @override
  String toString() => message;
}

class ReceiptPrinterService {
  Future<void> printReceipt(Receipt receipt) {
    return _print(buildTicket: () => _buildTicket(receipt));
  }

  Future<void> printSaldoReceipt(SaldoReceipt receipt) {
    return _print(buildTicket: () => _buildSaldoTicket(receipt));
  }

  /// Shared USB scan/connect/print/disconnect flow — [buildTicket] builds
  /// whichever ticket layout the caller needs.
  Future<void> _print({
    required Future<Ticket> Function() buildTicket,
  }) async {
    final manager = PrinterManager();

    try {
      final printers = await manager.scanPrinters(
        types: {PrinterConnectionType.usb},
      );

      if (printers.isEmpty) {
        throw const ReceiptPrinterException(
          "Printer USB tidak ditemukan. Pastikan printer terhubung dan menyala.",
        );
      }

      await manager.connect(printers.first);
      await manager.printTicket(await buildTicket());
      await manager.disconnect();
    } on PrinterException catch (e) {
      throw ReceiptPrinterException(e.message);
    } finally {
      await manager.dispose();
    }
  }

  Future<Ticket> _buildSaldoTicket(SaldoReceipt receipt) async {
    final ticket = await Ticket.create(PaperSize.mm58);

    ticket.text(
      receipt.businessName,
      align: PrintAlign.center,
      style: const PrintTextStyle(bold: true),
    );
    ticket.text(receipt.businessAddress, align: PrintAlign.center);
    ticket.separator(char: '.');
    ticket.text(
      receipt.invoiceNumber,
      align: PrintAlign.center,
      style: const PrintTextStyle(bold: true),
    );
    ticket.feed(1);

    ticket.row([
      PrintColumn(text: "Member", flex: 3, style: const PrintTextStyle(bold: true)),
      PrintColumn(
        text: ": ${receipt.customerName}",
        flex: 5,
        style: const PrintTextStyle(bold: true),
      ),
    ]);
    ticket.row([
      PrintColumn(text: "Tanggal", flex: 3),
      PrintColumn(text: ": ${formatFullDate(receipt.date)}", flex: 5),
    ]);
    ticket.row([
      PrintColumn(text: "Metode Bayar", flex: 3),
      PrintColumn(text: ": ${receipt.paymentMethod}", flex: 5),
    ]);

    ticket.feed(1);
    _amountRow(ticket, "Nominal Saldo", formatThousands(receipt.nominal));
    _amountRow(ticket, "Diskon", formatThousands(receipt.discount));
    ticket.separator(char: '.');
    _amountRow(
      ticket,
      "Total Dibayar",
      formatThousands(receipt.price),
      bold: true,
    );

    ticket.feed(1);
    ticket.text("Kasir : ${receipt.cashierName}");
    ticket.feed(3);
    ticket.cut();

    return ticket;
  }

  Future<Ticket> _buildTicket(Receipt receipt) async {
    final ticket = await Ticket.create(PaperSize.mm58);

    ticket.text(
      receipt.businessName,
      align: PrintAlign.center,
      style: const PrintTextStyle(bold: true),
    );
    ticket.text(receipt.businessAddress, align: PrintAlign.center);
    ticket.separator(char: '.');
    ticket.text(
      receipt.invoiceNumber,
      align: PrintAlign.center,
      style: const PrintTextStyle(bold: true),
    );
    ticket.feed(1);

    ticket.row([
      PrintColumn(
        text: "Table",
        flex: 3,
        style: const PrintTextStyle(bold: true),
      ),
      PrintColumn(
        text: ": ${receipt.tableLabel}",
        flex: 5,
        style: const PrintTextStyle(bold: true),
      ),
    ]);

    if (receipt.periods.isNotEmpty) {
      ticket.feed(1);
      ticket.row([
        for (final period in receipt.periods)
          PrintColumn(
            text: period.label,
            align: PrintAlign.center,
            style: const PrintTextStyle(bold: true),
          ),
      ]);
      ticket.separator(char: '.');
      ticket.row([
        for (final period in receipt.periods)
          PrintColumn(text: "Lama: ${formatDuration(period.duration)}"),
      ]);
      ticket.row([
        for (final period in receipt.periods)
          PrintColumn(text: "Biaya: ${formatThousands(period.cost)}"),
      ]);
    }

    ticket.feed(1);
    ticket.row([
      PrintColumn(text: "Tanggal", flex: 3),
      PrintColumn(text: ": ${formatFullDate(receipt.date)}", flex: 5),
    ]);
    ticket.row([
      PrintColumn(text: "Mulai", flex: 3),
      PrintColumn(text: ": ${formatClock(receipt.startAt)}", flex: 5),
    ]);
    ticket.row([
      PrintColumn(text: "Selesai", flex: 3),
      PrintColumn(text: ": ${formatClock(receipt.endAt)}", flex: 5),
    ]);
    ticket.row([
      PrintColumn(text: "Total Durasi", flex: 3),
      PrintColumn(
        text: ": ${formatDurationWords(receipt.totalDuration)}",
        flex: 5,
      ),
    ]);

    ticket.feed(1);
    _amountRow(ticket, "Total Table", formatThousands(receipt.totalTable));
    _amountRow(ticket, "Netto Table", formatThousands(receipt.nettoTable));
    ticket.separator(char: '.');
    _amountRow(ticket, "Subtotal", formatThousands(receipt.subtotal));
    _amountRow(ticket, "Diskon", "${receipt.discountPercent}%");
    ticket.separator(char: '.');
    _amountRow(
      ticket,
      "Grand Total",
      formatThousands(receipt.grandTotal),
      bold: true,
    );

    ticket.feed(1);
    ticket.text("Kasir : ${receipt.cashierName}");
    ticket.feed(3);
    ticket.cut();

    return ticket;
  }

  void _amountRow(
    Ticket ticket,
    String label,
    String value, {
    bool bold = false,
  }) {
    ticket.row([
      PrintColumn(
        text: label,
        flex: 3,
        align: PrintAlign.right,
        style: PrintTextStyle(bold: bold),
      ),
      PrintColumn(
        text: ": $value",
        flex: 3,
        align: PrintAlign.right,
        style: PrintTextStyle(bold: bold),
      ),
    ]);
  }
}
