import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

/// On Windows, USB printer "scanning" goes through the Print Spooler and
/// lists every installed printer — including virtual ones like "Send to
/// OneNote", "Microsoft Print to PDF", or "Fax" — not just the physical
/// thermal printer. Picking the first scan result can silently route
/// receipts to one of these instead. This filters known virtual printers
/// out so the real printer is preferred; if nothing survives the filter
/// (e.g. only virtual printers are installed), the original list is
/// returned so callers still get a usable error instead of an empty one.
const _virtualPrinterKeywords = [
  'onenote',
  'pdf',
  'fax',
  'xps document writer',
];

List<PrinterDevice> excludeVirtualPrinters(List<PrinterDevice> printers) {
  final real = printers.where((printer) {
    final name = printer.name.toLowerCase();
    return !_virtualPrinterKeywords.any(name.contains);
  }).toList();
  return real.isEmpty ? printers : real;
}
