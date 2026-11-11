import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_rgb_background.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/logout_dialog.dart';

class ProfileTab extends StatelessWidget {
  final AppState state;
  final Function(int) onNavigateTab;
  final VoidCallback? onBack;

  const ProfileTab({
    super.key,
    required this.state,
    required this.onNavigateTab,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final student = state.currentStudent;
    final weakness = student.weakness;
    final isDark = state.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: "Kembali",
          onPressed: () {
            SoundService.playClick();
            if (onBack != null) {
              onBack!();
            } else {
              onNavigateTab(0);
            }
          },
        ),
        title: const Text(
          "Profil Siswa SD",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppTheme.danaBlue,
        elevation: 0,
      ),
      body: AnimatedRgbBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
          children: [
            // Student Card Header (Interactive with Edit Avatar & Edit Profile Button)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                ),
              ),
              child: Column(
                children: [
                  // Tap avatar to edit profile
                  GestureDetector(
                    onTap: () {
                      SoundService.playClick();
                      EditProfileDialog.show(context, state);
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: isDark ? const Color(0xFF334155) : AppTheme.danaBlueLight,
                          child: Text(student.avatar, style: const TextStyle(fontSize: 46)),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.danaBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    student.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppTheme.textMain,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${student.grade} • ${student.school}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "NISN: ${student.nisn} • ${student.email}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Edit Profile Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SoundService.playClick();
                        EditProfileDialog.show(context, state);
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 20),
                      label: const Text(
                        "Edit Profil Siswa",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.danaBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Total Poin",
                    value: "${state.totalPoints} ⭐",
                    color: AppTheme.starGold,
                    isDarkMode: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "Peringkat Kelas",
                    value: "#${state.userRank}",
                    color: AppTheme.danaBlue,
                    isDarkMode: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "Misi Tuntas",
                    value: "${state.dailyMissions.completedCount}/5",
                    color: AppTheme.successGreen,
                    isDarkMode: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Diagnostik Belajar & Remedial Card
            if (weakness != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppTheme.cardShadow,
                  border: Border.all(
                    color: weakness.isRemedial
                        ? AppTheme.warningOrange.withAlpha(128)
                        : AppTheme.successGreen.withAlpha(128),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              weakness.isRemedial ? "⚠️" : "✅",
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Diagnostik Pemahaman",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppTheme.textMain,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: weakness.isRemedial
                                ? AppTheme.warningOrangeLight
                                : AppTheme.successGreenLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            weakness.isRemedial ? "Perlu Pengayaan" : "Tuntas Belajar",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: weakness.isRemedial
                                  ? AppTheme.warningOrange
                                  : AppTheme.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Materi: ${weakness.chapterName} (${weakness.subject})",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Skor Pemahaman Terakhir: ${weakness.score} / ${weakness.outOf}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        weakness.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onNavigateTab(2), // go to quiz
                        style: ElevatedButton.styleFrom(
                          backgroundColor: weakness.isRemedial
                              ? AppTheme.warningOrange
                              : AppTheme.danaBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          weakness.isRemedial
                              ? "Mulai Latihan Kuis Remedial"
                              : "Asah Pemahaman Lebih Dalam",
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // PENGATURAN TAMPILAN: MODE GELAP (DARK MODE SWITCH - Persis seperti di Web)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(isDark ? "🌙" : "☀️", style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        "Pengaturan Tampilan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textMain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mode Gelap (Dark Mode)",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppTheme.textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDark
                                  ? "Tema gelap aktif: nyaman untuk mata saat malam 🌙"
                                  : "Tema terang aktif: ceria & cerah untuk belajar ☀️",
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: isDark,
                        activeTrackColor: const Color(0xFF10B981),
                        activeThumbColor: Colors.white,
                        onChanged: (val) {
                          SoundService.playClick();
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          state.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sound & Voice Settings
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Suara & Narasi Robot AI",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Text("🔊", style: TextStyle(fontSize: 24)),
                    title: Text(
                      "Uji Suara Robot Pintar",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.textMain,
                      ),
                    ),
                    subtitle: Text(
                      "Membacakan materi dengan intonasi ceria ramah anak",
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : AppTheme.textSecondary,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        SoundService.playClick();
                        state.ttsService.speak(
                          "Halo ${student.name.split(' ').first}! Aku Robot Pintar ExplainMyLesson. Selamat belajar bersama ya!",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.danaBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Coba Suara", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),


            // LOGOUT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF450A0A).withAlpha(128) : AppTheme.errorRedLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.errorRed.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Keluar dari Akun Siswa",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Keluar dari sesi belajar ${student.name} pada perangkat ini.",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SoundService.playClick();
                        showLogoutConfirmDialog(context, state);
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        "Keluar Sekarang",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    bool isDarkMode = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF334155) : AppTheme.borderLight,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white60 : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
