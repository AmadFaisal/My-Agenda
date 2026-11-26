import 'package:flutter/material.dart';

import '../models/public_holiday_model.dart';
import '../routes/app_routing.dart';
import '../services/public_api_service.dart';
import '../theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<PublicHoliday>> _future;

  @override
  void initState() {
    super.initState();
    _future = PublicApiService.fetchHolidays();
  }

  void _refresh() {
    setState(() {
      _future = PublicApiService.fetchHolidays();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Libur'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang jadwal',
            icon: const Icon(Icons.refresh, color: AppTheme.inkMuted),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<PublicHoliday>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }
          if (snap.hasError) {
            return UtilitarianStateView(
              icon: Icons.cloud_off_outlined,
              title: 'Gagal memuat jadwal libur',
              message: snap.error.toString().replaceAll('Exception: ', ''),
              actionLabel: 'Coba Lagi',
              onAction: _refresh,
              isError: true,
            );
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return UtilitarianStateView(
              icon: Icons.event_busy_outlined,
              title: 'Belum ada data hari libur',
              message: 'Daftar libur nasional untuk tahun ini belum tersedia.',
              actionLabel: 'Muat Ulang',
              onAction: _refresh,
            );
          }

          final primaryHighlight = items.first;
          final secondaryHighlights = items.skip(1).take(2).toList();
          final listItems = items.skip(3).toList();

          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              children: [
                // Section 1: Focal Point - Nearest Holiday Spotlight
                const Text(
                  'LIBUR TERDEKAT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: AppTheme.inkMuted,
                  ),
                ),
                const SizedBox(height: 10),
                _SpotlightHolidayCard(
                  holiday: primaryHighlight,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouting.exploreDetail,
                    arguments: primaryHighlight,
                  ),
                ),

                if (secondaryHighlights.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (int i = 0; i < secondaryHighlights.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: _CompactUpcomingCard(
                            holiday: secondaryHighlights[i],
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRouting.exploreDetail,
                              arguments: secondaryHighlights[i],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 28),

                // Section 2: Full Timetable List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'JADWAL LIBUR NASIONAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                    Text(
                      '${items.length} tanggal',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.inkSubtle,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.border, width: 1),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final h = listItems[index];
                      return InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouting.exploreDetail,
                          arguments: h,
                        ),
                        borderRadius: index == 0
                            ? const BorderRadius.vertical(
                                top: Radius.circular(AppTheme.radiusLg),
                              )
                            : index == listItems.length - 1
                                ? const BorderRadius.vertical(
                                    bottom: Radius.circular(AppTheme.radiusLg),
                                  )
                                : BorderRadius.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              TimetableDateBadge(isoDate: h.date),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      h.localName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${h.date}  ·  ${h.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: AppTheme.inkSubtle,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SpotlightHolidayCard extends StatelessWidget {
  final PublicHoliday holiday;
  final VoidCallback onTap;

  const _SpotlightHolidayCard({required this.holiday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.accentBorder, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimetableDateBadge(isoDate: holiday.date, highlighted: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentSoft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        holiday.types.isNotEmpty
                            ? holiday.types.first
                            : 'Libur Nasional',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      holiday.localName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${holiday.name} (${holiday.date})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.chevron_right,
                  color: AppTheme.accent,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactUpcomingCard extends StatelessWidget {
  final PublicHoliday holiday;
  final VoidCallback onTap;

  const _CompactUpcomingCard({required this.holiday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                holiday.date,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                holiday.localName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ink,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
