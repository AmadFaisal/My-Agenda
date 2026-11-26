import 'package:flutter/material.dart';

import '../models/holiday_plan_model.dart';
import '../models/trip_type_model.dart';
import '../services/holiday_plan_service.dart';
import '../services/trip_type_service.dart';
import '../theme/app_theme.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});
  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksi Saya'),
        bottom: TabBar(
          controller: _tab,
          dividerColor: AppTheme.border,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 2.5,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.inkMuted,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Jenis Liburan'),
            Tab(text: 'Rencana Libur'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [_TripTypeTab(), _HolidayPlanTab()],
      ),
    );
  }
}

// ==================== TAB 1: CRUD TRIP TYPES ====================
class _TripTypeTab extends StatefulWidget {
  const _TripTypeTab();
  @override
  State<_TripTypeTab> createState() => _TripTypeTabState();
}

class _TripTypeTabState extends State<_TripTypeTab> {
  late Future<List<TripTypeModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = TripTypeService.getAll();
    });
  }

  Future<void> _openForm({TripTypeModel? data}) async {
    final ctrl = TextEditingController(text: data?.name ?? '');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(data == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppTheme.ink),
          decoration: const InputDecoration(
            labelText: 'Nama Kategori',
            hintText: 'Contoh: Mudik, Cuti Panjang',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              try {
                if (data == null) {
                  await TripTypeService.create(name);
                } else {
                  await TripTypeService.update(data.id, name);
                }
                _load();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(TripTypeModel data) async {
    try {
      await TripTypeService.delete(data.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_trip_type',
        onPressed: () => _openForm(),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Kategori',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<List<TripTypeModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }
          if (snap.hasError) {
            return UtilitarianStateView(
              icon: Icons.error_outline,
              title: 'Gagal memuat kategori',
              message: snap.error.toString().replaceAll('Exception: ', ''),
              actionLabel: 'Coba Lagi',
              onAction: _load,
              isError: true,
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return UtilitarianStateView(
              icon: Icons.folder_open_outlined,
              title: 'Belum ada kategori liburan',
              message:
                  'Buat kategori seperti Mudik atau Staycation untuk mengelompokkan rencana libur Anda.',
              actionLabel: 'Tambah Kategori',
              onAction: () => _openForm(),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.border, width: 1),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = items[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: const Icon(
                        Icons.label_outline,
                        color: AppTheme.accent,
                        size: 20,
                      ),
                      title: Text(
                        t.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.ink,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit kategori',
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppTheme.inkMuted,
                              size: 20,
                            ),
                            onPressed: () => _openForm(data: t),
                          ),
                          IconButton(
                            tooltip: 'Hapus kategori',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.danger,
                              size: 20,
                            ),
                            onPressed: () => _delete(t),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================== TAB 2: CRUD HOLIDAY PLANS ====================
class _HolidayPlanTab extends StatefulWidget {
  const _HolidayPlanTab();
  @override
  State<_HolidayPlanTab> createState() => _HolidayPlanTabState();
}

class _HolidayPlanTabState extends State<_HolidayPlanTab> {
  late Future<List<HolidayPlanModel>> _future;
  List<TripTypeModel> _tripTypes = [];
  int? _filterTripTypeId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _future = HolidayPlanService.getAll(tripTypeId: _filterTripTypeId);
    });
    try {
      _tripTypes = await TripTypeService.getAll();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _openForm({HolidayPlanModel? data}) async {
    if (_tripTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buat kategori dulu di tab Jenis Liburan'),
        ),
      );
      return;
    }

    final titleCtrl = TextEditingController(text: data?.title ?? '');
    final notesCtrl = TextEditingController(text: data?.notes ?? '');
    final dateCtrl = TextEditingController(text: data?.holidayDate ?? '');
    int? selectedType = data?.tripTypeId ?? _tripTypes.first.id;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(data == null ? 'Tambah Rencana' : 'Edit Rencana'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedType,
                  isExpanded: true,
                  items: _tripTypes
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(
                            t.name,
                            style: const TextStyle(color: AppTheme.ink),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialog(() => selectedType = v),
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: AppTheme.ink),
                  decoration: const InputDecoration(
                    labelText: 'Nama Rencana',
                    hintText: 'Contoh: Libur Lebaran',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateCtrl,
                  style: const TextStyle(color: AppTheme.ink),
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    hintText: 'YYYY-MM-DD (Contoh: 2026-03-20)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: AppTheme.ink),
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    hintText: 'Tujuan atau persiapan singkat',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty || selectedType == null) {
                  return;
                }
                Navigator.pop(ctx);
                try {
                  if (data == null) {
                    await HolidayPlanService.create(
                      tripTypeId: selectedType!,
                      title: titleCtrl.text.trim(),
                      notes: notesCtrl.text.trim(),
                      holidayDate: dateCtrl.text.trim(),
                    );
                  } else {
                    await HolidayPlanService.update(
                      data.id,
                      tripTypeId: selectedType!,
                      title: titleCtrl.text.trim(),
                      notes: notesCtrl.text.trim(),
                      holidayDate: dateCtrl.text.trim(),
                    );
                  }
                  _reload();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$e')));
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(HolidayPlanModel data) async {
    try {
      await HolidayPlanService.delete(data.id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_holiday_plan',
        onPressed: () => _openForm(),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Rencana',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.borderStrong, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _filterTripTypeId,
                  isExpanded: true,
                  dropdownColor: AppTheme.surface,
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppTheme.inkMuted,
                    size: 20,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'Semua Kategori',
                        style: TextStyle(color: AppTheme.ink, fontSize: 14),
                      ),
                    ),
                    ..._tripTypes.map(
                      (t) => DropdownMenuItem<int?>(
                        value: t.id,
                        child: Text(
                          t.name,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _filterTripTypeId = v);
                    _reload();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<HolidayPlanModel>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  );
                }
                if (snap.hasError) {
                  return UtilitarianStateView(
                    icon: Icons.error_outline,
                    title: 'Gagal memuat rencana libur',
                    message:
                        snap.error.toString().replaceAll('Exception: ', ''),
                    actionLabel: 'Coba Lagi',
                    onAction: _reload,
                    isError: true,
                  );
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return UtilitarianStateView(
                    icon: Icons.event_note_outlined,
                    title: _filterTripTypeId == null
                        ? 'Belum ada rencana libur'
                        : 'Tidak ada rencana di kategori ini',
                    message: _filterTripTypeId == null
                        ? 'Tambahkan rencana libur secara manual atau simpan dari tab Jadwal.'
                        : 'Ubah filter kategori atau buat rencana baru untuk kategori ini.',
                    actionLabel: 'Tambah Rencana',
                    onAction: () => _openForm(),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.border, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TimetableDateBadge(isoDate: p.holidayDate ?? ''),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppTheme.ink,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Edit rencana',
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: AppTheme.inkMuted,
                                        size: 19,
                                      ),
                                      onPressed: () => _openForm(data: p),
                                    ),
                                    IconButton(
                                      tooltip: 'Hapus rencana',
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.danger,
                                        size: 19,
                                      ),
                                      onPressed: () => _delete(p),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentSoft,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        p.tripTypeName ?? 'Tanpa kategori',
                                        style: const TextStyle(
                                          color: AppTheme.accent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (p.holidayDate != null &&
                                        p.holidayDate!.isNotEmpty)
                                      Text(
                                        p.holidayDate!,
                                        style: const TextStyle(
                                          color: AppTheme.inkSubtle,
                                          fontSize: 12,
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                if (p.notes != null &&
                                    p.notes!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    p.notes!,
                                    style: const TextStyle(
                                      color: AppTheme.inkMuted,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
