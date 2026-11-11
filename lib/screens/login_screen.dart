import 'package:flutter/material.dart';
import '../data/local_catalog.dart';
import '../models/student.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_rgb_background.dart';

class LoginScreen extends StatefulWidget {
  final AppState state;

  const LoginScreen({super.key, required this.state});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegister = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController(text: "SD Negeri 1 Madiun");

  String _selectedAvatar = "👦";
  String _selectedGrade = "Kelas 4 SD";

  final List<String> _avatarOptions = ["👦", "👧", "🧒", "🧑", "🎓", "🚀", "🌟", "🦁", "🤖", "🎨"];
  final List<String> _gradeOptions = ["Kelas 3 SD", "Kelas 4 SD", "Kelas 5 SD", "Kelas 6 SD"];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _handleDemoLogin(Student student) async {
    SoundService.playClick();
    setState(() => _isLoading = true);
    await widget.state.loginWithDemo(student);
    SoundService.playCoin();
  }

  void _handleSubmit() async {
    SoundService.playClick();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      SoundService.playWrong();
      setState(() => _errorMessage = "Masukkan format email yang benar ya! 😊");
      return;
    }
    if (password.length < 6) {
      SoundService.playWrong();
      setState(() => _errorMessage = "Kata sandi minimal 6 karakter.");
      return;
    }

    if (_isRegister && _nameController.text.trim().isEmpty) {
      SoundService.playWrong();
      setState(() => _errorMessage = "Nama lengkap siswa wajib diisi.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_isRegister) {
      await widget.state.registerStudent(
        name: _nameController.text.trim(),
        email: email,
        password: password,
        avatar: _selectedAvatar,
        grade: _selectedGrade,
        school: _schoolController.text.trim(),
      );
    } else {
      await widget.state.loginWithCredentials(email, password);
    }
    SoundService.playCorrect();
    SoundService.playCoin();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: AnimatedRgbBackground(
        isDark: isDark,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),

                // Brand Icon dengan Nuansa RGB Gradien Halus
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withAlpha(100),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withAlpha(60),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "SD",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Subtitle Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF78350F), const Color(0xFF581C87)]
                          : [const Color(0xFFFEF3C7), const Color(0xFFEDE9FE)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFFF59E0B).withAlpha(100) : const Color(0xFFC4B5FD),
                    ),
                  ),
                  child: Text(
                    "🇮🇩 Ruang Belajar PKn & 🎭 Bahasa Jawa SD",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF6D28D9),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  "ExplainMyLesson",
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Masuk untuk kumpulkan poin prestasi & belajar bersama!",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Main Auth Card dengan Aksen RGB Strip di Bagian Atas
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withAlpha(80) : const Color(0xFF3B82F6).withAlpha(20),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      children: [
                        // Garis Aksen RGB Halus (Rainbow Glow)
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF06B6D4), // Cyan
                                Color(0xFF3B82F6), // Blue
                                Color(0xFF8B5CF6), // Indigo/Purple
                                Color(0xFFEC4899), // Pink
                                Color(0xFFF59E0B), // Amber
                                Color(0xFF10B981), // Emerald
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                    // Tab Switcher: Masuk vs Daftar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildAuthTab(
                              label: "Masuk Akun",
                              isActive: !_isRegister,
                              isDark: isDark,
                              onTap: () => setState(() {
                                _isRegister = false;
                                _errorMessage = null;
                              }),
                            ),
                          ),
                          Expanded(
                            child: _buildAuthTab(
                              label: "Daftar Baru",
                              isActive: _isRegister,
                              isDark: isDark,
                              onTap: () => setState(() {
                                _isRegister = true;
                                _errorMessage = null;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRedLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.errorRed.withAlpha(100)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppTheme.errorRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppTheme.errorRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Register Fields
                    if (_isRegister) ...[
                      Text(
                        "Pilih Avatar Karakter:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _avatarOptions.length,
                          itemBuilder: (ctx, i) {
                            final av = _avatarOptions[i];
                            final isSel = av == _selectedAvatar;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatar = av),
                              child: Container(
                                width: 46,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? (isDark ? const Color(0xFF1E3A8A) : AppTheme.danaBlueLight)
                                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel ? AppTheme.danaBlue : (isDark ? const Color(0xFF334155) : AppTheme.borderLight),
                                    width: isSel ? 2.5 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(av, style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildTextField(
                        label: "Nama Lengkap Siswa",
                        controller: _nameController,
                        hint: "Contoh: Budi Santoso",
                        icon: Icons.person_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tingkat Kelas",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white70 : AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedGrade,
                                      isExpanded: true,
                                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : AppTheme.textMain,
                                      ),
                                      items: _gradeOptions.map((g) {
                                        return DropdownMenuItem(value: g, child: Text(g));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedGrade = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              label: "Asal Sekolah",
                              controller: _schoolController,
                              hint: "SD Negeri 1 Madiun",
                              icon: Icons.school_rounded,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    _buildTextField(
                      label: "Email Siswa / Akun",
                      controller: _emailController,
                      hint: "siswa@sd1madiun.sch.id",
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Password Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kata Sandi",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_rounded, size: 20, color: AppTheme.danaBlue),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                size: 18,
                                color: AppTheme.textMuted,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            hintText: "Minimal 6 karakter",
                            hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppTheme.danaBlue, width: 1.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.danaBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _isRegister ? "Daftar Akun Baru 🚀" : "Masuk Sekarang 🎒",
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Demo Login Button
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Atau Masuk Demo",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white60 : AppTheme.textMuted,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Direct Demo Button (Tanpa Akun Tertentu Sesuai Permintaan)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E3A8A).withAlpha(120),
                                  const Color(0xFF4C1D95).withAlpha(120),
                                ]
                              : [
                                  const Color(0xFFE0F2FE),
                                  const Color(0xFFEDE9FE),
                                ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3B82F6) : const Color(0xFF93C5FD),
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading
                              ? null
                              : () => _handleDemoLogin(LocalCatalog.demoStudents.first),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("🎮", style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Text(
                                  "Masuk Mode Demo",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "✨ Demo",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),

      // Footer info
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "SD Negeri 1 Madiun",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text("•", style: TextStyle(color: isDark ? Colors.white38 : AppTheme.textMuted)),
          const SizedBox(width: 8),
          Text(
            "Kurikulum Merdeka 2026",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
    ],
  ),
),
),
),
);
}

  Widget _buildAuthTab({
    required String label,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF334155) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
              color: isActive
                  ? (isDark ? Colors.white : AppTheme.danaBlueDark)
                  : (isDark ? Colors.white60 : AppTheme.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppTheme.danaBlue),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.danaBlue, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
