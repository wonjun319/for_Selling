class Item {
  String presetId;
  String name;
  int qty;
  int unitPrice; // VAT included unit price

  Item({this.presetId = '', this.name = '', this.qty = 1, this.unitPrice = 0});

  String get displayName {
    final n = name.trim();
    if (n.isEmpty) return '';
    final q = qty <= 0 ? 1 : qty;
    return '$n*$q';
  }

  // Total amount (VAT included)
  int get amount => unitPrice * (qty <= 0 ? 1 : qty);

  // Split included VAT: supply + vat == amount
  int get supply => (amount / 1.1).round();
  int get vat => amount - supply;
}
