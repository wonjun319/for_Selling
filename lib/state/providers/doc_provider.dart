import 'package:flutter/material.dart';

import '../../data/models/company.dart';
import '../../data/models/item.dart';

enum DocType { quote, statement }

enum VatMode { included, excluded }

class DocProvider extends ChangeNotifier {
  DocType docType = DocType.quote;
  DateTime date = DateTime.now();
  bool useToday = true;
  bool showAccountInfo = false;
  VatMode vatMode = VatMode.included;

  bool get vatIncluded => vatMode == VatMode.included;

  Company? myCompany;
  Company? partnerCompany;

  String workDesc = '';

  final List<Item> items = [];

  int pdfRevision = 0;

  void touchPdf() {
    pdfRevision++;
    notifyListeners();
  }

  void setDocType(DocType v) {
    docType = v;
    touchPdf();
  }

  void setDate(DateTime v) {
    date = v;
    useToday = false;
    touchPdf();
  }

  void setUseToday(bool v) {
    useToday = v;
    if (v) {
      date = DateTime.now();
    }
    touchPdf();
  }

  void setShowAccountInfo(bool v) {
    showAccountInfo = v;
    touchPdf();
  }

  void setVatIncluded(bool v) {
    vatMode = v ? VatMode.included : VatMode.excluded;
    touchPdf();
  }

  void setMyCompany(Company? c) {
    myCompany = c;
    touchPdf();
  }

  void setPartnerCompany(Company? c) {
    partnerCompany = c;
    touchPdf();
  }

  void setWorkDesc(String v) {
    workDesc = v;
    touchPdf();
  }

  void addItem() {
    items.add(Item());
    touchPdf();
  }

  void removeItem(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    touchPdf();
  }

  int get totalUnitPrice => items.fold(0, (sum, it) => sum + it.unitPrice);
  int get totalSupply =>
      items.fold(0, (sum, it) => sum + it.supplyOf(vatIncluded));
  int get totalVat => items.fold(0, (sum, it) => sum + it.vatOf(vatIncluded));
  int get totalAmount => items.fold(0, (sum, it) => sum + it.amount);

  String get yy => (date.year % 100).toString().padLeft(2, '0');
  String get mm => date.month.toString().padLeft(2, '0');
  String get dd => date.day.toString().padLeft(2, '0');
}
