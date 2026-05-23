import 'package:hive/hive.dart';

class ItemPreset {
  final String id;
  String name;
  int unitPrice;

  ItemPreset({
    required this.id,
    this.name = '',
    this.unitPrice = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unitPrice': unitPrice,
    };
  }

  factory ItemPreset.fromMap(Map<String, dynamic> map) {
    return ItemPreset(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      unitPrice: (map['unitPrice'] as int?) ?? 0,
    );
  }
}

class Company extends HiveObject {
  String id;
  String name;
  String ceo;
  String bizNo;
  String address;
  String tel;
  String bankName;
  String accountNo;
  String accountHolder;
  String bizType;
  String bizItem;
  String managerName;
  List<ItemPreset> itemPresets;

  Company({
    required this.id,
    required this.name,
    required this.ceo,
    required this.bizNo,
    required this.address,
    required this.tel,
    this.bankName = '',
    this.accountNo = '',
    this.accountHolder = '',
    this.bizType = '',
    this.bizItem = '',
    this.managerName = '',
    this.itemPresets = const [],
  });
}

class CompanyAdapter extends TypeAdapter<Company> {
  @override
  final int typeId = 1;

  @override
  Company read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    String bankName = '';
    String accountNo = '';
    String accountHolder = '';
    String bizType = '';
    String bizItem = '';
    String managerName = '';
    List<ItemPreset> itemPresets = const [];

    // v4: 6 bank, 7 account, 8 holder, 9 bizType, 10 bizItem, 11 manager, 12 presets
    if (fields[12] is List) {
      bankName = (fields[6] as String?) ?? '';
      accountNo = (fields[7] as String?) ?? '';
      accountHolder = (fields[8] as String?) ?? '';
      bizType = (fields[9] as String?) ?? '';
      bizItem = (fields[10] as String?) ?? '';
      managerName = (fields[11] as String?) ?? '';
      itemPresets = ((fields[12] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => ItemPreset.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } else if (fields[11] is List) {
      // v3: 6 bank, 7 account, 8 bizType, 9 bizItem, 10 manager, 11 presets
      bankName = (fields[6] as String?) ?? '';
      accountNo = (fields[7] as String?) ?? '';
      bizType = (fields[8] as String?) ?? '';
      bizItem = (fields[9] as String?) ?? '';
      managerName = (fields[10] as String?) ?? '';
      itemPresets = ((fields[11] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => ItemPreset.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } else {
      // v1/v2: 6 bizType, 7 bizItem, 8 manager, (optional) 9 presets
      bizType = (fields[6] as String?) ?? '';
      bizItem = (fields[7] as String?) ?? '';
      managerName = (fields[8] as String?) ?? '';
      itemPresets = ((fields[9] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => ItemPreset.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    }

    return Company(
      id: fields[0] as String,
      name: fields[1] as String,
      ceo: fields[2] as String,
      bizNo: fields[3] as String,
      address: fields[4] as String,
      tel: fields[5] as String,
      bankName: bankName,
      accountNo: accountNo,
      accountHolder: accountHolder,
      bizType: bizType,
      bizItem: bizItem,
      managerName: managerName,
      itemPresets: itemPresets,
    );
  }

  @override
  void write(BinaryWriter writer, Company obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ceo)
      ..writeByte(3)
      ..write(obj.bizNo)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.tel)
      ..writeByte(6)
      ..write(obj.bankName)
      ..writeByte(7)
      ..write(obj.accountNo)
      ..writeByte(8)
      ..write(obj.accountHolder)
      ..writeByte(9)
      ..write(obj.bizType)
      ..writeByte(10)
      ..write(obj.bizItem)
      ..writeByte(11)
      ..write(obj.managerName)
      ..writeByte(12)
      ..write(obj.itemPresets.map((e) => e.toMap()).toList());
  }
}
