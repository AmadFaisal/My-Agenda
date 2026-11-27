// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/holiday_register_illustration.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  int get _passwordStrength {
    final password = _password.text;
    if (password.isEmpty) return 0;

    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password) || password.length >= 12) {
      score++;
    }
    return score;
  }

  bool get _passwordMeetsRequirements =>
      _password.text.length >= 8 &&
      RegExp(r'[A-Za-z]').hasMatch(_password.text) &&
      RegExp(r'\d').hasMatch(_password.text);

  bool get _passwordsMatch =>
      _confirmPassword.text.isNotEmpty &&
      _password.text == _confirmPassword.text;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.isEmpty ||
        _confirmPassword.text.isEmpty) {
      _showMessage('Semua kolom wajib diisi');
      return;
    }
    if (!_passwordMeetsRequirements) {
      _showMessage(
        'Password minimal 8 karakter dan harus mengandung huruf serta angka',
      );
      return;
    }
    if (!_passwordsMatch) {
      _showMessage('Konfirmasi kata sandi belum cocok');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.register(
        _name.text.trim(),
        _email.text.trim(),
        _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat, silakan masuk')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, AppRouting.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _RegisterColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(textTheme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWelcome(textTheme),
                        const SizedBox(height: 24),
                        _buildRegisterCard(textTheme),
                        const SizedBox(height: 24),
                        _buildLoginLink(textTheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xCCE6FFF4),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A002018),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Kembali',
              onPressed: _goToLogin,
              icon: const Icon(Icons.arrow_back, size: 24),
              color: _RegisterColors.ink,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            ),
          ),
          Text(
            'Register',
            style: textTheme.titleLarge?.copyWith(
              color: _RegisterColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _RegisterColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(TextTheme textTheme) {
    return Column(
      children: [
        const HolidayRegisterIllustration(),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _RegisterColors.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12002018),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.flight_takeoff,
                size: 14,
                color: _RegisterColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Langkah Awal Liburan',
                style: textTheme.labelSmall?.copyWith(
                  color: _RegisterColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Buat akun baru ✨',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: _RegisterColors.ink,
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            'Mulai rencanakan libur panjang dan cuti cerdas bersama Agenda Liburku.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: _RegisterColors.inkMuted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _RegisterColors.surface,
        borderRadius: BorderRadius.circular(16),
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
          _buildFieldLabel('Nama Lengkap', textTheme),
          const SizedBox(height: 6),
          _buildNameField(),
          const SizedBox(height: 16),
          _buildFieldLabel('Email', textTheme),
          const SizedBox(height: 6),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildFieldLabel('Kata Sandi', textTheme),
          const SizedBox(height: 6),
          _buildPasswordField(),
          const SizedBox(height: 8),
          _buildPasswordStrength(textTheme),
          const SizedBox(height: 16),
          _buildFieldLabel('Konfirmasi Kata Sandi', textTheme),
          const SizedBox(height: 6),
          _buildConfirmPasswordField(),
          if (_confirmPassword.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildPasswordMatch(textTheme),
          ],
          const SizedBox(height: 16),
          _buildBenefitCard(textTheme),
          const SizedBox(height: 24),
          _buildSubmitButton(textTheme),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, TextTheme textTheme) {
    return Text(
      label,
      style: textTheme.labelLarge?.copyWith(
        color: _RegisterColors.inkMuted,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildNameField() {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        style: const TextStyle(color: _RegisterColors.ink, fontSize: 16),
        decoration: _fieldDecoration(
          hintText: 'Contoh: Rania Daniswara',
          icon: Icons.person_outline,
        ),
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
        style: const TextStyle(color: _RegisterColors.ink, fontSize: 16),
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
        key: const ValueKey('register-password'),
        controller: _password,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: _RegisterColors.ink, fontSize: 16),
        decoration: _fieldDecoration(
          hintText: 'Minimal 8 karakter',
          icon: Icons.lock_outline,
          suffixIcon: IconButton(
            tooltip: _obscurePassword ? 'Tampilkan sandi' : 'Sembunyikan sandi',
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _RegisterColors.outline,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return SizedBox(
      height: 48,
      child: TextField(
        key: const ValueKey('register-confirm-password'),
        controller: _confirmPassword,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) {
          if (!_loading) _submit();
        },
        style: const TextStyle(color: _RegisterColors.ink, fontSize: 16),
        decoration: _fieldDecoration(
          hintText: 'Ulangi kata sandi',
          icon: Icons.verified_user_outlined,
          suffixIcon: IconButton(
            tooltip: _obscureConfirmPassword
                ? 'Tampilkan konfirmasi sandi'
                : 'Sembunyikan konfirmasi sandi',
            onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _RegisterColors.outline,
              size: 20,
            ),
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
    final borderRadius = BorderRadius.circular(AppTheme.radiusLg);

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _RegisterColors.outline, fontSize: 16),
      filled: true,
      fillColor: _RegisterColors.field,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      prefixIcon: Icon(icon, color: _RegisterColors.secondary, size: 20),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 48),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: _RegisterColors.secondary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildPasswordStrength(TextTheme textTheme) {
    final score = _passwordStrength;
    final color = switch (score) {
      0 => _RegisterColors.outline,
      1 => _RegisterColors.danger,
      2 => _RegisterColors.primary,
      _ => _RegisterColors.secondary,
    };
    final message = switch (score) {
      0 => 'Minimal 8 karakter & kombinasi huruf/angka',
      1 => 'Kata sandi lemah (tambahkan kombinasi angka/huruf)',
      2 => 'Cukup kuat untuk keamanan akunmu',
      _ => 'Sangat kuat! Mantap untuk merencanakan liburan',
    };
    final icon = switch (score) {
      0 => Icons.info_outline,
      1 => Icons.warning_amber_outlined,
      2 => Icons.verified_outlined,
      _ => Icons.task_alt,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: index < score
                        ? color
                        : _RegisterColors.strengthTrack,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodySmall?.copyWith(
                    color: score == 0 ? _RegisterColors.inkMuted : color,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordMatch(TextTheme textTheme) {
    final matches = _passwordsMatch;
    final color = matches ? _RegisterColors.secondary : _RegisterColors.danger;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(
            matches ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            matches ? 'Kata sandi sesuai dan cocok' : 'Kata sandi belum cocok',
            style: textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _RegisterColors.benefit,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.beach_access_outlined,
            color: _RegisterColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuti Bersama Otomatis Terhubung',
                  style: textTheme.labelLarge?.copyWith(
                    color: _RegisterColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kalender SKB 3 Menteri resmi langsung siap di ponselmu setelah mendaftar.',
                  style: textTheme.bodySmall?.copyWith(
                    color: _RegisterColors.inkMuted,
                    fontSize: 12,
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

  Widget _buildSubmitButton(TextTheme textTheme) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _RegisterColors.secondaryContainer,
          foregroundColor: _RegisterColors.ink,
          disabledBackgroundColor: _RegisterColors.secondaryContainer,
          disabledForegroundColor: _RegisterColors.ink,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const StadiumBorder(),
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
                  color: _RegisterColors.secondary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Daftar Sekarang',
                    style: textTheme.labelLarge?.copyWith(
                      color: _RegisterColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink(TextTheme textTheme) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Sudah punya akun?',
              style: textTheme.bodyMedium?.copyWith(
                color: _RegisterColors.inkMuted,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: _goToLogin,
              style: TextButton.styleFrom(
                foregroundColor: _RegisterColors.secondary,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                textStyle: textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: _RegisterColors.secondary.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: const Text('Masuk di sini'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _RegisterColors.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_reset,
                size: 14,
                color: _RegisterColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                '100% Bebas Iklan & Aman',
                style: textTheme.labelSmall?.copyWith(
                  color: _RegisterColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegisterColors {
  static const background = Color(0xFFE6FFF4);
  static const surface = Color(0xFFFFFFFF);
  static const field = Color(0xFFE6FFF4);
  static const secondaryContainer = Color(0xFFBCEDDE);
  static const strengthTrack = Color(0xFFBDEDDB);
  static const benefit = Color(0x66FFEEB3);
  static const ink = Color(0xFF002018);
  static const inkMuted = Color(0xFF4A473B);
  static const outline = Color(0xFF7C7769);
  static const secondary = Color(0xFF3A665C);
  static const primary = Color(0xFF6A5E30);
  static const danger = Color(0xFFBA1A1A);
}
