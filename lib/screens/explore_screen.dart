// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/public_holiday_model.dart';
import '../models/user_model.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../services/public_api_service.dart';
import 'profile_screen.dart';
import '../theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  final Future<List<PublicHoliday>> Function()? holidayLoader;
  final Future<UserModel> Function()? userLoader;
  final VoidCallback? onProfileTap;

  const ExploreScreen({
    super.key,
    this.holidayLoader,
    this.userLoader,
    this.onProfileTap,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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
  static const _weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _shortWeekdays = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  final int _year = DateTime.now().year;
  late Future<List<PublicHoliday>> _future;
  late Future<UserModel> _userFuture;
  int? _selectedMonth;
  late int _calendarMonth;
  DateTime? _selectedCalendarDate;

  @override
  void initState() {
    super.initState();
    _calendarMonth = DateTime.now().month;
    _future = _loadHolidays();
    _userFuture = _loadUser();
  }

  Future<List<PublicHoliday>> _loadHolidays() {
    return widget.holidayLoader?.call() ??
        PublicApiService.fetchHolidays(year: _year);
  }

  Future<UserModel> _loadUser() {
    return widget.userLoader?.call() ?? AuthService.fetchUser();
  }

  void _openProfile() {
    final onProfileTap = widget.onProfileTap;
    if (onProfileTap != null) {
      onProfileTap();
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
    );
  }

  Future<void> _refresh() async {
    final next = _loadHolidays();
    setState(() => _future = next);
    await next.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  List<PublicHoliday> _sortHolidays(List<PublicHoliday> holidays) {
    final sorted = List<PublicHoliday>.of(holidays);
    sorted.sort((a, b) {
      final aDate = DateTime.tryParse(a.date);
      final bDate = DateTime.tryParse(b.date);
      if (aDate == null) return bDate == null ? 0 : 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });
    return sorted;
  }

  DateTime? _dateFor(PublicHoliday holiday) => DateTime.tryParse(holiday.date);

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal belum tersedia';
    return '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
  }

  String _weekday(DateTime? date) {
    if (date == null) return 'Tanggal belum tersedia';
    return _weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _ExploreColors.background,
      appBar: AppBar(
        backgroundColor: _ExploreColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _ExploreColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Icon(
                Icons.event_available,
                color: _ExploreColors.secondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Jadwal',
              style: textTheme.titleLarge?.copyWith(
                color: _ExploreColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang jadwal',
            icon: const Icon(Icons.refresh, color: _ExploreColors.secondary),
            onPressed: _refresh,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildProfileAvatar(),
          ),
        ],
      ),
      body: FutureBuilder<List<PublicHoliday>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _ExploreColors.secondary),
            );
          }
          if (snapshot.hasError) {
            return _buildLoadError(snapshot.error, textTheme);
          }

          final holidays = _sortHolidays(snapshot.data ?? const []);
          if (holidays.isEmpty) {
            return _buildEmptyState(textTheme);
          }

          return _buildHolidayDashboard(holidays, textTheme);
        },
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return FutureBuilder<UserModel>(
      future: _userFuture,
      builder: (context, snapshot) {
        final name = snapshot.data?.name.trim() ?? '';
        final initial = name.isEmpty ? null : name[0].toUpperCase();
        final tooltip = snapshot.hasError
            ? 'Gagal memuat profil: ${snapshot.error}'
            : name.isEmpty
            ? 'Profil'
            : name;

        return Tooltip(
          message: tooltip,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _openProfile,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: _ExploreColors.primaryContainer,
              child: initial == null
                  ? const Icon(
                      Icons.person_outline,
                      color: _ExploreColors.primary,
                      size: 20,
                    )
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: _ExploreColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHolidayDashboard(
    List<PublicHoliday> holidays,
    TextTheme textTheme,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = holidays.where((holiday) {
      final date = _dateFor(holiday);
      return date != null && !date.isBefore(today);
    }).toList();
    final spotlight = upcoming.isEmpty ? null : upcoming.first;
    final filtered = _selectedMonth == null
        ? holidays
        : holidays.where((holiday) {
            return _dateFor(holiday)?.month == _selectedMonth;
          }).toList();

    return RefreshIndicator(
      color: _ExploreColors.secondary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _buildMetadata(holidays.length, textTheme),
          const SizedBox(height: 16),
          _buildGreeting(textTheme),
          const SizedBox(height: 24),
          _buildSpotlight(spotlight, today, textTheme),
          const SizedBox(height: 28),
          _buildMonthFilters(textTheme),
          const SizedBox(height: 16),
          _buildMonthlyCalendar(holidays, textTheme),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            _buildEmptyMonth(textTheme)
          else
            for (final holiday in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HolidayListCard(
                  holiday: holiday,
                  date: _dateFor(holiday),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouting.exploreDetail,
                    arguments: holiday,
                  ),
                ),
              ),
          const SizedBox(height: 8),
          _buildVacationTip(spotlight, textTheme),
        ],
      ),
    );
  }

  Widget _buildMetadata(int count, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoPill(
          icon: Icons.calendar_month_outlined,
          label: 'TAHUN $_year • INDONESIA',
          backgroundColor: _ExploreColors.secondaryContainer,
          foregroundColor: _ExploreColors.secondary,
          textTheme: textTheme,
        ),
        const SizedBox(width: 8),
        _InfoPill(
          icon: Icons.celebration_outlined,
          label: '$count Hari Libur',
          backgroundColor: _ExploreColors.secondaryContainer,
          foregroundColor: _ExploreColors.secondary,
          textTheme: textTheme,
        ),
      ],
    );
  }

  Widget _buildGreeting(TextTheme textTheme) {
    return FutureBuilder<UserModel>(
      future: _userFuture,
      builder: (context, snapshot) {
        final name = snapshot.data?.name.trim() ?? '';
        final firstName = name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              snapshot.hasError
                  ? 'Halo!'
                  : firstName.isEmpty
                  ? 'Halo! 👋'
                  : 'Halo, $firstName! 👋',
              style: textTheme.headlineSmall?.copyWith(
                color: _ExploreColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            if (snapshot.hasError) ...[
              const SizedBox(height: 2),
              Text(
                'Profil tidak dapat dimuat: ${snapshot.error.toString().replaceAll('Exception: ', '')}',
                style: textTheme.bodySmall?.copyWith(
                  color: _ExploreColors.danger,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Sudah siap merencanakan liburan seru berikutnya?',
              style: textTheme.bodyMedium?.copyWith(
                color: _ExploreColors.inkMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpotlight(
    PublicHoliday? holiday,
    DateTime today,
    TextTheme textTheme,
  ) {
    final date = DateTime.tryParse(holiday?.date ?? '');
    final daysUntil = date?.difference(today).inDays;
    final daysLabel = daysUntil == null
        ? 'Tidak ada libur mendatang'
        : daysUntil == 0
        ? 'Hari ini!'
        : 'Tinggal $daysUntil hari lagi!';
    final longWeekend =
        date?.weekday == DateTime.monday || date?.weekday == DateTime.friday;

    return Material(
      color: _ExploreColors.highlight,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: holiday == null
            ? null
            : () => Navigator.pushNamed(
                context,
                AppRouting.exploreDetail,
                arguments: holiday,
              ),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoPill(
                    icon: Icons.circle,
                    label: 'LIBUR TERDEKAT',
                    backgroundColor: _ExploreColors.secondaryContainer,
                    foregroundColor: _ExploreColors.secondary,
                    textTheme: textTheme,
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: _ExploreColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              daysLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelMedium?.copyWith(
                                color: _ExploreColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holiday?.localName ?? 'Jadwal libur tahun ini',
                          style: textTheme.headlineSmall?.copyWith(
                            color: _ExploreColors.ink,
                            fontSize: 20,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: _ExploreColors.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _formatDate(date),
                                style: textTheme.titleSmall?.copyWith(
                                  color: _ExploreColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0x66FFF4C8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration_outlined,
                      color: _ExploreColors.primary,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      longWeekend
                          ? Icons.beach_access_outlined
                          : Icons.event_available_outlined,
                      color: _ExploreColors.rust,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        holiday == null
                            ? 'Jadwal libur nasional tahun ini sudah selesai.'
                            : '${_weekday(date)}${longWeekend ? ' • Potensi long weekend' : ' • Libur nasional'}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _ExploreColors.rust,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _ExploreColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12002018),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lihat Detail Libur & Ide Cuti',
                        style: textTheme.titleSmall?.copyWith(
                          color: _ExploreColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: _ExploreColors.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthFilters(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jadwal Kalender',
              style: textTheme.titleLarge?.copyWith(
                color: _ExploreColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Urutkan Tanggal',
              style: textTheme.labelSmall?.copyWith(
                color: _ExploreColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _MonthFilterChip(
                key: const ValueKey('month-filter-all'),
                label: 'Semua',
                selected: _selectedMonth == null,
                onTap: () => setState(() {
                  _selectedMonth = null;
                  _selectedCalendarDate = null;
                }),
              ),
              for (var month = 1; month <= _months.length; month++)
                _MonthFilterChip(
                  key: ValueKey('month-filter-$month'),
                  label: _months[month - 1],
                  selected: _selectedMonth == month,
                  onTap: () => setState(() {
                    _selectedMonth = month;
                    _calendarMonth = month;
                    _selectedCalendarDate = null;
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyCalendar(
    List<PublicHoliday> holidays,
    TextTheme textTheme,
  ) {
    final firstDay = DateTime(_year, _calendarMonth, 1);
    final daysInMonth = DateTime(_year, _calendarMonth + 1, 0).day;
    final leadingDays = firstDay.weekday - 1;
    final totalCells = ((leadingDays + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();

    return Container(
      key: const ValueKey('monthly-calendar'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: _ExploreColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A002018),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                key: const ValueKey('calendar-prev-month'),
                tooltip: 'Bulan sebelumnya',
                onPressed: () => setState(() {
                  _calendarMonth = _calendarMonth == 1
                      ? 12
                      : _calendarMonth - 1;
                  _selectedMonth = _calendarMonth;
                  _selectedCalendarDate = null;
                }),
                icon: const Icon(
                  Icons.chevron_left,
                  color: _ExploreColors.secondary,
                ),
              ),
              Expanded(
                child: Text(
                  '${_months[_calendarMonth - 1]} $_year',
                  key: const ValueKey('calendar-month-title'),
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.copyWith(
                    color: _ExploreColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('calendar-next-month'),
                tooltip: 'Bulan berikutnya',
                onPressed: () => setState(() {
                  _calendarMonth = _calendarMonth == 12
                      ? 1
                      : _calendarMonth + 1;
                  _selectedMonth = _calendarMonth;
                  _selectedCalendarDate = null;
                }),
                icon: const Icon(
                  Icons.chevron_right,
                  color: _ExploreColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final day in _shortWeekdays)
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: _ExploreColors.outline,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            key: const ValueKey('calendar-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              mainAxisExtent: 44,
            ),
            itemBuilder: (context, index) {
              final dayOffset = index - leadingDays;
              if (dayOffset < 1 || dayOffset > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(_year, _calendarMonth, dayOffset);
              final holidayMatches = holidays.where((holiday) {
                final holidayDate = _dateFor(holiday);
                return holidayDate != null &&
                    holidayDate.year == date.year &&
                    holidayDate.month == date.month &&
                    holidayDate.day == date.day;
              }).toList();
              final isHoliday = holidayMatches.isNotEmpty;
              final isToday =
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSelected =
                  _selectedCalendarDate?.year == date.year &&
                  _selectedCalendarDate?.month == date.month &&
                  _selectedCalendarDate?.day == date.day;

              return InkWell(
                key: ValueKey('calendar-day-$dayOffset'),
                onTap: () {
                  setState(() {
                    _selectedCalendarDate = date;
                    _selectedMonth = date.month;
                  });
                  if (holidayMatches.length == 1) {
                    Navigator.pushNamed(
                      context,
                      AppRouting.exploreDetail,
                      arguments: holidayMatches.first,
                    );
                  }
                },
                customBorder: const CircleBorder(),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _ExploreColors.secondaryContainer
                        : isToday
                        ? _ExploreColors.primaryContainer
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: _ExploreColors.primary, width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayOffset',
                        style: textTheme.labelMedium?.copyWith(
                          color: isHoliday
                              ? _ExploreColors.rust
                              : isSelected
                              ? _ExploreColors.secondary
                              : _ExploreColors.ink,
                          fontSize: 12,
                          fontWeight: isHoliday || isToday || isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      if (isHoliday)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: _ExploreColors.rust,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVacationTip(PublicHoliday? holiday, TextTheme textTheme) {
    final date = holiday == null ? null : _dateFor(holiday);
    final message = holiday == null
        ? 'Pantau kalender dan rencanakan cuti lebih awal agar liburanmu lebih maksimal.'
        : '${holiday.localName} jatuh pada ${_weekday(date)}. Rencanakan cuti lebih awal untuk liburan yang lebih santai.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ExploreColors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: _ExploreColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saran Hemat Cuti',
                  style: textTheme.titleSmall?.copyWith(
                    color: _ExploreColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: _ExploreColors.inkMuted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMonth(TextTheme textTheme) {
    final month = _months[(_selectedMonth ?? 1) - 1];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _ExploreColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_outlined,
            color: _ExploreColors.secondary,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            'Belum ada jadwal di bulan $month',
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
              color: _ExploreColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadError(Object? error, TextTheme textTheme) {
    final message =
        error?.toString().replaceAll('Exception: ', '') ??
        'Terjadi kesalahan saat memuat jadwal.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: _ExploreColors.danger,
              size: 36,
            ),
            const SizedBox(height: 14),
            Text(
              'Gagal memuat jadwal libur',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: _ExploreColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: _ExploreColors.inkMuted,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _ExploreColors.secondary,
                side: const BorderSide(color: _ExploreColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              color: _ExploreColors.secondary,
              size: 36,
            ),
            const SizedBox(height: 14),
            Text(
              'Belum ada data hari libur',
              style: textTheme.titleMedium?.copyWith(
                color: _ExploreColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Daftar libur nasional untuk tahun $_year belum tersedia.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: _ExploreColors.inkMuted,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _ExploreColors.secondary,
                side: const BorderSide(color: _ExploreColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextTheme textTheme;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MonthFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? _ExploreColors.secondary : _ExploreColors.inkMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        selectedColor: _ExploreColors.secondaryContainer,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _HolidayListCard extends StatelessWidget {
  final PublicHoliday holiday;
  final DateTime? date;
  final VoidCallback onTap;

  const _HolidayListCard({
    required this.holiday,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final longWeekend =
        date != null &&
        (date!.weekday == DateTime.monday || date!.weekday == DateTime.friday);
    final dateBlockColor =
        date != null &&
            (date!.weekday == DateTime.saturday ||
                date!.weekday == DateTime.sunday)
        ? _ExploreColors.primaryContainer
        : _ExploreColors.secondaryContainer;

    return Material(
      color: _ExploreColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A002018),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _HolidayDateBlock(date: date, color: dateBlockColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _CategoryTag(
                          icon: Icons.event_available,
                          label: 'Libur Nasional',
                          backgroundColor: _ExploreColors.secondaryContainer,
                          foregroundColor: _ExploreColors.secondary,
                        ),
                        if (longWeekend)
                          _CategoryTag(
                            icon: Icons.beach_access_outlined,
                            label: 'Long Weekend',
                            backgroundColor: _ExploreColors.coralSoft,
                            foregroundColor: _ExploreColors.rust,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      holiday.localName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: _ExploreColors.ink,
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      holiday.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: _ExploreColors.inkMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                color: _ExploreColors.outline,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HolidayDateBlock extends StatelessWidget {
  final DateTime? date;
  final Color color;

  const _HolidayDateBlock({required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color == _ExploreColors.primaryContainer
        ? _ExploreColors.primary
        : _ExploreColors.secondary;

    return Container(
      width: 64,
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date == null ? '--' : date!.day.toString().padLeft(2, '0'),
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              height: 1.1,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date == null
                ? '---'
                : _ExploreScreenState._shortMonths[date!.month - 1],
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date == null
                ? '—'
                : _ExploreScreenState._shortWeekdays[date!.weekday - 1],
            style: TextStyle(color: textColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _CategoryTag({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreColors {
  static const background = Color(0xFFE6FFF4);
  static const surface = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFBCEDDE);
  static const primaryContainer = Color(0xFFFFEEB3);
  static const highlight = Color(0xFFFFEEB3);
  static const coralSoft = Color(0xFFFFEAE4);
  static const ink = Color(0xFF002018);
  static const inkMuted = Color(0xFF4A473B);
  static const outline = Color(0xFF7C7769);
  static const secondary = Color(0xFF3A665C);
  static const primary = Color(0xFF6A5E30);
  static const rust = Color(0xFF944930);
  static const danger = Color(0xFFBA1A1A);
}
