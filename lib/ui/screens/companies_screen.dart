import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/company.dart';
import '../../state/providers/doc_provider.dart';

class CompaniesScreen extends StatelessWidget {
  final bool isMyCompany;
  const CompaniesScreen({super.key, required this.isMyCompany});

  String get boxName => isMyCompany ? 'companies_my' : 'companies_partner';
  String get title => isMyCompany ? '내업체 관리' : '상대 업체 관리';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showDialog<Company>(
            context: context,
            builder: (_) => _CompanyInfoDialog(isMyCompany: isMyCompany),
          );
          if (created == null) return;
          await Hive.box<Company>(boxName).put(created.id, created);
        },
        icon: const Icon(Icons.add),
        label: const Text('업체 등록'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Company>(boxName).listenable(),
        builder: (context, box, _) {
          final keys = box.keys.toList();
          if (keys.isEmpty) {
            return const Center(child: Text('등록된 업체가 없습니다.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: keys.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = box.get(keys[i])!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text('${c.ceo} · ${Formatters.phone(c.tel)}'),
                      if (isMyCompany) ...[
                        const SizedBox(height: 2),
                        Text('자주 쓰는 품목 ${c.itemPresets.length}개'),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              final edited = await showDialog<Company>(
                                context: context,
                                builder: (_) => _CompanyInfoDialog(
                                  isMyCompany: isMyCompany,
                                  initial: c,
                                ),
                              );
                              if (edited == null) return;
                              await box.put(edited.id, edited);
                              if (!context.mounted) return;
                              final doc = context.read<DocProvider>();
                              if (isMyCompany && doc.myCompany?.id == edited.id) {
                                doc.setMyCompany(edited);
                              } else if (!isMyCompany &&
                                  doc.partnerCompany?.id == edited.id) {
                                doc.setPartnerCompany(edited);
                              }
                            },
                            child: const Text('정보변경'),
                          ),
                          if (isMyCompany)
                            OutlinedButton(
                              onPressed: () async {
                                final editedPresets =
                                    await showDialog<List<ItemPreset>>(
                                      context: context,
                                      builder: (_) =>
                                          _PresetDialog(initial: c.itemPresets),
                                    );
                                if (editedPresets == null) return;
                                final updated = Company(
                                  id: c.id,
                                  name: c.name,
                                  ceo: c.ceo,
                                  bizNo: c.bizNo,
                                  address: c.address,
                                  tel: c.tel,
                                  bankName: c.bankName,
                                  accountNo: c.accountNo,
                                  accountHolder: c.accountHolder,
                                  bizType: c.bizType,
                                  bizItem: c.bizItem,
                                  managerName: c.managerName,
                                  itemPresets: editedPresets,
                                );
                                await box.put(updated.id, updated);
                                if (!context.mounted) return;
                                final doc = context.read<DocProvider>();
                                if (doc.myCompany?.id == updated.id) {
                                  doc.setMyCompany(updated);
                                }
                              },
                              child: const Text('품목추가'),
                            ),
                          TextButton(
                            onPressed: () {
                              final doc = context.read<DocProvider>();
                              if (isMyCompany) {
                                doc.setMyCompany(c);
                              } else {
                                doc.setPartnerCompany(c);
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('적용'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await box.delete(c.id);
                            },
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CompanyInfoDialog extends StatefulWidget {
  final bool isMyCompany;
  final Company? initial;

  const _CompanyInfoDialog({required this.isMyCompany, this.initial});

  @override
  State<_CompanyInfoDialog> createState() => _CompanyInfoDialogState();
}

class _CompanyInfoDialogState extends State<_CompanyInfoDialog> {
  late final TextEditingController name;
  late final TextEditingController ceo;
  late final TextEditingController bizNo;
  late final TextEditingController address;
  late final TextEditingController tel;
  late final TextEditingController bankName;
  late final TextEditingController accountNo;
  late final TextEditingController accountHolder;
  late final TextEditingController bizType;
  late final TextEditingController bizItem;
  late final TextEditingController managerName;

  bool get isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    name = TextEditingController(text: c?.name ?? '');
    ceo = TextEditingController(text: c?.ceo ?? '');
    bizNo = TextEditingController(text: c?.bizNo ?? '');
    address = TextEditingController(text: c?.address ?? '');
    tel = TextEditingController(text: c?.tel ?? '');
    bankName = TextEditingController(text: c?.bankName ?? '');
    accountNo = TextEditingController(text: c?.accountNo ?? '');
    accountHolder = TextEditingController(text: c?.accountHolder ?? '');
    bizType = TextEditingController(text: c?.bizType ?? '');
    bizItem = TextEditingController(text: c?.bizItem ?? '');
    managerName = TextEditingController(text: c?.managerName ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    ceo.dispose();
    bizNo.dispose();
    address.dispose();
    tel.dispose();
    bankName.dispose();
    accountNo.dispose();
    accountHolder.dispose();
    bizType.dispose();
    bizItem.dispose();
    managerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEdit ? '업체 정보 수정' : '업체 등록'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: '상호'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ceo,
                decoration: const InputDecoration(labelText: '대표자'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bizNo,
                decoration: const InputDecoration(labelText: '사업자번호'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: '사업장주소'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: tel,
                decoration: const InputDecoration(labelText: '전화번호'),
              ),
              if (widget.isMyCompany) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: bankName,
                  decoration: const InputDecoration(labelText: '은행'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: accountNo,
                  decoration: const InputDecoration(labelText: '계좌번호'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: accountHolder,
                  decoration: const InputDecoration(labelText: '예금주명'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bizType,
                  decoration: const InputDecoration(labelText: '업태'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bizItem,
                  decoration: const InputDecoration(labelText: '종목'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: managerName,
                  decoration: const InputDecoration(labelText: '담당자'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final id = widget.initial?.id ??
                DateTime.now().millisecondsSinceEpoch.toString();
            Navigator.pop(
              context,
              Company(
                id: id,
                name: name.text.trim(),
                ceo: ceo.text.trim(),
                bizNo: bizNo.text.trim(),
                address: address.text.trim(),
                tel: tel.text.trim(),
                bankName: widget.isMyCompany ? bankName.text.trim() : '',
                accountNo: widget.isMyCompany ? accountNo.text.trim() : '',
                accountHolder: widget.isMyCompany ? accountHolder.text.trim() : '',
                bizType: widget.isMyCompany ? bizType.text.trim() : '',
                bizItem: widget.isMyCompany ? bizItem.text.trim() : '',
                managerName: widget.isMyCompany ? managerName.text.trim() : '',
                itemPresets: widget.initial?.itemPresets ?? const [],
              ),
            );
          },
          child: Text(isEdit ? '수정' : '저장'),
        ),
      ],
    );
  }
}

class _PresetDialog extends StatefulWidget {
  final List<ItemPreset> initial;

  const _PresetDialog({required this.initial});

  @override
  State<_PresetDialog> createState() => _PresetDialogState();
}

class _PresetDialogState extends State<_PresetDialog> {
  final List<ItemPreset> presets = [];

  @override
  void initState() {
    super.initState();
    presets.addAll(
      widget.initial
          .map((e) => ItemPreset(id: e.id, name: e.name, unitPrice: e.unitPrice))
          .toList(),
    );
  }

  void addPreset() {
    setState(() {
      presets.add(
        ItemPreset(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          unitPrice: 0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('품목 추가'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '자주 쓰는 품목',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: addPreset,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('품목 추가'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (presets.isEmpty)
                const Text('등록된 품목이 없습니다.')
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: presets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = presets[index];
                    return _PresetEditorRow(
                      preset: p,
                      onRemove: () {
                        setState(() {
                          presets.removeAt(index);
                        });
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final cleaned = presets.where((e) => e.name.trim().isNotEmpty).toList();
            Navigator.pop(context, cleaned);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

class _PresetEditorRow extends StatefulWidget {
  final ItemPreset preset;
  final VoidCallback onRemove;

  const _PresetEditorRow({required this.preset, required this.onRemove});

  @override
  State<_PresetEditorRow> createState() => _PresetEditorRowState();
}

class _PresetEditorRowState extends State<_PresetEditorRow> {
  late final TextEditingController name;
  late final TextEditingController unitPrice;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.preset.name);
    unitPrice = TextEditingController(text: widget.preset.unitPrice.toString());
  }

  @override
  void dispose() {
    name.dispose();
    unitPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: name,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: '품명',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (v) => widget.preset.name = v,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: unitPrice,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: '단가',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => widget.preset.unitPrice = int.tryParse(v) ?? 0,
              ),
            ),
            IconButton(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
