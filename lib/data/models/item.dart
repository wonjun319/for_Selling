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

  // Total amount (unit price * qty)
  int get amount => unitPrice * (qty <= 0 ? 1 : qty);

  // Supply value.
  // - VAT included: split out the 10% VAT (supply + vat == amount).
  // - VAT excluded: no split, the whole amount is the supply value.
  int supplyOf(bool vatIncluded) =>
      vatIncluded ? (amount / 1.1).round() : amount;

  // VAT amount. Zero when VAT is excluded (rendered blank in documents).
  int vatOf(bool vatIncluded) => vatIncluded ? amount - supplyOf(true) : 0;
}
