import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../models/student.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_rgb_background.dart';
import '../widgets/badge_dialog.dart';
import '../widgets/subject_tabs.dart';

class BadgesLeaderboardTab extends StatefulWidget {
  final AppState state;
  final Function(int) onNavigateTab;
  final VoidCallback? onBack;

  const BadgesLeaderboardTab({
    super.key,
    required this.state,
    required this.onNavigateTab,
    this.onBack,
  });

  @override
  State<BadgesLeaderboardTab> createState() => _BadgesLeaderboardTabState();
}

class _BadgesLeaderboardTabState extends State<BadgesLeaderboardTab> {
  int _activeSegment = 0; // 0 = Lencana, 1 = Juara Kelas

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: "Kembali",
          onPressed: () {
            SoundService.playClick();
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              widget.onNavigateTab(0);
            }
          },
        ),
        title: const Text(
          "Prestasi & Juara Kelas",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppTheme.danaBlue,
        elevation: 0,
      ),
      body: AnimatedRgbBackground(
        isDark: isDark,
        child: Column(
          children: [
            // Segment Switcher: Lencana Prestasi vs Juara Kelas
            Container(
              color: isDark ? const Color(0xFF1E293B) : AppTheme.danaBlue,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(isDark ? 80 : 38),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSegmentButton(
                        index: 0,
                        label: "Lencana Prestasi",
                        icon: "🏆",
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildSegmentButton(
                        index: 1,
                        label: "Juara Kelas",
                        icon: "👑",
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Body Content based on segment
            Expanded(
              child: _activeSegment == 0
                  ? _buildBadgesView(isDark)
                  : _buildLeaderboardView(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String label,
    required String icon,
    required bool isDark,
  }) {
    final isActive = _activeSegment == index;

    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        setState(() => _activeSegment = index);
      },
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
                    color: Colors.black.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
                color: isActive
                    ? (isDark ? Colors.white : AppTheme.danaBlueDark)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: LENCANA PRESTASI (Bentuk Memanjang & Menyesuaikan Materi Input Guru)
  // ===========================================================================
  Widget _buildBadgesView(bool isDark) {
    final allBadges = widget.state.currentSubjectBadges;
    final totalPoints = widget.state.totalPoints;
    final missions = widget.state.dailyMissions;
    final completedChapters = widget.state.completedChapterIds;

    // Filter HANYA lencana yang sudah benar-benar diraih / diselesaikan oleh siswa (Persis web: earnedBadges)
    final earnedBadges = allBadges.where((badge) {
      return badge.isUnlocked(
        totalPoints,
        missions.completedQuiz,
        missions.quizLevel1,
        completedChapters,
      );
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubjectTabs(
            activeSubject: widget.state.activeSubject,
            onSelectSubject: (s) => widget.state.setSubject(s),
          ),
          const SizedBox(height: 16),

          // Total badges count card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF78350F), const Color(0xFF451A03)]
                    : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.starGold.withAlpha(100)),
            ),
            child: Row(
              children: [
                const Text("⭐", style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lencana Pembelajaran Diraih (${earnedBadges.length} Lencana)",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Lencana otomatis menyesuaikan materi yang diselesaikan dan tervalidasi oleh Guru.",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFFB45309).withAlpha(230),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // List Lencana Memanjang ke Samping & Bawah (Bukan Kotak-Kotak Sempit)
          if (earnedBadges.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.borderLight),
              ),
              child: const Center(
                child: Text(
                  "Selesaikan bab & kuis untuk meraih lencana! 🌟",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: earnedBadges.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, index) {
                final badge = earnedBadges[index];
                return _buildElongatedBadgeCard(badge, true, isDark);
              },
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Kartu Lencana Memanjang (Horizontal Wide Card dengan Ruang Bawah Menyesuaikan)
  Widget _buildElongatedBadgeCard(BadgeModel badge, bool isUnlocked, bool isDark) {
    final isCurrentActive = badge.targetChapterId != null &&
        (badge.targetChapterId == widget.state.activeTeacherModule?.id ||
            badge.targetChapterId == widget.state.currentChapter.id);

    return InkWell(
      onTap: () {
        if (isUnlocked) {
          SoundService.playBadgeFanfare();
        } else {
          SoundService.playClick();
        }
        BadgeDialog.show(
          context,
          badge: badge,
          isUnlocked: isUnlocked,
          onOpenChapter: () {
            if (badge.targetChapterId != null) {
              final found = widget.state.currentSubjectChapters.firstWhere(
                (c) => c.id == badge.targetChapterId,
                orElse: () => widget.state.currentChapter,
              );
              widget.state.selectChapter(found);
              widget.onNavigateTab(1);
            }
          },
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isCurrentActive
                ? const Color(0xFFF59E0B) // Amber highlight
                : (isUnlocked
                    ? (isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC))
                    : (isDark ? const Color(0xFF334155) : AppTheme.borderLight)),
            width: isCurrentActive ? 2.2 : 1.2,
          ),
          boxShadow: isCurrentActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withAlpha(50),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row Atas: Icon Bulat Emas, Judul & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      badge.icon,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (badge.chapterCode != null && badge.chapterCode!.isNotEmpty)
                                  ? badge.chapterCode!
                                  : (badge.subject == 'pkn' ? 'PKn SD' : 'B. Jawa'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF0284C7),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCurrentActive
                                  ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
                                  : (isUnlocked
                                      ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isCurrentActive
                                  ? "Aktif Guru ⚡"
                                  : (isUnlocked ? "Diraih ⭐" : "Terkunci 🔒"),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isCurrentActive
                                    ? const Color(0xFFD97706)
                                    : (isUnlocked
                                        ? const Color(0xFF059669)
                                        : (isDark ? Colors.white38 : AppTheme.textMuted)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppTheme.textMain,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Ringkasan Deskripsi Lencana
            Text(
              badge.description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : AppTheme.textSecondary,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Cara Meraih Box Mini
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  const Text("💡", style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      badge.howToGet,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : const Color(0xFF475569),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tombol Aksi Memanjang: 📖 Pelajari & 🔊 Motivasi
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (badge.targetChapterId != null) {
                        final found = widget.state.currentSubjectChapters.firstWhere(
                          (c) => c.id == badge.targetChapterId,
                          orElse: () => widget.state.currentChapter,
                        );
                        widget.state.selectChapter(found);
                      }
                      widget.onNavigateTab(1); // Jump to Belajar Tab
                    },
                    icon: const Text("📖", style: TextStyle(fontSize: 13)),
                    label: const Text(
                      "Pelajari Bab",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final tts = widget.state.ttsService;
                      final motivationText = badge.motivation.isNotEmpty
                          ? badge.motivation
                          : "Hebat sekali! Terus semangat belajar dan raih cita-citamu setinggi bintang!";
                      tts.speak(motivationText);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Text("🔊 ", style: TextStyle(fontSize: 16)),
                              Expanded(
                                child: Text(
                                  motivationText,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF1E3A8A),
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    icon: const Text("🔊", style: TextStyle(fontSize: 13)),
                    label: const Text(
                      "Motivasi AI",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                      backgroundColor: isDark ? const Color(0xFF78350F).withAlpha(60) : const Color(0xFFFEF3C7),
                      side: BorderSide(
                        color: isDark ? const Color(0xFFB45309) : const Color(0xFFFCD34D),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 2: JUARA KELAS (Persis Seperti Foto Web media_1794228931245_61420156.png)
  // ===========================================================================
  Widget _buildLeaderboardView(bool isDark) {
    final board = widget.state.leaderboard;
    final isReset = widget.state.isRankingEmpty;
    final userRank = widget.state.userRank;
    final totalPoints = widget.state.totalPoints;

    final firstPlace = board.isNotEmpty ? board[0] : null;
    final secondPlace = board.length > 1 ? board[1] : null;
    final thirdPlace = board.length > 2 ? board[2] : null;
    final remainingPlaces = board.length > 3 ? board.sublist(3) : <LeaderboardEntry>[];

    return RefreshIndicator(
      color: AppTheme.danaBlue,
      onRefresh: () async {
        await widget.state.syncTeacherPointReset();
        await widget.state.fetchClassmates();
        await widget.state.fetchNotifications();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // 4. TANGGA JUARA KELAS 4A (PERSIS DESAIN WEB PelajarDashboardPage.tsx)
            // =================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF3B0764) : const Color(0xFFE9D5FF),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC084FC).withAlpha(isDark ? 30 : 25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Baris: Ikon 🏆 + Judul + Pill Status Peringkat Siswa
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFBBF24), Color(0xFFEAB308)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEAB308).withAlpha(80),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text("🏆", style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tangga Juara Kelas 4A 🏆",
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF3B0764),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Tiga Siswa Teratas Peraih Poin Prestasi Tertinggi Pekan Ini",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Pill Peringkat Siswa di Sisi Kanan (Persis Web)
                      if (isReset)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Text(
                            "⚠️ Poin Di-Reset",
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF78350F),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF3B0764) : const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE9D5FF)),
                          ),
                          child: Text(
                            userRank <= 3
                                ? "🎉 Kamu Juara $userRank!"
                                : "Peringkat: ke-$userRank ($totalPoints Poin)",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF6B21A8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    thickness: 1.2,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3E8FF),
                  ),
                  const SizedBox(height: 14),

                  // Jika Poin Di-Reset Guru: Tampilkan Notifikasi Khusus (Persis Web)
                  if (isReset) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFF59E0B),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text("📢", style: TextStyle(fontSize: 26)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Poin Telah Di-Reset oleh Guru 🔄",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF78350F),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Bapak/Ibu Guru telah mereset seluruh perolehan poin dan tangga juara kelas untuk memulai periode baru. Tangga juara akan otomatis tampil kembali setelah kamu menyelesaikan kuis dan misi harian! 🚀",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF92400E),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: () => widget.onNavigateTab(1),
                            icon: const Text("🎮", style: TextStyle(fontSize: 14)),
                            label: const Text(
                              "Mulai Kuis & Kumpulkan Poin Baru",
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Podium Horizontal 3 Besar (Persis Web PelajarDashboardPage.tsx)
                    _buildWebHorizontalPodium(firstPlace, secondPlace, thirdPlace, isDark),
                  ],
                ],
              ),
            ),

            // Peringkat 4 dan seterusnya di bawah podium
            if (remainingPlaces.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A8A) : AppTheme.danaBlueLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text("🌟", style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Peringkat Siswa Lainnya (Nomor 4 dan Seterusnya)",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: remainingPlaces.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final entry = remainingPlaces[index];
                  return _buildExactLeaderboardCard(entry, isDark);
                },
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Podium Horizontal 3 Besar (Persis PelajarDashboardPage.tsx: Juara 2 Kiri, Juara 1 Tengah Tertinggi, Juara 3 Kanan)
  Widget _buildWebHorizontalPodium(
    LeaderboardEntry? first,
    LeaderboardEntry? second,
    LeaderboardEntry? third,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // JUARA 2 (PERAK) - Kiri
          Expanded(
            flex: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWebPodiumStudentBox(
                  entry: second,
                  medal: "🥈",
                  isFirst: false,
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 85,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF475569), Color(0xFF334155)]
                          : const [Color(0xFFCBD5E1), Color(0xFFE2E8F0)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "2",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      Text(
                        "PERAK",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // JUARA 1 (EMAS) - Tengah Lebih Tinggi + Mahkota 👑
          Expanded(
            flex: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    "👑",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                _buildWebPodiumStudentBox(
                  entry: first,
                  medal: "🥇",
                  isFirst: true,
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFFB45309), Color(0xFFD97706)]
                          : const [Color(0xFFFBBF24), Color(0xFFFDE047)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: const Border(
                      top: BorderSide(
                        color: Color(0xFFFEF08A),
                        width: 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "1",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF78350F),
                        ),
                      ),
                      Text(
                        "JUARA 1 ⭐",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // JUARA 3 (PERUNGGU) - Kanan
          Expanded(
            flex: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWebPodiumStudentBox(
                  entry: third,
                  medal: "🥉",
                  isFirst: false,
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF7C2D12), Color(0xFF9A3412)]
                          : const [Color(0xFFEA580C), Color(0xFFFB923C)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: const Border(
                      top: BorderSide(
                        color: Color(0xFFFDBA74),
                        width: 4,
                      ),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "3",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "PERUNGGU",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Colors.white,
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
    );
  }

  /// Kotak Identitas Siswa di Atas Tiang Podium (Persis Web)
  Widget _buildWebPodiumStudentBox({
    required LeaderboardEntry? entry,
    required String medal,
    required bool isFirst,
    required bool isDark,
  }) {
    final hasEntry = entry != null;
    final isCurrentUser = entry?.isUser ?? false;

    Color boxBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    Color boxBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    double borderWidth = 2.0;

    if (isCurrentUser) {
      boxBg = isDark ? const Color(0xFF78350F).withAlpha(140) : const Color(0xFFFEF3C7);
      boxBorder = const Color(0xFFF59E0B);
      borderWidth = 2.5;
    } else if (isFirst) {
      boxBg = isDark ? const Color(0xFF78350F).withAlpha(80) : const Color(0xFFFFFBEB);
      boxBorder = const Color(0xFFFCD34D);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: isFirst ? 8 : 6),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: boxBorder, width: borderWidth),
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(medal, style: TextStyle(fontSize: isFirst ? 28 : 22)),
          const SizedBox(height: 2),
          Text(
            hasEntry ? entry.name.split(' ').first : "-",
            style: TextStyle(
              fontSize: isFirst ? 11.5 : 10.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: isFirst
                  ? const Color(0xFFFDE68A)
                  : (isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              hasEntry ? "🪙 ${entry.points}" : "🪙 0",
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: isFirst
                    ? const Color(0xFF78350F)
                    : (isDark ? Colors.white70 : const Color(0xFF334155)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  /// Kartu Juara Kelas yang Persis dengan Screenshot Web
  Widget _buildExactLeaderboardCard(LeaderboardEntry entry, bool isDark) {
    final isCurrentUser = entry.isUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? (isDark ? const Color(0xFF1E3A8A).withAlpha(128) : const Color(0xFFEFF6FF))
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentUser
              ? (isDark ? const Color(0xFF3B82F6) : const Color(0xFFBFDBFE))
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isCurrentUser ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circle Nomor Urut (1, 2, 3 Soft Cream Amber; 4 dst Soft Blue)
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: entry.rank <= 3
                  ? (isDark ? const Color(0xFF78350F).withAlpha(120) : const Color(0xFFFFFBEB))
                  : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${entry.rank}",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: entry.rank <= 3
                      ? const Color(0xFFD97706)
                      : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Avatar Siswa
          Text(
            entry.avatar,
            style: const TextStyle(fontSize: 26),
          ),
          const SizedBox(width: 14),

          // Nama Siswa (Dengan (Kamu) jika akun aktif)
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isCurrentUser
                    ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8))
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Total Poin Bintang Kuning di Kanan (⭐ 360 Poin)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("⭐", style: TextStyle(fontSize: 15)),
              const SizedBox(width: 4),
              Text(
                "${entry.points} Poin",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
