import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Menampilkan dialog konfirmasi untuk mematikan audio penjelasan AI
/// saat siswa ingin berpindah halaman atau meninggalkan ruang belajar.
Future<bool> showConfirmStopTtsDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.volume_off_rounded,
              color: Color(0xFFD97706),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Matikan Penjelasan AI?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMain,
              ),
            ),
          ),
        ],
      ),
      content: const Text(
        "Suara penjelasan AI masih sedang dibacakan. Apakah kamu ingin mematikan suara penjelasan AI sebelum berpindah halaman?",
        style: TextStyle(
          fontSize: 13,
          color: AppTheme.textSecondary,
          height: 1.5,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppTheme.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Tetap Dengarkan",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danaBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Matikan & Pindah",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
