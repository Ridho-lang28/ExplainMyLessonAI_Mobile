import 'package:flutter/material.dart';
import '../models/daily_mission.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class DailyMissionCard extends StatelessWidget {
  final DailyMissions missions;
  final VoidCallback onStartQuiz;
  final VoidCallback onStartStudy;
  final VoidCallback onListenAudio;
  final bool isDarkMode;

  const DailyMissionCard({
    super.key,
    required this.missions,
    required this.onStartQuiz,
    required this.onStartStudy,
    required this.onListenAudio,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDarkMode ? const Color(0xFF334155) : AppTheme.borderLight;
    final titleColor = isDarkMode ? Colors.white : AppTheme.textMain;
    final subtitleColor = isDarkMode ? Colors.white70 : AppTheme.textSecondary;
    final progressBg = isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF78350F) : AppTheme.warningOrangeLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("🎯", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Misi Harian Siswa",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      Text(
                        "${missions.completedCount} dari 5 misi terselesaikan",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: missions.completedCount == 5
                      ? (isDarkMode ? const Color(0xFF065F46) : AppTheme.successGreenLight)
                      : (isDarkMode ? const Color(0xFF1E3A8A) : AppTheme.danaBlueLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${missions.progressPercentInt}%",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: missions.completedCount == 5
                        ? (isDarkMode ? const Color(0xFF6EE7B7) : AppTheme.successGreen)
                        : (isDarkMode ? const Color(0xFF93C5FD) : AppTheme.danaBlue),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: missions.progressPercent,
              minHeight: 10,
              backgroundColor: progressBg,
              valueColor: AlwaysStoppedAnimation<Color>(
                missions.completedCount == 5
                    ? AppTheme.successGreen
                    : AppTheme.danaBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Mission Items (Sesuai 5 Misi Harian di Web)
          _buildMissionItem(
            title: "Memahami Materi yang Disampaikan 📖",
            reward: "+10 ⭐",
            isDone: missions.readSummary,
            onTap: onStartStudy,
          ),
          _buildMissionItem(
            title: "Mendengarkan Penjelasan Materi 🎧",
            reward: "+10 ⭐",
            isDone: missions.listenedAudio,
            onTap: onListenAudio,
          ),
          _buildMissionItem(
            title: "Taklukkan Kuis Tingkat 1 🎮",
            reward: "+10 ⭐",
            isDone: missions.quizLevel1,
            onTap: onStartQuiz,
          ),
          _buildMissionItem(
            title: "Taklukkan Kuis Tingkat 2 ⚡",
            reward: "+20 ⭐",
            isDone: missions.quizLevel2,
            onTap: onStartQuiz,
          ),
          _buildMissionItem(
            title: "Taklukkan Kuis Tingkat 3 🏆",
            reward: "+30 ⭐",
            isDone: missions.quizLevel3 || missions.completedQuiz,
            onTap: onStartQuiz,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionItem({
    required String title,
    required String reward,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    final itemBg = isDone
        ? (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC))
        : Colors.transparent;
    final itemBorder = isDone
        ? (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
        : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFEDF2F7));
    final textColor = isDarkMode ? Colors.white : AppTheme.textMain;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          SoundService.playClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: itemBorder),
          ),
          child: Row(
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isDone ? AppTheme.successGreen : (isDarkMode ? Colors.white38 : AppTheme.textMuted),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDone
                      ? (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                      : (isDarkMode ? const Color(0xFF78350F) : AppTheme.starGoldLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reward,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDone
                        ? (isDarkMode ? Colors.white60 : AppTheme.textSecondary)
                        : (isDarkMode ? const Color(0xFFFCD34D) : const Color(0xFFB45309)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
