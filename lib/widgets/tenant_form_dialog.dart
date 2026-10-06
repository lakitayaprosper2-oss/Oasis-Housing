import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tenant.dart';

class TenantFormDialog extends StatefulWidget {
  final Tenant? existing;
  const TenantFormDialog({super.key, this.existing});

  @override
  State<TenantFormDialog> createState() => _TenantFormDialogState();
}

class _TenantFormDialogState extends State<TenantFormDialog> {
  final _nameCtrl = TextEditingController();
  final _tribeCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _intervalCtrl = TextEditingController(text: '1');
  final List<TextEditingController> _phoneCtrls = [];
  String _gender = '';
  DateTime _startDate = DateTime.now();
  String? _docPath;
  String? _docName;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    if (t != null) {
      _nameCtrl.text = t.name;
      _tribeCtrl.text = t.tribe;
      _ageCtrl.text = t.age?.toString() ?? '';
      _rentCtrl.text = t.rent == t.rent.roundToDouble() ? t.rent.toInt().toString() : t.rent.toString();
      _intervalCtrl.text = t.intervalMonths.toString();
      _gender = t.gender;
      _startDate = DateTime.tryParse(t.startDate) ?? DateTime.now();
      _docPath = t.docPath;
      _docName = t.docName;
      for (final p in t.phones) {
        _phoneCtrls.add(TextEditingController(text: p));
      }
    }
    if (_phoneCtrls.isEmpty) _phoneCtrls.add(TextEditingController());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tribeCtrl.dispose();
    _ageCtrl.dispose();
    _rentCtrl.dispose();
    _intervalCtrl.dispose();
    for (final c in _phoneCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickDoc() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _docPath = result.files.single.path;
        _docName = result.files.single.name;
      });
    }
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final phones = _phoneCtrls.map((c) => c.text.trim()).where((p) => p.isNotEmpty).toList();
    final rent = double.tryParse(_rentCtrl.text.trim()) ?? 0;
    final interval = int.tryParse(_intervalCtrl.text.trim()) ?? 1;

    if (name.isEmpty || phones.isEmpty || rent <= 0 || interval <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in name, phone, rent and interval.')),
      );
      return;
    }

    final tenant = Tenant(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      phones: phones,
      tribe: _tribeCtrl.text.trim(),
      gender: _gender,
      age: int.tryParse(_ageCtrl.text.trim()),
      rent: rent,
      intervalMonths: interval,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate),
      docPath: _docPath,
      docName: _docName,
      lastPaidDueDate: widget.existing?.lastPaidDueDate,
      amountPaidThisCycle: widget.existing?.amountPaidThisCycle ?? 0,
      payments: widget.existing?.payments,
    );
    Navigator.pop(context, tenant);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add tenant' : 'Edit tenant'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Phone number(s)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              ..._phoneCtrls.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: c,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(hintText: 'e.g. 0712 345 678'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _phoneCtrls.length > 1 ? () => setState(() => _phoneCtrls.removeAt(i)) : null,
                      ),
                    ],
                  ),
                );
              }),
              TextButton(
                onPressed: () => setState(() => _phoneCtrls.add(TextEditingController())),
                child: const Text('+ Add another phone'),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: _tribeCtrl, decoration: const InputDecoration(labelText: 'Tribe'))),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender.isEmpty ? null : _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? ''),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _rentCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rent amount'),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDoc,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(children: [
                    const Icon(Icons.upload_file, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _docName ?? 'Upload rent contract (document or image)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Pay every'),
                const SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: _intervalCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('month(s)'),
              ]),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date rent started'),
                  child: Text(DateFormat('dd MMM yyyy').format(_startDate)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save tenant')),
      ],
    );
  }
}

Future<Tenant?> showTenantFormDialog(BuildContext context, {Tenant? existing}) {
  return showDialog<Tenant>(context: context, builder: (_) => TenantFormDialog(existing: existing));
}
