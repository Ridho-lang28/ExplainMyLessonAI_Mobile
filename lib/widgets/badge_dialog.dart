import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../services/sound_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class BadgeDialog extends StatefulWidget {
  final BadgeModel badge;
  final bool isUnlocked;
  final VoidCallback onOpenChapter;

  const BadgeDialog({
    super.key,
    required this.badge,
    required this.isUnlocked,
    required this.onOpenChapter,
  });

  static void show(
    BuildContext context, {
    required BadgeModel badge,
    required bool isUnlocked,
    required VoidCallback onOpenChapter,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BadgeDialog(
        badge: badge,
        isUnlocked: isUnlocked,
        onOpenChapter: onOpenChapter,
      ),
    );
  }

  @override
  State<BadgeDialog> createState() => _BadgeDialogState();
}

class _BadgeDialogState extends State<BadgeDialog> {
  final TtsService _ttsService = TtsService();
  bool _isSpeaking = false;

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  void _toggleSpeakMotivation() async {
    SoundService.playClick();
    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _ttsService.speak(
        widget.badge.motivation,
        onComplete: () {
          if (mounted) setState(() => _isSpeaking = false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),

          // Big Badge Icon with glowing container
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: widget.isUnlocked
                  ? AppTheme.starGoldLight
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isUnlocked
                    ? AppTheme.starGold
                    : const Color(0xFFCBD5E1),
                width: 3,
              ),
              boxShadow: widget.isUnlocked
                  ? [
                      BoxShadow(
                        color: AppTheme.starGold.withAlpha(76),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.badge.icon,
                style: const TextStyle(fontSize: 44),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Status Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isUnlocked
                  ? AppTheme.successGreenLight
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isUnlocked
                    ? AppTheme.successGreen.withAlpha(76)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isUnlocked
                      ? Icons.check_circle_rounded
                      : Icons.lock_outline_rounded,
                  size: 16,
                  color: widget.isUnlocked
                      ? AppTheme.successGreen
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.isUnlocked ? "Lencana Diraih ⭐" : "Masih Terkunci 🔒",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: widget.isUnlocked
                        ? AppTheme.successGreen
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Badge Title
          Text(
            widget.badge.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.textMain,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            widget.badge.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),

          // Motivation Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.danaBlueLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.danaBlue.withAlpha(51)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text("🤖", style: TextStyle(fontSize: 18)),
                        SizedBox(width: 6),
                        Text(
                          "Pesan Semangat Robot Pintar:",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.danaBlueDark,
                          ),
                        ),
                      ],
                    ),
                    // TTS Button
                    GestureDetector(
                      onTap: _toggleSpeakMotivation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isSpeaking ? AppTheme.warningOrange : AppTheme.danaBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isSpeaking ? "Berhenti" : "Dengarkan",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "\"${widget.badge.motivation}\"",
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF0C4A6E),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // How to get info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Cara Meraih: ${widget.badge.howToGet}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                SoundService.playClick();
                Navigator.pop(context);
                widget.onOpenChapter();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danaBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Pelajari Materi Bab Ini 🚀",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
