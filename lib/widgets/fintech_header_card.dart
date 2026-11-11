import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

class FintechHeaderCard extends StatelessWidget {
  final Student student;
  final int points;
  final int rank;
  final int unreadNotifications;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenQuiz;
  final VoidCallback onOpenStudy;
  final VoidCallback onOpenBadges;
  final VoidCallback onOpenTts;
  final VoidCallback onOpenProfile;

  const FintechHeaderCard({
    super.key,
    required this.student,
    required this.points,
    required this.rank,
    this.unreadNotifications = 0,
    required this.onOpenNotifications,
    required this.onOpenQuiz,
    required this.onOpenStudy,
    required this.onOpenBadges,
    required this.onOpenTts,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Blue Top Header Container (Dana/GoPay style)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 48,
            bottom: 85,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF118EEA), Color(0xFF076DB9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Brand & Profile Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.starGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "SD PINTAR",
                              style: TextStyle(
                                color: Color(0xFF5A3E00),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            student.school,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            "ExplainMyLesson",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withAlpha(160),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF38BDF8),
                                width: 1.2,
                              ),
                            ),
                            child: const Text(
                              "EdTech AI",
                              style: TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Platform Pembelajaran Adaptif",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Notification Bell Button with Badge
                      GestureDetector(
                        onTap: onOpenNotifications,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(77),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              if (unreadNotifications > 0)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Center(
                                      child: Text(
                                        unreadNotifications > 9
                                            ? "9+"
                                            : "$unreadNotifications",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Profile Avatar
                      GestureDetector(
                        onTap: onOpenProfile,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 19,
                            backgroundColor: Colors.white,
                            child: Text(
                              student.avatar,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Student Greeting & Level Chip
              Row(
                children: [
                  Flexible(
                    child: Text(
                      "Halo, ${student.name.split(' ').first}! 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.military_tech_rounded,
                          color: AppTheme.starGold,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Peringkat #$rank",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Ample space so the floating card does NOT cover the greeting & title
              const SizedBox(height: 65),
            ],
          ),
        ),

        // Floating Balance & Quick Action Card (Dana/GoPay Signature)
        Positioned(
          left: 16,
          right: 16,
          bottom: -55,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D253C).withAlpha(30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                // Balance Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.starGold.withAlpha(100),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "⭐",
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Poin Prestasi Belajar",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "$points",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textMain,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Poin",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.danaBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreenLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppTheme.successGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Aktif Belajar",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.borderLight),
                const SizedBox(height: 12),
                // Quick Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: Icons.sports_esports_rounded,
                      color: const Color(0xFFFF6584),
                      label: "Kuis Seru",
                      onTap: onOpenQuiz,
                    ),
                    _buildActionButton(
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFF118EEA),
                      label: "Materi Bab",
                      onTap: onOpenStudy,
                    ),
                    _buildActionButton(
                      icon: Icons.military_tech_rounded,
                      color: const Color(0xFFFFB800),
                      label: "Lencana",
                      onTap: onOpenBadges,
                    ),
                    _buildActionButton(
                      icon: Icons.volume_up_rounded,
                      color: const Color(0xFF00B14F),
                      label: "Suara AI",
                      onTap: onOpenTts,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
