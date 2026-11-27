import 'dart:async';

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/holiday_plan_model.dart';
import '../models/trip_type_model.dart';
import '../services/holiday_plan_service.dart';
import '../services/trip_type_service.dart';
import 'collection_form_screen.dart';
import '../widgets/holiday_collection_illustration.dart';

typedef TripTypeLoader = Future<List<TripTypeModel>> Function();
typedef TripTypeCreator = Future<TripTypeModel> Function(String name);
typedef HolidayPlanLoader = Future<List<HolidayPlanModel>> Function({
  int? tripTypeId,
});

class CollectionScreen extends StatefulWidget {
  final TripTypeLoader? tripTypeLoader;
  final TripTypeCreator? tripTypeCreator;
  final HolidayPlanLoader? holidayPlanLoader;

  const CollectionScreen({
    super.key,
    this.tripTypeLoader,
    this.tripTypeCreator,
    this.holidayPlanLoader,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  int _categoryRevision = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  void _onCategoriesChanged() {
    setState(() => _categoryRevision++);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CollectionColors.background,
      appBar: AppBar(
        backgroundColor: _CollectionColors.background,
        foregroundColor: _CollectionColors.ink,
        title: const Row(
          children: [
            Icon(
              Icons.luggage_rounded,
              color: _CollectionColors.green,
              size: 25,
            ),
            SizedBox(width: 10),
            Text('Koleksi'),
          ],
        ),
        bottom: TabBar(
          controller: _tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: _CollectionColors.mint,
            borderRadius: BorderRadius.circular(22),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: _CollectionColors.green,
          unselectedLabelColor: _CollectionColors.muted,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Rencana Libur'),
            Tab(text: 'Jenis Liburan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _HolidayPlanTab(
            tripTypeLoader: widget.tripTypeLoader,
            planLoader: widget.holidayPlanLoader,
            categoryRevision: _categoryRevision,
          ),
          _TripTypeTab(
            loader: widget.tripTypeLoader,
            creator: widget.tripTypeCreator,
            onChanged: _onCategoriesChanged,
          ),
        ],
      ),
    );
  }
}

class _TripTypeTab extends StatefulWidget {
  final TripTypeLoader? loader;
  final TripTypeCreator? creator;
  final VoidCallback? onChanged;

  const _TripTypeTab({this.loader, this.creator, this.onChanged});

  @override
  State<_TripTypeTab> createState() => _TripTypeTabState();
}

class _TripTypeTabState extends State<_TripTypeTab> {
  late Future<List<TripTypeModel>> _future;
  List<TripTypeModel> _categories = [];

  Future<List<TripTypeModel>> _loadCategories() =>
      widget.loader?.call() ?? TripTypeService.getAll();

  @override
  void initState() {
    super.initState();
    _future = _loadCategories();
  }

  void _load() {
    setState(() {
      _future = _loadCategories();
    });
  }

  Future<void> _openForm({TripTypeModel? data}) async {
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (_) => CollectionFormScreen.category(
          category: data,
          tripTypeCreator: widget.creator,
        ),
      ),
    );
    if (!mounted) return;
    if (result is TripTypeModel) {
      final optimistic = data == null
          ? [
              ..._categories,
              result.id == 0
                  ? TripTypeModel(
                      id: DateTime.now().microsecondsSinceEpoch,
                      name: result.name,
                    )
                  : result,
            ]
          : _categories
                .map((category) => category.id == data.id ? result : category)
                .toList();
      _categories = optimistic;
      setState(() {
        _future = Future.value(optimistic);
      });
    } else if (result == true) {
      setState(() {
        _future = _loadCategories();
      });
    }
    widget.onChanged?.call();
    unawaited(_syncCategories());
  }

  Future<void> _syncCategories() async {
    try {
      final categories = await _loadCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _future = Future.value(categories);
      });
    } catch (error) {
      if (!mounted) return;
      _showError('Gagal memuat kategori terbaru', error);
    }
  }

  Future<void> _delete(TripTypeModel data) async {
    try {
      await TripTypeService.delete(data.id);
      if (!mounted) return;
      _categories = _categories
          .where((category) => category.id != data.id)
          .toList();
      setState(() {
        _future = Future.value(_categories);
      });
      widget.onChanged?.call();
    } catch (error) {
      if (!mounted) return;
      _showError('Gagal menghapus kategori', error);
    }
  }

  void _showError(String title, Object error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$title: $error')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CollectionColors.background,
      body: FutureBuilder<List<TripTypeModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _CollectionColors.green),
            );
          }
          if (snapshot.hasError) {
            return _CollectionErrorState(
              title: 'Gagal memuat kategori',
              message: snapshot.error.toString(),
              onRetry: _load,
            );
          }

          final categories = snapshot.data ?? [];
          _categories = List<TripTypeModel>.of(categories);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              _CollectionHeading(
                title: 'Jenis Liburan',
                subtitle: 'Kelola kategori untuk mengelompokkan rencana.',
                onAdd: () => _openForm(),
                addTooltip: 'Tambah kategori',
              ),
              const SizedBox(height: 18),
              if (categories.isEmpty)
                _CollectionEmptyState(
                  title: 'Belum ada kategori liburan',
                  message: 'Buat kategori seperti Mudik atau Staycation untuk mengelompokkan rencana libur.',
                  actionLabel: 'Tambah Kategori',
                  onAction: () => _openForm(),
                )
              else
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _CategoryCard(
                      category: category,
                      onEdit: () => _openForm(data: category),
                      onDelete: () => _delete(category),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HolidayPlanTab extends StatefulWidget {
  final TripTypeLoader? tripTypeLoader;
  final HolidayPlanLoader? planLoader;
  final int categoryRevision;

  const _HolidayPlanTab({
    this.tripTypeLoader,
    this.planLoader,
    required this.categoryRevision,
  });

  @override
  State<_HolidayPlanTab> createState() => _HolidayPlanTabState();
}

class _HolidayPlanTabState extends State<_HolidayPlanTab> {
  late Future<List<HolidayPlanModel>> _future;
  List<TripTypeModel> _tripTypes = [];
  Object? _tripTypesError;
  int? _filterTripTypeId;

  Future<List<TripTypeModel>> _loadCategories() =>
      widget.tripTypeLoader?.call() ?? TripTypeService.getAll();

  Future<List<HolidayPlanModel>> _loadPlans() =>
      widget.planLoader?.call() ?? HolidayPlanService.getAll();

  @override
  void initState() {
    super.initState();
    _future = _loadPlans();
    _reloadCategories();
  }

  @override
  void didUpdateWidget(covariant _HolidayPlanTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryRevision != widget.categoryRevision) {
      _reloadCategories();
    }
  }

  Future<void> _reloadCategories() async {
    try {
      final categories = await _loadCategories();
      if (!mounted) return;
      setState(() {
        _tripTypes = categories;
        _tripTypesError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _tripTypesError = error);
    }
  }

  Future<void> _reload() async {
    setState(() => _future = _loadPlans());
    await _reloadCategories();
  }

  Future<void> _openForm({HolidayPlanModel? data}) async {
    if (_tripTypesError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategori belum tersedia: $_tripTypesError')),
      );
      return;
    }
    if (_tripTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buat kategori dulu di tab Jenis Liburan'),
        ),
      );
      return;
    }

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CollectionFormScreen.plan(
          plan: data,
          tripTypeLoader: widget.tripTypeLoader,
        ),
      ),
    );
    if (saved == true && mounted) await _reload();
  }

  Future<void> _delete(HolidayPlanModel data) async {
    try {
      await HolidayPlanService.delete(data.id);
      if (!mounted) return;
      await _reload();
    } catch (error) {
      if (!mounted) return;
      _showError('Gagal menghapus rencana', error);
    }
  }

  void _showError(String title, Object error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$title: $error')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CollectionColors.background,
      body: FutureBuilder<List<HolidayPlanModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _CollectionColors.green),
            );
          }
          if (snapshot.hasError) {
            return _CollectionErrorState(
              title: 'Gagal memuat rencana libur',
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final allPlans = snapshot.data ?? [];
          final plans = _filterTripTypeId == null
              ? allPlans
              : allPlans
                    .where((plan) => plan.tripTypeId == _filterTripTypeId)
                    .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            children: [
              _CollectionHeading(
                title: 'Koleksi Liburanku 🎒',
                subtitle:
                    'Rencana liburan tersimpan dan ide destinasi favoritmu',
                onAdd: () => _openForm(),
                addTooltip: 'Tambah rencana',
              ),
              const SizedBox(height: 18),
              _buildCategoryFilters(allPlans),
              if (_tripTypesError != null) ...[
                const SizedBox(height: 12),
                _CategoryLoadError(
                  error: _tripTypesError!,
                  onRetry: _reloadCategories,
                ),
              ],
              const SizedBox(height: 18),
              if (plans.isEmpty)
                _CollectionEmptyState(
                  title: _filterTripTypeId == null
                      ? 'Koper siap, rencananya kapan?'
                      : 'Belum ada rencana di kategori ini',
                  message: _filterTripTypeId == null
                      ? 'Simpan tanggal merah favorit dan susun rencana libur seru bersama keluarga.'
                      : 'Pilih kategori lain atau tambahkan rencana liburan baru.',
                  actionLabel: _filterTripTypeId == null
                      ? 'Tambah Rencana'
                      : 'Buat Rencana',
                  onAction: () => _openForm(),
                )
              else ...[
                for (final plan in plans)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: _HolidayPlanCard(
                      plan: plan,
                      categoryName: _categoryName(plan),
                      onEdit: () => _openForm(data: plan),
                      onDelete: () => _delete(plan),
                    ),
                  ),
                const SizedBox(height: 10),
                _InspirationCard(onAdd: () => _openForm()),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters(List<HolidayPlanModel> plans) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('Semua (${plans.length})'),
              selected: _filterTripTypeId == null,
              onSelected: (_) => setState(() => _filterTripTypeId = null),
              selectedColor: _CollectionColors.mint,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: _filterTripTypeId == null
                    ? _CollectionColors.green
                    : _CollectionColors.muted,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide.none,
            ),
          ),
          for (final category in _tripTypes)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  '${category.name} (${plans.where((plan) => plan.tripTypeId == category.id).length})',
                ),
                selected: _filterTripTypeId == category.id,
                onSelected: (_) =>
                    setState(() => _filterTripTypeId = category.id),
                selectedColor: _CollectionColors.mint,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: _filterTripTypeId == category.id
                      ? _CollectionColors.green
                      : _CollectionColors.muted,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide.none,
              ),
            ),
        ],
      ),
    );
  }

  String _categoryName(HolidayPlanModel plan) {
    if (plan.tripTypeName != null && plan.tripTypeName!.isNotEmpty) {
      return plan.tripTypeName!;
    }
    for (final type in _tripTypes) {
      if (type.id == plan.tripTypeId) return type.name;
    }
    return 'Tanpa kategori';
  }
}

class _CollectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  final String addTooltip;

  const _CollectionHeading({
    required this.title,
    required this.subtitle,
    required this.onAdd,
    required this.addTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _CollectionColors.ink,
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _CollectionColors.muted,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: _CollectionColors.mint,
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: addTooltip,
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 27),
            color: _CollectionColors.green,
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final TripTypeModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _CollectionColors.green.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: _CollectionColors.mintLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.label_rounded,
              color: _CollectionColors.green,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                color: _CollectionColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Edit kategori',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: _CollectionColors.green,
          ),
          IconButton(
            tooltip: 'Hapus kategori',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: _CollectionColors.coral,
          ),
        ],
      ),
    );
  }
}

class _HolidayPlanCard extends StatelessWidget {
  final HolidayPlanModel plan;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HolidayPlanCard({
    required this.plan,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(plan.holidayDate ?? '');
    final day = date?.day.toString().padLeft(2, '0');
    final month = date == null ? null : _shortMonths[date.month - 1];
    final dateLabel = date == null ? plan.holidayDate : _formatPlanDate(date);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _CollectionColors.green.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 15, 13, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 7,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _PlanPill(
                        icon: Icons.luggage_rounded,
                        label: categoryName,
                        background: _CollectionColors.mint,
                        foreground: _CollectionColors.green,
                      ),
                      if (dateLabel?.isNotEmpty ?? false)
                        _PlanPill(
                          icon: Icons.event_rounded,
                          label: dateLabel!,
                          background: _CollectionColors.surfaceTint,
                          foreground: _CollectionColors.muted,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (date != null) ...[
                        Container(
                          width: 53,
                          height: 57,
                          decoration: BoxDecoration(
                            color: _CollectionColors.mintLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day!,
                                style: const TextStyle(
                                  color: _CollectionColors.ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                month!,
                                style: const TextStyle(
                                  color: _CollectionColors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          plan.title,
                          style: const TextStyle(
                            color: _CollectionColors.ink,
                            fontSize: 19,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.bookmark_border_rounded,
                        color: _CollectionColors.olive,
                        size: 24,
                      ),
                    ],
                  ),
                  if (plan.notes != null && plan.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 11),
                    Text(
                      plan.notes!.trim(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _CollectionColors.muted,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: _CollectionColors.divider),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.event_note_rounded,
                        color: _CollectionColors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dateLabel?.isNotEmpty == true
                              ? dateLabel!
                              : 'Tanggal belum ditentukan',
                          style: const TextStyle(
                            color: _CollectionColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: _CollectionColors.green,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Hapus rencana',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: _CollectionColors.coral,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 7, color: _CollectionColors.mint),
            ),
          ],
        ),
      ),
    );
  }

  static const _shortMonths = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGU',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];

  static String _formatPlanDate(DateTime date) =>
      '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
}

class _PlanPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _PlanPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InspirationCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _InspirationCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 19, 18, 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_CollectionColors.mintLight, _CollectionColors.mint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const HolidayCollectionIllustration(size: 118),
          const SizedBox(height: 8),
          const Text(
            'Inspirasi Rencana Baru',
            style: TextStyle(
              color: _CollectionColors.ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Susun agenda libur berikutnya dan simpan semua persiapannya di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _CollectionColors.muted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Rencana'),
              style: FilledButton.styleFrom(
                backgroundColor: _CollectionColors.cream,
                foregroundColor: _CollectionColors.olive,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _CollectionEmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_CollectionColors.mintLight, _CollectionColors.mint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const HolidayCollectionIllustration(),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _CollectionColors.ink,
              fontSize: 21,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _CollectionColors.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: _CollectionColors.cream,
                foregroundColor: _CollectionColors.olive,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryLoadError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _CategoryLoadError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAE4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: _CollectionColors.coral,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Kategori gagal dimuat: $error',
              style: const TextStyle(
                color: _CollectionColors.ink,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Coba muat kategori lagi',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            color: _CollectionColors.green,
          ),
        ],
      ),
    );
  }
}

class _CollectionErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _CollectionErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: _CollectionColors.coral,
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _CollectionColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _CollectionColors.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class _CollectionColors {
  static const background = Color(0xFFE6FFF4);
  static const surfaceTint = Color(0xFFFFEAE4);
  static const mint = Color(0xFFBCEDE0);
  static const mintLight = Color(0xFFCEFEED);
  static const green = Color(0xFF3A665C);
  static const ink = Color(0xFF002018);
  static const muted = Color(0xFF4A625B);
  static const cream = Color(0xFFFFEEB3);
  static const olive = Color(0xFF6A5E30);
  static const coral = Color(0xFF944930);
  static const divider = Color(0xFFE8F3ED);
}
