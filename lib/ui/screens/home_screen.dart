import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../core/services/pdf_service.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/company.dart';
import '../../data/models/item.dart';
import '../../state/providers/doc_provider.dart';
import 'companies_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('문서 작성'),
          bottom: TabBar(
            indicatorWeight: 3,
            onTap: (i) {
              context.read<DocProvider>().setDocType(
                i == 0 ? DocType.quote : DocType.statement,
              );
            },
            tabs: const [
              Tab(text: '견적서'),
              Tab(text: '거래명세서'),
            ],
          ),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      const Color(0xFF1E88E5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    '업체 관리',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('내업체 관리'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompaniesScreen(isMyCompany: true),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake_outlined),
                title: const Text('상대 업체(거래처) 관리'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompaniesScreen(isMyCompany: false),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5F9FF), Color(0xFFEAF2FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              _DocForm(key: ValueKey('quote-form')),
              _DocForm(key: ValueKey('statement-form')),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocForm extends StatefulWidget {
  const _DocForm({super.key});

  @override
  State<_DocForm> createState() => _DocFormState();
}

class _DocFormState extends State<_DocForm> {
  String _selectedPresetId = '';

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<DocProvider>();
    final color = Theme.of(context).colorScheme;
    final presetCompany = doc.myCompany ?? doc.partnerCompany;
    final presets = presetCompany?.itemPresets ?? const <ItemPreset>[];

    if (_selectedPresetId.isNotEmpty &&
        !presets.any((e) => e.id == _selectedPresetId)) {
      _selectedPresetId = '';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const _Panel(child: _CompanyPickers()),
          const SizedBox(height: 12),
          const _Panel(child: _DateSelector()),
          const SizedBox(height: 12),
          if (doc.docType == DocType.quote) ...[
            _Panel(
              child: TextFormField(
                initialValue: doc.workDesc,
                decoration: const InputDecoration(labelText: '작업내용'),
                onChanged: (v) => context.read<DocProvider>().setWorkDesc(v),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _Panel(
            child: Column(
              children: [
                if (presets.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedPresetId,
                          decoration: const InputDecoration(
                            labelText: '자주 쓰는 품목 선택',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('직접 입력'),
                            ),
                            ...presets.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(
                                  '${p.name} (${Formatters.moneyWon(p.unitPrice)})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (id) {
                            setState(() {
                              _selectedPresetId = id ?? '';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          if (_selectedPresetId.isEmpty) {
                            context.read<DocProvider>().addItem();
                            return;
                          }
                          final preset = presets.firstWhere(
                            (e) => e.id == _selectedPresetId,
                          );
                          doc.items.add(
                            Item(
                              presetId: preset.id,
                              name: preset.name,
                              qty: 1,
                              unitPrice: preset.unitPrice,
                            ),
                          );
                          context.read<DocProvider>().touchPdf();
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: doc.items.length + (presets.isEmpty ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (presets.isEmpty && index == doc.items.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () =>
                              context.read<DocProvider>().addItem(),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('품목 추가'),
                        ),
                      );
                    }

                    final item = doc.items[index];
                    return DecoratedBox(
                      key: ObjectKey(item),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    key: ValueKey('name-${item.hashCode}'),
                                    initialValue: item.name,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: const InputDecoration(
                                      labelText: '품명',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                    ),
                                    onChanged: (v) {
                                      item.presetId = '';
                                      item.name = v;
                                      context.read<DocProvider>().touchPdf();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey('qty-${item.hashCode}'),
                                    initialValue: item.qty.toString(),
                                    style: const TextStyle(fontSize: 13),
                                    decoration: const InputDecoration(
                                      labelText: '수량',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      item.presetId = '';
                                      item.qty = int.tryParse(v) ?? 1;
                                      context.read<DocProvider>().touchPdf();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey('unit-${item.hashCode}'),
                                    initialValue: item.unitPrice.toString(),
                                    style: const TextStyle(fontSize: 13),
                                    decoration: const InputDecoration(
                                      labelText: '단가 (VAT포함)',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      item.presetId = '';
                                      item.unitPrice = int.tryParse(v) ?? 0;
                                      context.read<DocProvider>().touchPdf();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => context
                                      .read<DocProvider>()
                                      .removeItem(index),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            child: Column(
              children: [
                _sumRow('합계단가', Formatters.moneyWon(doc.totalUnitPrice)),
                _sumRow('합계공급가액', Formatters.moneyWon(doc.totalSupply)),
                _sumRow('합계세액', Formatters.moneyWon(doc.totalVat)),
                const Divider(),
                _sumRow(
                  '합계금액',
                  Formatters.moneyWon(doc.totalAmount),
                  isStrong: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                final docProvider = context.read<DocProvider>();
                final latestMy = docProvider.myCompany == null
                    ? null
                    : Hive.box<Company>('companies_my')
                        .get(docProvider.myCompany!.id);
                final latestPartner = docProvider.partnerCompany == null
                    ? null
                    : Hive.box<Company>('companies_partner')
                        .get(docProvider.partnerCompany!.id);

                if (latestMy != null) {
                  docProvider.setMyCompany(latestMy);
                }
                if (latestPartner != null) {
                  docProvider.setPartnerCompany(latestPartner);
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _PdfPreviewScreen()),
                );
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF 미리보기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sumRow(String label, String value, {bool isStrong = false}) {
    final style = TextStyle(
      fontWeight: isStrong ? FontWeight.w700 : FontWeight.w500,
      fontSize: isStrong ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _PdfPreviewScreen extends StatelessWidget {
  const _PdfPreviewScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF 미리보기'),
        actions: [
          IconButton(
            onPressed: () => context.read<DocProvider>().touchPdf(),
            icon: const Icon(Icons.refresh),
            tooltip: 'PDF 다시 그리기',
          ),
        ],
      ),
      body: Consumer<DocProvider>(
        builder: (context, doc, _) {
          final prefix = doc.docType == DocType.quote ? '견적서' : '거래명세서';
          final fileName = '${prefix}_${Formatters.date(doc.date)}.pdf';
          return PdfPreview(
            key: ValueKey(doc.pdfRevision),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: fileName,
            build: (_) => PdfService.buildPdf(doc: doc),
          );
        },
      ),
    );
  }
}

class _CompanyPickers extends StatelessWidget {
  const _CompanyPickers();

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<DocProvider>();
    final myBox = Hive.box<Company>('companies_my');
    final partnerBox = Hive.box<Company>('companies_partner');

    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: myBox.listenable(),
          builder: (context, box, _) {
            final companies = box.values.toList();
            return _pickerRow(
              context: context,
              label: '내업체',
              value: doc.myCompany?.id,
              companies: companies,
              emptyText: '등록된 내업체가 없습니다',
              onManage: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompaniesScreen(isMyCompany: true),
                  ),
                );
              },
              onChanged: (id) {
                if (id == null) return;
                final selected = companies.firstWhere((c) => c.id == id);
                context.read<DocProvider>().setMyCompany(selected);
              },
            );
          },
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder(
          valueListenable: partnerBox.listenable(),
          builder: (context, box, _) {
            final companies = box.values.toList();
            return _pickerRow(
              context: context,
              label: '상대업체',
              value: doc.partnerCompany?.id,
              companies: companies,
              emptyText: '등록된 거래처가 없습니다',
              onManage: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompaniesScreen(isMyCompany: false),
                  ),
                );
              },
              onChanged: (id) {
                if (id == null) return;
                final selected = companies.firstWhere((c) => c.id == id);
                context.read<DocProvider>().setPartnerCompany(selected);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _pickerRow({
    required BuildContext context,
    required String label,
    required String? value,
    required List<Company> companies,
    required String emptyText,
    required VoidCallback onManage,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: companies.isEmpty
              ? _EmptyDropdownHint(text: emptyText, onManage: onManage)
              : DropdownButtonFormField<String>(
                  initialValue: value,
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  hint: const Text('선택'),
                  items: companies
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector();

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<DocProvider>();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: doc.useToday
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: doc.date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('ko', 'KR'),
                    );
                    if (picked == null) return;
                    if (!context.mounted) return;
                    context.read<DocProvider>().setDate(picked);
                  },
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(Formatters.date(doc.date)),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              visualDensity: VisualDensity.compact,
              value: doc.useToday,
              onChanged: (v) =>
                  context.read<DocProvider>().setUseToday(v ?? false),
            ),
            const Text('오늘'),
            const SizedBox(width: 8),
            Checkbox(
              visualDensity: VisualDensity.compact,
              value: doc.showAccountInfo,
              onChanged: (v) =>
                  context.read<DocProvider>().setShowAccountInfo(v ?? false),
            ),
            const Text('계좌정보'),
          ],
        ),
      ],
    );
  }
}

class _EmptyDropdownHint extends StatelessWidget {
  final String text;
  final VoidCallback onManage;

  const _EmptyDropdownHint({required this.text, required this.onManage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(onPressed: onManage, child: const Text('등록')),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

