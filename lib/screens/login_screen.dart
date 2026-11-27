// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/holiday_login_illustration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.login(_email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouting.main);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _LoginColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWelcome(textTheme),
                  const SizedBox(height: 24),
                  _buildLoginCard(textTheme),
                  const SizedBox(height: 16),
                  _buildHolidayTip(textTheme),
                  const SizedBox(height: 24),
                  _buildRegisterLink(textTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _LoginColors.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14002018),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_available,
                color: _LoginColors.secondary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'AGENDA LIBURKU',
                style: textTheme.labelSmall?.copyWith(
                  color: _LoginColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const HolidayLoginIllustration(),
        const SizedBox(height: 8),
        Text(
          'Selamat datang kembali!',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: _LoginColors.ink,
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310),
          child: Text(
            'Masuk untuk melihat kalender libur dan susun agenda liburan impianmu.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: _LoginColors.inkMuted,
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _LoginColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12002018),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFieldLabel('Email', textTheme),
          const SizedBox(height: 6),
          _buildEmailField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFieldLabel('Kata Sandi', textTheme)),
              Text(
                'Lupa Kata Sandi?',
                style: textTheme.labelSmall?.copyWith(
                  color: _LoginColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildPasswordField(),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _LoginColors.secondaryContainer,
                foregroundColor: _LoginColors.ink,
                disabledBackgroundColor: _LoginColors.secondaryContainer,
                disabledForegroundColor: _LoginColors.ink,
                elevation: 1,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                textStyle: textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _LoginColors.secondary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Masuk',
                          style: textTheme.labelLarge?.copyWith(
                            color: _LoginColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, TextTheme textTheme) {
    return Text(
      label,
      style: textTheme.labelLarge?.copyWith(
        color: _LoginColors.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildEmailField() {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        style: const TextStyle(color: _LoginColors.ink, fontSize: 16),
        decoration: _fieldDecoration(
          hintText: 'nama@email.com',
          icon: Icons.mail_outline,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _password,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          if (!_loading) _submit();
        },
        style: const TextStyle(color: _LoginColors.ink, fontSize: 16),
        decoration: _fieldDecoration(
          hintText: 'Masukkan kata sandi',
          icon: Icons.lock_outline,
          suffixIcon: IconButton(
            tooltip: _obscurePassword
                ? 'Tampilkan kata sandi'
                : 'Sembunyikan kata sandi',
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _LoginColors.inkSubtle,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final borderRadius = BorderRadius.circular(AppTheme.radiusMd);

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _LoginColors.outline, fontSize: 16),
      filled: true,
      fillColor: _LoginColors.field,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      prefixIcon: Icon(icon, color: _LoginColors.secondary, size: 20),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 48),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: _LoginColors.secondary, width: 1.5),
      ),
    );
  }

  Widget _buildHolidayTip(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _LoginColors.tip,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _LoginColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.beach_access_outlined,
              size: 18,
              color: _LoginColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: _LoginColors.inkMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(
                    text: 'Tips Libur: ',
                    style: TextStyle(
                      color: _LoginColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'Ada 4 long weekend menunggumu di tahun ini! Yuk mulai agendakan.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun?',
          style: textTheme.bodyMedium?.copyWith(
            color: _LoginColors.inkMuted,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRouting.register),
          style: TextButton.styleFrom(
            foregroundColor: _LoginColors.secondary,
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            textStyle: textTheme.labelLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Daftar'),
        ),
      ],
    );
  }
}

class _LoginColors {
  static const background = Color(0xFFE6FFF4);
  static const surface = Color(0xFFFFFFFF);
  static const field = Color(0xFFCEFEEB);
  static const secondaryContainer = Color(0xFFBCEDDE);
  static const primaryContainer = Color(0xFFFFEEB3);
  static const tip = Color(0x99FFEEB3);
  static const ink = Color(0xFF002018);
  static const inkMuted = Color(0xFF4A473B);
  static const inkSubtle = Color(0xFF7C7769);
  static const secondary = Color(0xFF3A665C);
  static const primary = Color(0xFF6A5E30);
  static const outline = Color(0xFF7C7769);
}
