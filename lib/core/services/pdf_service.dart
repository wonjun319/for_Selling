import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/company.dart';
import '../../state/providers/doc_provider.dart';
import '../utils/formatters.dart';

class PdfService {
  static const double baseFont = 11;
  static const double titleFont = 13;
  static const double totalFont = 14;

  // Shared item-grid anchors for both templates.
  static const double itemsStartY = 318;
  static const double itemsRowH = 25.5;
  static const int maxRows = 14;

  static Future<Uint8List> buildPdf({required DocProvider doc}) async {
    final regularData = await rootBundle.load(
      'assets/fonts/NotoSansKR-Regular.ttf',
    );
    final boldData = await rootBundle.load('assets/fonts/NotoSansKR-Bold.ttf');

    final fontRegular = pw.Font.ttf(regularData);
    final fontBold = pw.Font.ttf(boldData);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
    );

    final templatePath = doc.docType == DocType.quote
        ? 'assets/templates/quote.png'
        : 'assets/templates/statement.png';

    final templateBytes = await rootBundle.load(templatePath);
    final bgImage = pw.MemoryImage(templateBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(child: pw.Image(bgImage, fit: pw.BoxFit.fill)),
              ..._buildFields(doc),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static List<pw.Widget> _buildFields(DocProvider doc) {
    return doc.docType == DocType.quote
        ? _fieldsQuote(doc)
        : _fieldsStatement(doc);
  }

  static List<pw.Widget> _fieldsQuote(DocProvider doc) {
    final my = doc.myCompany;
    final partner = doc.partnerCompany;

    final widgets = <pw.Widget>[
      _t(x: 93, y: 177, text: doc.yy),
      _t(x: 127, y: 177, text: doc.mm),
      _t(x: 153, y: 177, text: doc.dd),

      // Left block (recipient/work description area).
      _t(x: 67, y: 115, text: doc.workDesc, maxWidth: 92),
      _t(x: 87, y: 208, text: partner?.name ?? '', maxWidth: 110),

      // Supplier block (right table).
      _t(x: 335, y: 116, text: my == null ? '' : Formatters.bizNo(my.bizNo)),
      _t(x: 335, y: 141, text: my?.name ?? ''),
      _t(x: 476, y: 141, text: my?.ceo ?? ''),
      _t(
        x: 335,
        y: 163,
        text: my?.address ?? '',
        size: baseFont - 1,
        maxWidth: 205,
      ),
      _t(x: 335, y: 183, text: my?.bizType ?? '', maxWidth: 105),
      _t(x: 475, y: 183, text: my?.bizItem ?? '', maxWidth: 95),
      _t(x: 335, y: 206, text: my?.managerName ?? '', maxWidth: 105),
      _t(
        x: 475,
        y: 208,
        text: my == null ? '' : Formatters.phone(my.tel),
        maxWidth: 95,
      ),

      // Total amount (header line).
      _t(
        x: 225,
        y: 243,
        text: Formatters.amountToHangul(doc.totalAmount),
        maxWidth: 250,
      ),
      _t(
        x: 410,
        y: 240,
        text: Formatters.money(doc.totalAmount),
        size: totalFont,
        bold: true,
      ),
    ];

    widgets.addAll(_buildItemsRows(doc));

    widgets.addAll([
      _t(x: 223, y: 721, text: Formatters.money(doc.totalUnitPrice)),
      _t(x: 320, y: 721, text: Formatters.money(doc.totalSupply)),
      _t(
        x: 414,
        y: 721,
        text: doc.vatIncluded ? Formatters.money(doc.totalVat) : '',
      ),
      _t(x: 503, y: 721, text: Formatters.money(doc.totalAmount)),
    ]);

    final accountInfoText = _buildAccountInfoText(my);
    if (doc.showAccountInfo && accountInfoText.isNotEmpty) {
      widgets.add(
        _t(
          x: 180,
          y: 797,
          text: accountInfoText,
          size: baseFont - 0.5,
          maxWidth: 560,
        ),
      );
    }

    return widgets;
  }

  static List<pw.Widget> _fieldsStatement(DocProvider doc) {
    final my = doc.myCompany;
    final partner = doc.partnerCompany;

    final widgets = <pw.Widget>[
      _t(x: 111, y: 83, text: doc.yy),
      _t(x: 148, y: 83, text: doc.mm),
      _t(x: 182, y: 83, text: doc.dd),

      _t(x: 117, y: 124, text: my == null ? '' : Formatters.bizNo(my.bizNo)),
      _t(x: 117, y: 157, text: my?.name ?? ''),
      _t(x: 236, y: 160, text: my?.ceo ?? ''),
      _t(
        x: 117,
        y: 186,
        text: my?.address ?? '',
        size: baseFont - 1,
        maxWidth: 168,
      ),
      _t(x: 117, y: 224, text: my == null ? '' : Formatters.phone(my.tel)),

      _t(
        x: 394,
        y: 124,
        text: partner == null ? '' : Formatters.bizNo(partner.bizNo),
      ),
      _t(x: 394, y: 157, text: partner?.name ?? ''),
      _t(x: 508, y: 160, text: partner?.ceo ?? ''),
      _t(
        x: 394,
        y: 186,
        text: partner?.address ?? '',
        size: baseFont - 1,
        maxWidth: 168,
      ),
      _t(
        x: 394,
        y: 224,
        text: partner == null ? '' : Formatters.phone(partner.tel),
      ),

      _t(
        x: 259,
        y: 255,
        text: Formatters.amountToHangul(doc.totalAmount),
        maxWidth: 235,
      ),
      _t(
        x: 450,
        y: 253,
        text: Formatters.money(doc.totalAmount),
        size: totalFont,
        bold: true,
      ),
    ];

    widgets.addAll(_buildItemsRows(doc));

    widgets.addAll([
      _t(x: 223, y: 721, text: Formatters.money(doc.totalUnitPrice)),
      _t(x: 320, y: 721, text: Formatters.money(doc.totalSupply)),
      _t(
        x: 414,
        y: 721,
        text: doc.vatIncluded ? Formatters.money(doc.totalVat) : '',
      ),
      _t(x: 503, y: 721, text: Formatters.money(doc.totalAmount)),
    ]);

    final accountInfoText = _buildAccountInfoText(my);
    if (doc.showAccountInfo && accountInfoText.isNotEmpty) {
      widgets.add(
        _t(
          x: 28,
          y: 797,
          text: accountInfoText,
          size: baseFont - 0.5,
          maxWidth: 560,
        ),
      );
    }

    return widgets;
  }

  static String _buildAccountInfoText(Company? company) {
    if (company == null) return '';

    final bank = company.bankName.trim();
    final accountNo = company.accountNo.trim();
    final holder = company.accountHolder.trim();

    if (bank.isEmpty && accountNo.isEmpty && holder.isEmpty) return '';

    final parts = <String>[
      if (bank.isNotEmpty) bank,
      if (accountNo.isNotEmpty) accountNo,
      if (holder.isNotEmpty) holder,
    ];

    return '계좌정보: ${parts.join(' ')}';
  }

  static List<pw.Widget> _buildItemsRows(DocProvider doc) {
    final rows = <pw.Widget>[];
    final count = doc.items.length < maxRows ? doc.items.length : maxRows;
    final vatIncluded = doc.vatIncluded;

    for (int i = 0; i < count; i++) {
      final it = doc.items[i];
      final y = itemsStartY + (itemsRowH * i);

      rows.addAll([
        _t(
          x: 28,
          y: y,
          text: it.displayName,
          size: baseFont + 1,
          maxWidth: 125,
        ),
        _t(
          x: 223,
          y: y,
          text: Formatters.money(it.unitPrice),
          size: baseFont + 1,
        ),
        _t(
          x: 320,
          y: y,
          text: Formatters.money(it.supplyOf(vatIncluded)),
          size: baseFont + 1,
        ),
        // VAT column: left blank when VAT is excluded.
        _t(
          x: 414,
          y: y,
          text: vatIncluded ? Formatters.money(it.vatOf(true)) : '',
          size: baseFont + 1,
        ),
        _t(x: 503, y: y, text: Formatters.money(it.amount), size: baseFont + 1),
      ]);
    }

    return rows;
  }

  static pw.Widget _t({
    required double x,
    required double y,
    required String text,
    double? size,
    bool bold = false,
    double? maxWidth,
  }) {
    return pw.Positioned(
      left: x,
      top: y,
      child: pw.Container(
        width: maxWidth,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: size ?? baseFont,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
