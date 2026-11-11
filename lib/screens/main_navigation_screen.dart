import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_exit_quiz_dialog.dart';
import '../widgets/confirm_stop_tts_dialog.dart';
import 'badges_leaderboard_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'quiz_screen.dart';
import 'study_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  final AppState state;

  const MainNavigationScreen({super.key, required this.state});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<int> _navigationHistory = [0];

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    final reward = widget.state.consumeLatestReward();
    if (reward != null && reward.amount > 0 && mounted) {
      SoundService.playCoin();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(76),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: AppTheme.starGold, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppTheme.starGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text("⭐", style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "+${reward.amount} Poin Prestasi!",
                        style: const TextStyle(
                          color: AppTheme.starGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        reward.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _navigateToTab(int index) async {
    SoundService.playClick();
    if (index == _currentIndex) return;

    if (widget.state.ttsService.isPlaying) {
      final shouldStop = await showConfirmStopTtsDialog(context);
      if (!shouldStop) {
        return;
      }
      await widget.state.ttsService.stop();
    }

    if (!mounted) return;

    // Jika siswa sedang di tab Kuis dan kuis sedang aktif dikerjakan
    if (_currentIndex == 2 && widget.state.isQuizActive) {
      final shouldExit = await showConfirmExitQuizDialog(context, isDark: widget.state.isDarkMode);
      if (!shouldExit) {
        return;
      }
      widget.state.setQuizActive(false);
    }

    if (mounted) {
      setState(() {
        _currentIndex = index;
        if (index == 0) {
          _navigationHistory.clear();
          _navigationHistory.add(0);
        } else {
          if (_navigationHistory.isEmpty || _navigationHistory.last != index) {
            _navigationHistory.add(index);
          }
        }
      });
    }
  }

  Future<void> _goBack() async {
    SoundService.playClick();
    if (widget.state.ttsService.isPlaying) {
      final shouldStop = await showConfirmStopTtsDialog(context);
      if (!shouldStop) return;
      await widget.state.ttsService.stop();
    }
    if (!mounted) return;

    if (_currentIndex == 2 && widget.state.isQuizActive) {
      final shouldExit = await showConfirmExitQuizDialog(context, isDark: widget.state.isDarkMode);
      if (!shouldExit) return;
      widget.state.setQuizActive(false);
    }
    if (!mounted) return;

    if (_navigationHistory.length > 1) {
      setState(() {
        _navigationHistory.removeLast();
        _currentIndex = _navigationHistory.last;
      });
    } else if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
        _navigationHistory.clear();
        _navigationHistory.add(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;

    final screens = [
      HomeTab(state: state, onNavigateTab: _navigateToTab),
      StudyTab(state: state, onNavigateTab: _navigateToTab, onBack: _goBack),
      QuizScreen(state: state, onFinishQuiz: _goBack),
      BadgesLeaderboardTab(state: state, onNavigateTab: _navigateToTab, onBack: _goBack),
      ProfileTab(state: state, onNavigateTab: _navigateToTab, onBack: _goBack),
    ];

    return PopScope(
      canPop: _navigationHistory.length <= 1 && _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_navigationHistory.length > 1 || _currentIndex != 0) {
          await _goBack();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : AppTheme.background,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 60 : 15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFEDF2F7),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, "Beranda", isDark),
                  _buildNavItem(1, Icons.menu_book_rounded, "Belajar", isDark),
                  _buildNavItem(2, Icons.sports_esports_rounded, "Kuis", isDark),
                  _buildNavItem(3, Icons.military_tech_rounded, "Prestasi", isDark),
                  _buildNavItem(4, Icons.person_rounded, "Profil", isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        _navigateToTab(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A) : AppTheme.danaBlueLight)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? (isDark ? const Color(0xFF93C5FD) : AppTheme.danaBlue)
                  : (isDark ? const Color(0xFF64748B) : AppTheme.textMuted),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? const Color(0xFF93C5FD) : AppTheme.danaBlueDark)
                    : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
