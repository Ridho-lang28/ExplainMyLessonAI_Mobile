import 'package:flutter/material.dart';
import '../models/student.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class EditProfileDialog extends StatefulWidget {
  final Student student;
  final AppState state;

  const EditProfileDialog({
    super.key,
    required this.student,
    required this.state,
  });

  static Future<void> show(BuildContext context, AppState state) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditProfileDialog(
        student: state.currentStudent,
        state: state,
      ),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _schoolController;
  late TextEditingController _nisnController;
  late String _selectedGrade;
  late String _selectedAvatar;
  bool _isSaving = false;
  String? _errorMessage;

  final List<String> _avatarOptions = [
    "👦", "👧", "🧒", "🧑", "🎓", "🚀", "🌟", "🦁", "🎨", "🤖", "🐼", "🦊",
  ];

  final List<String> _gradeOptions = [
    "Kelas 3 SD",
    "Kelas 4 SD",
    "Kelas 5 SD",
    "Kelas 6 SD",
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameController = TextEditingController(text: s.name);
    _emailController = TextEditingController(text: s.email);
    _schoolController = TextEditingController(text: s.school);
    _nisnController = TextEditingController(text: s.nisn);
    _selectedGrade = _gradeOptions.contains(s.grade) ? s.grade : "Kelas 4 SD";
    _selectedAvatar = s.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _schoolController.dispose();
    _nisnController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    SoundService.playClick();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      SoundService.playWrong();
      setState(() => _errorMessage = "Nama lengkap siswa tidak boleh kosong ya! 😊");
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      SoundService.playWrong();
      setState(() => _errorMessage = "Format alamat email tidak valid (harus ada @).");
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    await widget.state.updateStudentProfile(
      name: name,
      email: email,
      avatar: _selectedAvatar,
      grade: _selectedGrade,
      school: _schoolController.text.trim().isEmpty ? "SD Negeri 1 Madiun" : _schoolController.text.trim(),
      nisn: _nisnController.text.trim().isEmpty ? "0084729102" : _nisnController.text.trim(),
    );

    SoundService.playCorrect();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    final isDark = widget.state.isDarkMode;

    return Container(
      margin: EdgeInsets.only(bottom: keyboardPadding),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3A8A) : AppTheme.danaBlueLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("✏️", style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Profil Siswa SD",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppTheme.textMain,
                          ),
                        ),
                        Text(
                          "Ubah nama, avatar karakter, dan info sekolah",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white70 : AppTheme.textMuted,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error Message if any
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRedLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.errorRed.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppTheme.errorRed, size: 18),
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
              const SizedBox(height: 14),
            ],

            // Avatar Picker Section
            Text(
              "Pilih Avatar Karakter Siswa:",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _avatarOptions.length,
                itemBuilder: (ctx, index) {
                  final av = _avatarOptions[index];
                  final isSelected = av == _selectedAvatar;

                  return GestureDetector(
                    onTap: () {
                      SoundService.playClick();
                      setState(() => _selectedAvatar = av);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF1E3A8A) : AppTheme.danaBlueLight)
                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.danaBlue
                              : (isDark ? const Color(0xFF334155) : AppTheme.borderLight),
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.danaBlue.withAlpha(60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(av, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Form Inputs
            _buildInputField(
              label: "Nama Lengkap Siswa",
              controller: _nameController,
              hint: "Masukkan nama lengkap siswa",
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            _buildInputField(
              label: "Email / Akun Belajar",
              controller: _emailController,
              hint: "contoh: siswa@sd1madiun.sch.id",
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: "NISN Siswa",
                    controller: _nisnController,
                    hint: "Nomor Induk Siswa",
                    icon: Icons.badge_outlined,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
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
                        height: 48,
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
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isDark ? const Color(0xFF93C5FD) : AppTheme.danaBlue,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            selectedItemBuilder: (BuildContext context) {
                              return _gradeOptions.map<Widget>((String item) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            items: _gradeOptions.map((g) {
                              return DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              );
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
              ],
            ),
            const SizedBox(height: 12),

            _buildInputField(
              label: "Nama Sekolah",
              controller: _schoolController,
              hint: "Nama SD tempat belajar",
              icon: Icons.school_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 22),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("💾", style: TextStyle(fontSize: 18)),
                label: Text(
                  _isSaving ? "Menyimpan..." : "Simpan Perubahan & Raih +10 ⭐",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danaBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
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
            color: isDark ? Colors.white : AppTheme.textMain,
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
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
              ),
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
