import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

void showLogoutConfirmDialog(BuildContext context, AppState state) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Text("🚪", style: TextStyle(fontSize: 24)),
          SizedBox(width: 8),
          Text(
            "Keluar dari Akun?",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.textMain),
          ),
        ],
      ),
      content: const Text(
        "Poin bintang dan seluruh progres belajarmu tersimpan aman di perangkat. Kamu bisa masuk kembali kapan saja untuk melanjutkan belajar!",
        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () {
            SoundService.playClick();
            Navigator.pop(ctx);
          },
          child: const Text(
            "Batal",
            style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            SoundService.playClick();
            Navigator.pop(ctx);
            state.logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text("Ya, Keluar Akun", style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
}
