// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/holiday_plan_model.dart';
import '../models/trip_type_model.dart';
import '../services/holiday_plan_service.dart';
import '../services/trip_type_service.dart';

typedef CollectionTripTypeLoader = Future<List<TripTypeModel>> Function();
typedef CollectionTripTypeCreator = Future<TripTypeModel> Function(String name);

class CollectionFormScreen extends StatefulWidget {
  final bool isPlan;
  final HolidayPlanModel? plan;
  final TripTypeModel? category;
  final CollectionTripTypeLoader? tripTypeLoader;
  final CollectionTripTypeCreator? tripTypeCreator;

  const CollectionFormScreen.plan({super.key, this.plan, this.tripTypeLoader})
    : isPlan = true,
      category = null,
      tripTypeCreator = null;

  const CollectionFormScreen.category({
    super.key,
    this.category,
    this.tripTypeCreator,
  }) : isPlan = false,
       plan = null,
       tripTypeLoader = null;

  @override
  State<CollectionFormScreen> createState() => _CollectionFormScreenState();
}

class _CollectionFormScreenState extends State<CollectionFormScreen> {
  static const _background = Color(0xFFE6FFF4);
  static const _mint = Color(0xFFBCEDE0);
  static const _mintLight = Color(0xFFCEFEED);
  static const _green = Color(0xFF3A665C);
  static const _ink = Color(0xFF002018);
  static const _muted = Color(0xFF4A625B);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dateController;
  late final TextEditingController _notesController;

  List<TripTypeModel> _categories = [];
  int? _selectedCategoryId;
  Object? _categoryError;
  bool _categoryLoading = false;
  bool _saving = false;
  Object? _saveError;

  bool get _isEditing =>
      widget.isPlan ? widget.plan != null : widget.category != null;

  Future<List<TripTypeModel>> _loadTripTypes() =>
      widget.tripTypeLoader?.call() ?? TripTypeService.getAll();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.isPlan
          ? widget.plan?.title ?? ''
          : widget.category?.name ?? '',
    );
    _dateController = TextEditingController(
      text: widget.plan?.holidayDate ?? '',
    );
    _notesController = TextEditingController(text: widget.plan?.notes ?? '');
    if (widget.isPlan) _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoryLoading = true;
      _categoryError = null;
    });
    try {
      final categories = await _loadTripTypes();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        if (!_categories.any((item) => item.id == _selectedCategoryId)) {
          _selectedCategoryId = widget.plan?.tripTypeId;
        }
        if (!_categories.any((item) => item.id == _selectedCategoryId)) {
          _selectedCategoryId = _categories.isEmpty
              ? null
              : _categories.first.id;
        }
        _categoryLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _categoryError = error;
        _categoryLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final existing = DateTime.tryParse(_dateController.text);
    final today = DateUtils.dateOnly(DateTime.now());
    final chosen = await showDatePicker(
      context: context,
      initialDate: existing ?? today,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      helpText: 'Pilih tanggal libur',
    );
    if (chosen == null || !mounted) return;
    _dateController.text =
        '${chosen.year.toString().padLeft(4, '0')}-'
        '${chosen.month.toString().padLeft(2, '0')}-'
        '${chosen.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.isPlan &&
        (_categoryLoading ||
            _categoryError != null ||
            _categories.isEmpty ||
            _selectedCategoryId == null)) {
      return;
    }

    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      TripTypeModel? categoryResult;
      if (widget.isPlan) {
        final categoryId = _selectedCategoryId!;
        if (widget.plan == null) {
          await HolidayPlanService.create(
            tripTypeId: categoryId,
            title: _nameController.text.trim(),
            notes: _notesController.text.trim(),
            holidayDate: _dateController.text.trim(),
          );
        } else {
          await HolidayPlanService.update(
            widget.plan!.id,
            tripTypeId: categoryId,
            title: _nameController.text.trim(),
            notes: _notesController.text.trim(),
            holidayDate: _dateController.text.trim(),
          );
        }
      } else if (widget.category == null) {
        categoryResult =
            await (widget.tripTypeCreator ?? TripTypeService.create)(
              _nameController.text.trim(),
            );
      } else {
        categoryResult = await TripTypeService.update(
          widget.category!.id,
          _nameController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(categoryResult ?? true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saveError = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isPlan
        ? '${_isEditing ? 'Edit' : 'Tambah'} Rencana'
        : '${_isEditing ? 'Edit' : 'Tambah'} Kategori';

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _ink,
        title: Text(title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _buildIntro(
                    widget.isPlan
                        ? 'Susun Rencana Liburan'
                        : 'Atur Kategori Liburan',
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isPlan) ...[
                          _buildCategoryField(),
                          const SizedBox(height: 15),
                        ],
                        TextFormField(
                          key: const ValueKey('collection-form-name'),
                          controller: _nameController,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: widget.isPlan
                              ? TextInputAction.next
                              : TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: widget.isPlan
                                ? 'Nama Rencana'
                                : 'Nama Kategori',
                            hintText: widget.isPlan
                                ? 'Contoh: Mudik Lebaran'
                                : 'Contoh: Mudik, Staycation',
                            prefixIcon: Icon(
                              widget.isPlan
                                  ? Icons.luggage_rounded
                                  : Icons.label_rounded,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isPlan
                                  ? 'Nama rencana harus diisi'
                                  : 'Nama kategori harus diisi';
                            }
                            return null;
                          },
                        ),
                        if (widget.isPlan) ...[
                          const SizedBox(height: 15),
                          TextFormField(
                            key: const ValueKey('collection-form-date'),
                            controller: _dateController,
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Libur (opsional)',
                              hintText: 'Pilih tanggal',
                              prefixIcon: Icon(Icons.calendar_month_rounded),
                              suffixIcon: Icon(Icons.edit_calendar_rounded),
                            ),
                            validator: (value) {
                              final dateText = value?.trim() ?? '';
                              if (dateText.isEmpty) return null;
                              final hasIsoFormat = RegExp(
                                r'^\d{4}-\d{2}-\d{2}$',
                              ).hasMatch(dateText);
                              if (!hasIsoFormat ||
                                  DateTime.tryParse(dateText) == null) {
                                return 'Pilih tanggal yang valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _notesController,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 4,
                            minLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Catatan (opsional)',
                              hintText: 'Tujuan atau persiapan singkat',
                              alignLabelWithHint: true,
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 42),
                                child: Icon(Icons.notes_rounded),
                              ),
                            ),
                          ),
                        ],
                        if (_saveError != null) ...[
                          const SizedBox(height: 14),
                          _ErrorMessage(error: _saveError!),
                        ],
                      ],
                    ),
                  ),
                  if (widget.isPlan && _categories.isEmpty && !_categoryLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _categoryError == null
                          ? _EmptyCategories(onRetry: _loadCategories)
                          : _ErrorMessage(
                              error: _categoryError!,
                              onRetry: _loadCategories,
                            ),
                    ),
                ],
              ),
            ),
          ),
          _buildSubmitButton(title),
        ],
      ),
    );
  }

  Widget _buildIntro(String title) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_mintLight, _mint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              widget.isPlan ? Icons.luggage_rounded : Icons.category_rounded,
              color: _green,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isPlan
                      ? 'Simpan jadwal dan catatan rencana liburanmu.'
                      : 'Kelompokkan rencana liburan agar mudah ditemukan.',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    if (_categoryLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Center(child: CircularProgressIndicator(color: _green)),
      );
    }
    if (_categoryError != null) {
      return _ErrorMessage(error: _categoryError!, onRetry: _loadCategories);
    }
    if (_categories.isEmpty) {
      return const Text(
        'Buat kategori liburan terlebih dahulu sebelum menyimpan rencana.',
        style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
      );
    }

    return DropdownButtonFormField<int>(
      key: const ValueKey('collection-form-category'),
      initialValue: _selectedCategoryId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Kategori',
        prefixIcon: Icon(Icons.category_rounded),
      ),
      items: _categories
          .map(
            (category) => DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedCategoryId = value),
      validator: (value) =>
          value == null ? 'Pilih kategori untuk rencana ini' : null,
    );
  }

  Widget _buildSubmitButton(String title) {
    final disabled =
        _saving ||
        (widget.isPlan &&
            (_categoryLoading ||
                _categoryError != null ||
                _categories.isEmpty));

    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: _background.withValues(alpha: 0.97),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: disabled ? null : _submit,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _green,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(_saving ? 'Menyimpan...' : 'Simpan $title'),
          style: FilledButton.styleFrom(
            backgroundColor: _mint,
            foregroundColor: _ink,
            disabledBackgroundColor: _mint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const _ErrorMessage({required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAE4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFF944930)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Terjadi kesalahan: $error',
              style: const TextStyle(
                color: Color(0xFF002018),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              tooltip: 'Coba lagi',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              color: const Color(0xFF3A665C),
            ),
        ],
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyCategories({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF3A665C)),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'Belum ada kategori. Tambahkan Jenis Liburan terlebih dahulu.',
              style: TextStyle(
                color: Color(0xFF4A625B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang kategori',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF3A665C),
          ),
        ],
      ),
    );
  }
}
