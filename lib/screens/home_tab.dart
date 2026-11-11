import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_rgb_background.dart';
import '../widgets/daily_mission_card.dart';
import '../widgets/notification_modal.dart';

class HomeTab extends StatelessWidget {
  final AppState state;
  final Function(int) onNavigateTab;

  const HomeTab({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final student = state.currentStudent;
    final isDark = state.isDarkMode;

    // Active module directly from teacher
    final activeModule = state.activeTeacherModule ?? state.currentChapter;

    return AnimatedRgbBackground(
      isDark: isDark,
      child: RefreshIndicator(
        color: AppTheme.danaBlue,
        onRefresh: () async {
          final ok = await state.syncCurriculumWithBackend();
          await state.syncTeacherPointReset();
          await state.fetchClassmates();
          await state.fetchNotifications();
          if (context.mounted && ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Data pembelajaran dari Guru berhasil disinkronkan! 📚✨"),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================================
              // 1. GREETING BANNER DENGAN BRANDING EXPLAINMYLESSON & EDTECH AI
              // ==============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E3A8A), const Color(0xFF1E293B)]
                        : [const Color(0xFF38BDF8), const Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3B82F6).withAlpha(128) : Colors.white,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : const Color(0xFF38BDF8)).withAlpha(60),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row Logo ExplainMyLesson & EdTech AI (Persis Foto Web) + Notification Bell
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo Buku Biru Rounded
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF38BDF8),
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withAlpha(80),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFF0284C7),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "ExplainMyLesson",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF60A5FA)),
                                    ),
                                    child: Text(
                                      "EdTech AI",
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                "Platform Pembelajaran Adaptif",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification Bell
                        GestureDetector(
                          onTap: () {
                            SoundService.playClick();
                            NotificationModal.show(context, state, onNavigateTab);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(isDark ? 40 : 60),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                if (state.unreadNotificationCount > 0)
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                      child: Center(
                                        child: Text(
                                          "${state.unreadNotificationCount}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tag Sekolah & Akun Siswa (Tanpa Tuntas & Tanpa Keaktifan 7 Hari)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
                            ),
                          ),
                          child: Text(
                            "🏫 ${student.school}",
                            style: TextStyle(
                              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A).withAlpha(200) : Colors.white.withAlpha(235),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF7DD3FC)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("👤 ", style: TextStyle(fontSize: 11)),
                                Text(
                                  "Akun: ",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white70 : const Color(0xFF1E3A8A),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    student.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Greeting Title & Backpack Emoji
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Hai, ${student.name}! 🎒",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Materi Pendidikan Kewarganegaraan (PKn) dan Bahasa Jawa terintegrasi Kurikulum Merdeka. Kumpulkan poin prestasi dan raih capaian belajar terbaik!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bottom Gamification Box (Total Poin Prestasi & Status Aktif)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A).withAlpha(160)
                            : Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withAlpha(90), width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Total Poin Prestasi
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Poin Prestasi 🪙",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDE047),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "🪙 ${state.totalPoints} POIN",
                                  style: const TextStyle(
                                    color: Color(0xFF78350F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Status Belajar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Text("🟢 ", style: TextStyle(fontSize: 9)),
                                Text(
                                  "Aktif Belajar",
                                  style: TextStyle(
                                    color: Color(0xFF065F46),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
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
              ),
              const SizedBox(height: 22),

            // ==============================================================
            // 2. MATERI PELAJARAN AKTIF DARI FOTO WEB (media_1794227279482_5ed1dd18.png)
            // ==============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE0F2FE),
                  width: 2,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Materi Pelajaran Aktif 📚
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Materi Pelajaran Aktif",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0369A1),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text("📚", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "🇮🇩 PKn & 🎭 Bahasa Jawa",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section subtitle row: Modul Pembelajaran Aktif & ✓ Tervalidasi Guru
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Modul Pembelajaran Aktif",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF6EE7B7)),
                        ),
                        child: Row(
                          children: [
                            const Text("🟢 ", style: TextStyle(fontSize: 9)),
                            Text(
                              "✓ Tervalidasi Guru",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Active Teacher Module Card (exact design from Image 2)
                  _buildTeacherModuleCard(context, activeModule, isActive: true, isDark: isDark),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ==============================================================
            // 3. MISI HARIAN SISWA (Diposisikan di Bawah Sesuai Permintaan)
            // ==============================================================
            DailyMissionCard(
              missions: state.dailyMissions,
              isDarkMode: isDark,
              onStartQuiz: () => onNavigateTab(2),
              onStartStudy: () => onNavigateTab(1),
              onListenAudio: () {
                onNavigateTab(1);
                state.ttsService.speak(activeModule.storyBody.first);
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

  // Teacher module card matching Image 2 perfectly
  Widget _buildTeacherModuleCard(
    BuildContext context,
    Chapter module, {
    required bool isActive,
    required bool isDark,
  }) {
    final isBjawa = module.subject == 'bjawa';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive
              ? const Color(0xFF3B82F6) // Blue 500
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isActive ? 2 : 1.2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withAlpha(isDark ? 50 : 25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            SoundService.playClick();
            state.selectActiveTeacherModule();
            onNavigateTab(1); // Jump to Ruang Belajar
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blue square emblem with Flag & Text (🇮🇩 PKN or 🎭 JAWA)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isBjawa
                              ? [const Color(0xFF059669), const Color(0xFF047857)]
                              : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isBjawa ? const Color(0xFF059669) : const Color(0xFF2563EB))
                                .withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isBjawa ? "🎭" : "🇮🇩",
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            isBjawa ? "JAWA" : "PKN",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // BAB Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  module.chapterCode.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  module.subjectLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            module.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),
                // Bottom row: Guru validation & Langsung Aktif pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text("👨‍🏫 ", style: TextStyle(fontSize: 12)),
                        Text(
                          "Guru: ${module.teacherValidatedAt ?? 'Baru saja divalidasi oleh Guru'}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        children: [
                          const Text("⚡ ", style: TextStyle(fontSize: 10)),
                          Text(
                            isActive ? "Langsung Aktif" : "Buka Modul",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
