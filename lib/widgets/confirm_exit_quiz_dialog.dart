import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Menampilkan dialog konfirmasi peringatan keluar kuis
/// Persis seperti konfirmasi di versi web (QuizClient.tsx):
/// "Mau keluar dari game kuis ini? Nanti koinnya ngga nambah lho!"
Future<bool> showConfirmExitQuizDialog(BuildContext context, {bool isDark = false}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text("🎮", style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Mau Keluar Game Kuis?",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppTheme.textMain,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        "Mau keluar dari game kuis ini? Nanti koinnya ngga nambah lho! ⭐\n\nKamu bisa lanjut menjawab untuk mendapatkan poin prestasi juara kelas.",
        style: TextStyle(
          fontSize: 13.5,
          color: isDark ? Colors.white70 : AppTheme.textSecondary,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF3B82F6) : AppTheme.danaBlue,
                    width: 1.8,
                  ),
                  backgroundColor: isDark ? const Color(0xFF1E3A8A).withAlpha(80) : const Color(0xFFEFF6FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Lanjut Kuis 🚀",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF93C5FD) : AppTheme.danaBlueDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Ya, Keluar",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  return result ?? false;
}
