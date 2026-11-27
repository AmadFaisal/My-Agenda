// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/public_holiday_model.dart';
import '../services/holiday_plan_service.dart';
import '../services/trip_type_service.dart';

class ExploreDetailScreen extends StatefulWidget {
  final PublicHoliday holiday;

  const ExploreDetailScreen({super.key, required this.holiday});

  @override
  State<ExploreDetailScreen> createState() => _ExploreDetailScreenState();
}

class _ExploreDetailScreenState extends State<ExploreDetailScreen> {
  static const _background = Color(0xFFE6FFF4);
  static const _mint = Color(0xFFBCEDE0);
  static const _mintLight = Color(0xFFCEFEED);
  static const _green = Color(0xFF3A665C);
  static const _ink = Color(0xFF002018);
  static const _muted = Color(0xFF4A625B);
  static const _cream = Color(0xFFFFEEB3);
  static const _coral = Color(0xFF944930);

  bool _saving = false;

  static const _weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  DateTime? get _holidayDate => DateTime.tryParse(widget.holiday.date);

  String _formatDate(DateTime? date) {
    if (date == null) return widget.holiday.date;
    return '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  String _countdownLabel(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';
    final today = DateUtils.dateOnly(DateTime.now());
    final target = DateUtils.dateOnly(date);
    final days = target.difference(today).inDays;
    if (days == 0) return 'Hari ini';
    if (days > 0) return 'Tinggal $days hari';
    return 'Sudah berlalu ${days.abs()} hari';
  }

  @override
  Widget build(BuildContext context) {
    final date = _holidayDate;
    final weekday = date == null ? null : _weekdays[date.weekday - 1];
    final title = widget.holiday.localName.isNotEmpty
        ? widget.holiday.localName
        : widget.holiday.name;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _ink,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Row(
          children: [
            Icon(Icons.event_note_rounded, color: _green, size: 23),
            SizedBox(width: 9),
            Text('Detail Libur'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                _buildHero(date),
                const SizedBox(height: 16),
                _buildHolidayCard(title, date),
                const SizedBox(height: 16),
                _buildPlanningCard(weekday),
                const SizedBox(height: 16),
                _buildInformationCard(date),
              ],
            ),
          ),
          _buildSaveAction(),
        ],
      ),
    );
  }

  Widget _buildHero(DateTime? date) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cream, _mintLight, _mint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Badge(
                icon: Icons.verified_rounded,
                label: 'LIBUR NASIONAL',
                background: Colors.white.withValues(alpha: 0.9),
              ),
              const Spacer(),
              _Badge(
                icon: Icons.public_rounded,
                label: widget.holiday.countryCode.isEmpty
                    ? 'KALENDER'
                    : widget.holiday.countryCode.toUpperCase(),
                background: _green,
                foreground: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(height: 145, child: _buildHeroIllustration()),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: _green, size: 21),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Hitung mundur',
                    style: TextStyle(color: _ink, fontSize: 14),
                  ),
                ),
                Text(
                  _countdownLabel(date),
                  style: const TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 194,
          height: 118,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        Positioned(
          left: 83,
          top: 10,
          child: Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 86,
              height: 104,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _mint, width: 3),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded, color: _green, size: 40),
                  SizedBox(height: 5),
                  Text(
                    'LIBUR',
                    style: TextStyle(
                      color: _green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 105,
          bottom: 4,
          child: Container(
            width: 74,
            height: 58,
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.luggage_rounded,
              color: Colors.white,
              size: 39,
            ),
          ),
        ),
        const Positioned(
          top: 22,
          right: 88,
          child: Icon(Icons.auto_awesome, color: _coral, size: 22),
        ),
        const Positioned(
          bottom: 31,
          left: 96,
          child: Icon(Icons.star_rounded, color: _coral, size: 20),
        ),
      ],
    );
  }

  Widget _buildHolidayCard(String title, DateTime? date) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const _Badge(
                icon: Icons.circle,
                label: 'Libur Nasional',
                background: _mint,
                foreground: _green,
              ),
              if (widget.holiday.types.isNotEmpty)
                ...widget.holiday.types.map(
                  (type) => _Badge(
                    label: type,
                    background: const Color(0xFFFFEAE4),
                    foreground: _coral,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            title.isEmpty ? 'Hari Libur' : title,
            style: const TextStyle(
              color: _ink,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _mintLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(date),
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tanggal hari libur berdasarkan kalender publik.',
                        style: TextStyle(
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
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningCard(String? weekday) {
    final isWeekendAdjacent = weekday == 'Senin' || weekday == 'Jumat';
    final message = weekday == null
        ? 'Periksa kembali tanggal libur sebelum menyusun rencana perjalanan.'
        : isWeekendAdjacent
        ? 'Libur jatuh pada $weekday dan berpotensi tersambung dengan akhir pekan. Pastikan jadwal kerja sebelum mengatur perjalanan.'
        : 'Libur jatuh pada $weekday. Periksa akhir pekan dan jadwal kerja di sekitar tanggal ini sebelum mengatur cuti.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: _green, size: 23),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Rencanakan Liburan',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: const BoxDecoration(
                    color: _mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: _green,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard(DateTime? date) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: _mint,
                child: Icon(Icons.menu_book_rounded, color: _green, size: 21),
              ),
              SizedBox(width: 10),
              Text(
                'Tentang Hari Libur Ini',
                style: TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            widget.holiday.name.isEmpty
                ? 'Informasi hari libur dari kalender publik.'
                : widget.holiday.name,
            style: const TextStyle(color: _muted, fontSize: 15, height: 1.55),
          ),
          const SizedBox(height: 18),
          const Text(
            'Rincian',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.event_rounded,
            label: 'Tanggal',
            value: date == null
                ? widget.holiday.date
                : '${date.day} ${_months[date.month - 1]} ${date.year}',
          ),
          const SizedBox(height: 9),
          _InfoRow(
            icon: Icons.public_rounded,
            label: 'Negara',
            value: widget.holiday.countryCode.isEmpty
                ? 'Tidak tersedia'
                : widget.holiday.countryCode.toUpperCase(),
          ),
          if (widget.holiday.types.isNotEmpty) ...[
            const SizedBox(height: 9),
            _InfoRow(
              icon: Icons.category_rounded,
              label: 'Jenis',
              value: widget.holiday.types.join(', '),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveAction() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: _background.withValues(alpha: 0.96),
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
        height: 54,
        child: FilledButton.icon(
          onPressed: _saving ? null : _saveToCollection,
          style: FilledButton.styleFrom(
            backgroundColor: _mint,
            foregroundColor: _ink,
            disabledBackgroundColor: _mint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: _saving
              ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.bookmark_add_rounded),
          label: Text(
            _saving ? 'Menyimpan...' : '✨ Simpan ke Koleksi Rencana',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Future<void> _saveToCollection() async {
    setState(() => _saving = true);
    try {
      final categories = await TripTypeService.getAll();
      if (!mounted) return;
      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buat kategori liburan terlebih dahulu'),
          ),
        );
        return;
      }

      int? selectedId = categories.first.id;
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Simpan ke koleksi'),
            content: DropdownButtonFormField<int>(
              initialValue: selectedId,
              decoration: const InputDecoration(labelText: 'Kategori liburan'),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setDialogState(() => selectedId = value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: selectedId == null
                    ? null
                    : () => Navigator.pop(context, true),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      );
      if (shouldSave != true || selectedId == null || !mounted) return;

      await HolidayPlanService.create(
        tripTypeId: selectedId!,
        title: widget.holiday.localName.isNotEmpty
            ? widget.holiday.localName
            : widget.holiday.name,
        notes: widget.holiday.name,
        holidayDate: widget.holiday.date,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil disimpan ke koleksi')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A665C).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color background;
  final Color foreground;

  const _Badge({
    this.icon,
    required this.label,
    this.background = const Color(0xFFBCEDE0),
    this.foreground = const Color(0xFF214E44),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFF3A665C)),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF4A625B), fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF002018),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
