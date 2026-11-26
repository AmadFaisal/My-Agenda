import 'package:flutter/material.dart';

import '../models/public_holiday_model.dart';
import '../models/trip_type_model.dart';
import '../services/holiday_plan_service.dart';
import '../services/trip_type_service.dart';
import '../theme/app_theme.dart';

class ExploreDetailScreen extends StatefulWidget {
  final PublicHoliday holiday;
  const ExploreDetailScreen({super.key, required this.holiday});
  @override
  State<ExploreDetailScreen> createState() => _ExploreDetailScreenState();
}

class _ExploreDetailScreenState extends State<ExploreDetailScreen> {
  bool _saving = false;

  Future<void> _simpanKeKoleksi() async {
    setState(() => _saving = true);
    List<TripTypeModel> categories = [];
    try {
      categories = await TripTypeService.getAll();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kategori: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buat kategori dulu di tab Koleksi sebelum menyimpan.'),
        ),
      );
      return;
    }

    int? selectedId = categories.first.id;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simpan ke Koleksi'),
        content: DropdownButtonFormField<int>(
          value: selectedId,
          isExpanded: true,
          items: categories
              .map(
                (t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(t.name, style: const TextStyle(color: AppTheme.ink)),
                ),
              )
              .toList(),
          onChanged: (v) => selectedId = v,
          decoration: const InputDecoration(labelText: 'Pilih Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await HolidayPlanService.create(
                  tripTypeId: selectedId!,
                  title: widget.holiday.localName,
                  notes: 'Libur nasional: ${widget.holiday.name}',
                  holidayDate: widget.holiday.date,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rencana libur berhasil disimpan')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menyimpan: $e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.holiday;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Hari Libur')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TimetableDateBadge(isoDate: h.date, highlighted: true),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.localName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            h.name,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'INFORMASI JADWAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: AppTheme.inkMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Tanggal', h.date),
                      const Divider(height: 1),
                      _buildInfoRow('Kode Negara', h.countryCode),
                      const Divider(height: 1),
                      _buildInfoRow(
                        'Tipe',
                        h.types.isNotEmpty ? h.types.join(', ') : '-',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _simpanKeKoleksi,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_saving)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(Icons.bookmark_add_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text('Simpan ke Koleksi'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.inkMuted, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
