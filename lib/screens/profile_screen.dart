// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/holiday_plan_model.dart';
import '../models/trip_type_model.dart';
import '../models/user_model.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../services/holiday_plan_service.dart';
import '../services/trip_type_service.dart';
import '../theme/app_theme.dart';

typedef ProfileUserLoader = Future<UserModel> Function();
typedef ProfilePlanLoader = Future<List<HolidayPlanModel>> Function();
typedef ProfileCategoryLoader = Future<List<TripTypeModel>> Function();

class ProfileScreen extends StatefulWidget {
  final ProfileUserLoader? userLoader;
  final ProfilePlanLoader? planLoader;
  final ProfileCategoryLoader? categoryLoader;

  const ProfileScreen({
    super.key,
    this.userLoader,
    this.planLoader,
    this.categoryLoader,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _background = Color(0xFFE6FFF4);
  static const _mint = Color(0xFFBCEDE0);
  static const _mintLight = Color(0xFFCEFEED);
  static const _green = Color(0xFF3A665C);
  static const _ink = Color(0xFF002018);
  static const _muted = Color(0xFF4A625B);
  static const _cream = Color(0xFFFFEEB3);
  static const _coral = Color(0xFF944930);

  UserModel? _user;
  bool _userLoading = true;
  Object? _userError;

  int? _planCount;
  int? _categoryCount;
  bool _statsLoading = true;
  Object? _statsError;
  bool _loggingOut = false;

  Future<UserModel> _loadUser() =>
      widget.userLoader?.call() ?? AuthService.fetchUser();

  Future<List<HolidayPlanModel>> _loadPlans() =>
      widget.planLoader?.call() ?? HolidayPlanService.getAll();

  Future<List<TripTypeModel>> _loadCategories() =>
      widget.categoryLoader?.call() ?? TripTypeService.getAll();

  @override
  void initState() {
    super.initState();
    _refreshUser();
    _refreshStats();
  }

  Future<void> _refreshUser() async {
    setState(() {
      _userLoading = true;
      _userError = null;
    });
    try {
      final user = await _loadUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _userLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _userError = error;
        _userLoading = false;
      });
    }
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsLoading = true;
      _statsError = null;
    });
    try {
      final plans = await _loadPlans();
      final categories = await _loadCategories();
      if (!mounted) return;
      setState(() {
        _planCount = plans.length;
        _categoryCount = categories.length;
        _statsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _statsError = error;
        _statsLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouting.login,
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal keluar dari akun: $error')));
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  String _initialFor(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _ink,
        title: const Row(
          children: [
            Icon(Icons.person_rounded, color: _green, size: 23),
            SizedBox(width: 9),
            Text('Profil'),
          ],
        ),
      ),
      body: _userLoading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : _userError != null
          ? _ProfileErrorState(
              message: _userError.toString(),
              onRetry: _refreshUser,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                _buildAccountCard(),
                const SizedBox(height: 17),
                _buildStats(),
                if (_statsError != null) ...[
                  const SizedBox(height: 10),
                  _StatsError(error: _statsError!, onRetry: _refreshStats),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle(Icons.tune_rounded, 'Kalender & Informasi'),
                const SizedBox(height: 10),
                _buildCalendarInfoCard(),
                const SizedBox(height: 21),
                _buildSectionTitle(
                  Icons.account_circle_outlined,
                  'Identitas Pembuat',
                ),
                const SizedBox(height: 10),
                _buildAuthorCard(),
                const SizedBox(height: 20),
                _buildLogoutButton(),
                const SizedBox(height: 18),
                _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildAccountCard() {
    final name = _user?.name ?? '-';
    final email = _user?.email ?? '-';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFFFDF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: _mint,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: _mintLight,
              child: Text(
                _initialFor(name),
                style: const TextStyle(
                  color: _green,
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 14),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: _mintLight,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded, color: _green, size: 16),
                SizedBox(width: 6),
                Text(
                  'Akun Agenda Liburku',
                  style: TextStyle(
                    color: _green,
                    fontSize: 12,
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

  Widget _buildStats() {
    final plans = _statsLoading ? '…' : _planCount?.toString() ?? '—';
    final categories = _statsLoading ? '…' : _categoryCount?.toString() ?? '—';

    return Row(
      children: [
        Expanded(
          child: _ProfileStatCard(
            icon: Icons.luggage_rounded,
            value: plans,
            label: 'Rencana Tersimpan',
            badge: 'Koleksi',
            background: _cream,
            foreground: const Color(0xFF6A5E30),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileStatCard(
            icon: Icons.category_rounded,
            value: categories,
            label: 'Jenis Liburan',
            badge: 'Kategori',
            background: _mint,
            foreground: _green,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 19, color: _green),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _muted,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarInfoCard() {
    return _ProfileCard(
      children: [
        _InfoTile(
          icon: Icons.event_available_rounded,
          title: 'Kalender Libur Nasional',
          subtitle: 'Jadwal libur publik mengikuti data kalender Indonesia.',
          tint: _mintLight,
        ),
        const Divider(height: 1, indent: 58),
        _InfoTile(
          icon: Icons.public_rounded,
          title: 'Sumber Kalender',
          subtitle: 'date.nager.at/api/v3',
          tint: const Color(0xFFFFF4D1),
        ),
        const Divider(height: 1, indent: 58),
        _InfoTile(
          icon: Icons.info_outline_rounded,
          title: 'Tentang Agenda Liburku',
          subtitle: 'Bantuan dan informasi aplikasi',
          tint: const Color(0xFFFFEAE4),
          onTap: _showAbout,
        ),
      ],
    );
  }

  Widget _buildAuthorCard() {
    return _ProfileCard(
      children: [
        _IdentityRow(label: 'Nama', value: 'Ahmad Faisal'),
        const Divider(height: 1),
        _IdentityRow(label: 'Kelas', value: 'XII RPL 2'),
        const Divider(height: 1),
        _IdentityRow(label: 'Absen', value: '5'),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _loggingOut ? null : _logout,
        icon: _loggingOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: _coral),
              )
            : const Icon(Icons.logout_rounded),
        label: Text(_loggingOut ? 'Keluar...' : 'Keluar Akun'),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _coral,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.park_rounded, color: _green, size: 17),
            SizedBox(width: 5),
            Icon(Icons.wb_sunny_rounded, color: _green, size: 17),
            SizedBox(width: 5),
            Icon(Icons.sailing_rounded, color: _green, size: 17),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Agenda Liburku © ${DateTime.now().year} • Dibuat untuk Momen Liburan Lebih Bahagia',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Agenda Liburku',
      applicationLegalese:
          'Informasi tanggal libur nasional dan penyimpanan rencana liburan.',
      children: const [
        SizedBox(height: 8),
        Text('Kalender publik: date.nager.at/api/v3'),
      ],
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String badge;
  final Color background;
  final Color foreground;

  const _ProfileStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.badge,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 137,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: foreground, size: 21),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF002018),
              fontSize: 29,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A665C).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: _ProfileScreenState._green, size: 21),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF002018),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF4A625B),
            fontSize: 12,
            height: 1.35,
          ),
        ),
        trailing: onTap == null
            ? null
            : const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C7769)),
        onTap: onTap,
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  final String label;
  final String value;

  const _IdentityRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF4A625B), fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF002018),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              color: AppTheme.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat profil',
              style: TextStyle(
                color: Color(0xFF002018),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4A625B), fontSize: 13),
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

class _StatsError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _StatsError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAE4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFF944930)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gagal memuat statistik: $error',
              style: const TextStyle(color: Color(0xFF002018), fontSize: 12),
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang statistik',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF3A665C),
          ),
        ],
      ),
    );
  }
}
