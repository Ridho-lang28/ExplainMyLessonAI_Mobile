import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_rgb_background.dart';
import '../widgets/confirm_stop_tts_dialog.dart';

class StudyTab extends StatefulWidget {
  final AppState state;
  final Function(int) onNavigateTab;
  final VoidCallback? onBack;

  const StudyTab({
    super.key,
    required this.state,
    required this.onNavigateTab,
    this.onBack,
  });

  @override
  State<StudyTab> createState() => _StudyTabState();
}

class _StudyCardPalette {
  final Color lightBg;
  final Color lightBorder;
  final Color lightHeader;
  final List<Color> numberGradient;
  final Color lightAccent;
  final Color lightNumberShadow;

  const _StudyCardPalette({
    required this.lightBg,
    required this.lightBorder,
    required this.lightHeader,
    required this.numberGradient,
    required this.lightAccent,
    required this.lightNumberShadow,
  });
}

const List<_StudyCardPalette> _studyPalettes = [
  _StudyCardPalette(
    lightBg: Color(0xFFF0F9FF),
    lightBorder: Color(0xFFBAE6FD),
    lightHeader: Color(0xFF0369A1),
    numberGradient: [Color(0xFF38BDF8), Color(0xFF0284C7)],
    lightAccent: Color(0xFF0284C7),
    lightNumberShadow: Color(0xFF0284C7),
  ),
  _StudyCardPalette(
    lightBg: Color(0xFFF0FDF4),
    lightBorder: Color(0xFFA7F3D0),
    lightHeader: Color(0xFF047857),
    numberGradient: [Color(0xFF34D399), Color(0xFF059669)],
    lightAccent: Color(0xFF059669),
    lightNumberShadow: Color(0xFF059669),
  ),
  _StudyCardPalette(
    lightBg: Color(0xFFFFFBEB),
    lightBorder: Color(0xFFFDE68A),
    lightHeader: Color(0xFFB45309),
    numberGradient: [Color(0xFFFBBF24), Color(0xFFD97706)],
    lightAccent: Color(0xFFD97706),
    lightNumberShadow: Color(0xFFD97706),
  ),
  _StudyCardPalette(
    lightBg: Color(0xFFFAF5FF),
    lightBorder: Color(0xFFDDD6FE),
    lightHeader: Color(0xFF6D28D9),
    numberGradient: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    lightAccent: Color(0xFF7C3AED),
    lightNumberShadow: Color(0xFF7C3AED),
  ),
  _StudyCardPalette(
    lightBg: Color(0xFFFFF1F2),
    lightBorder: Color(0xFFFECDD3),
    lightHeader: Color(0xFFBE123C),
    numberGradient: [Color(0xFFFB7185), Color(0xFFE11D48)],
    lightAccent: Color(0xFFE11D48),
    lightNumberShadow: Color(0xFFE11D48),
  ),
  _StudyCardPalette(
    lightBg: Color(0xFFEEF2FF),
    lightBorder: Color(0xFFC7D2FE),
    lightHeader: Color(0xFF4338CA),
    numberGradient: [Color(0xFF818CF8), Color(0xFF4F46E5)],
    lightAccent: Color(0xFF4F46E5),
    lightNumberShadow: Color(0xFF4F46E5),
  ),
];

class _StudyTabState extends State<StudyTab> {
  String _selectedMode = 'cerita'; // 'cerita' | 'kuis'
  int _activeParagraphIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.state.ttsService.playingStateNotifier.addListener(_onTtsStateChange);
  }

  void _onTtsStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.state.ttsService.playingStateNotifier.removeListener(_onTtsStateChange);
    widget.state.ttsService.stop();
    super.dispose();
  }

  void _playAllStory() async {
    SoundService.playClick();
    final tts = widget.state.ttsService;
    if (tts.isPlaying) {
      await tts.stop();
      setState(() => _activeParagraphIndex = -1);
    } else {
      final chapter = widget.state.activeTeacherModule ?? widget.state.currentChapter;
      final fullText = "${chapter.title}. ${chapter.storyBody.join('. ')}";

      widget.state.completeMission(
        'listenedAudio',
        10,
        "Hebat! Kamu telah mendengarkan narasi suara AI (+10 ⭐)",
      );

      setState(() => _activeParagraphIndex = 0);
      await tts.speak(
        fullText,
        onComplete: () {
          if (mounted) setState(() => _activeParagraphIndex = -1);
        },
      );
    }
  }

  void _playSingleParagraph(int index, String text) async {
    SoundService.playClick();
    final tts = widget.state.ttsService;
    if (tts.isPlaying && _activeParagraphIndex == index) {
      await tts.stop();
      setState(() => _activeParagraphIndex = -1);
    } else {
      setState(() => _activeParagraphIndex = index);
      widget.state.completeMission('listenedAudio', 10);
      await tts.speak(
        text,
        onComplete: () {
          if (mounted) setState(() => _activeParagraphIndex = -1);
        },
      );
    }
  }

  Future<void> _showQuizReadyDialog(BuildContext context) async {
    final chapter = widget.state.activeTeacherModule ?? widget.state.currentChapter;
    final isDark = widget.state.isDarkMode;

    final ready = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withAlpha(100),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text("🎯", style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Siap Menjawab Kuis?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${chapter.chapterCode}: ${chapter.title}",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF0284C7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Uji pemahamanmu dari materi yang baru saja dipelajari. Dapatkan poin bintang emas dan rebut posisi tertinggi di Juara Kelas! ⭐",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withAlpha(100) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6EE7B7)),
              ),
              child: Row(
                children: [
                  const Text("💡", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tips AI: Jawab dengan tenang, ada petunjuk rahasia jika kamu ragu!",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    SoundService.playClick();
                    Navigator.pop(ctx, false);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    "Belajar Lagi 📖",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white60 : AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    SoundService.playClick();
                    Navigator.pop(ctx, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Siap, Mulai! 🚀",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (ready == true) {
      if (widget.state.ttsService.isPlaying) {
        await widget.state.ttsService.stop();
      }
      widget.onNavigateTab(2); // Jump to Quiz
    }
  }

  void _claimReadPoints() {
    SoundService.playCoin();
    final chapter = widget.state.activeTeacherModule ?? widget.state.currentChapter;
    widget.state.markChapterCompleted(chapter.id);
    widget.state.completeMission(
      'readSummary',
      10,
      "Luar biasa! Kamu telah membaca & memahami materi (+10 ⭐)",
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.state.activeTeacherModule ?? widget.state.currentChapter;
    final isPlaying = widget.state.ttsService.isPlaying;
    final readAlready = widget.state.dailyMissions.readSummary;
    final isDark = widget.state.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: "Kembali",
          onPressed: () async {
            SoundService.playClick();
            if (widget.state.ttsService.isPlaying) {
              final shouldStop = await showConfirmStopTtsDialog(context);
              if (!shouldStop) return;
              await widget.state.ttsService.stop();
            }
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              widget.onNavigateTab(0);
            }
          },
        ),
        title: const Text(
          "Ruang Belajar Siswa SD",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppTheme.danaBlue,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Dengarkan Semua",
            icon: Icon(
              isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
              color: isPlaying ? AppTheme.starGold : Colors.white,
            ),
            onPressed: _playAllStory,
          ),
        ],
      ),
      body: AnimatedRgbBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Module Status Banner
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6EE7B7)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Modul Pembelajaran Tervalidasi Guru",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                          ),
                        ),
                        Text(
                          "Materi resmi kurikulum disahkan pengajar: ${chapter.teacherValidatedAt ?? 'Baru saja divalidasi oleh Guru'}",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chapter Title Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withAlpha(64),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${chapter.subjectLabel} · ${chapter.chapterCode.toUpperCase()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        chapter.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    chapter.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chapter.shortDescription,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mode Selector: Ringkasan vs Kuis
            Row(
              children: [
                Expanded(
                  child: _buildModeButton(
                    id: 'cerita',
                    label: "Ringkasan & Pengamalan",
                    icon: "💡",
                    isSelected: _selectedMode == 'cerita',
                    isDark: isDark,
                    onTap: () {
                      SoundService.playClick();
                      setState(() => _selectedMode = 'cerita');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildModeButton(
                    id: 'kuis',
                    label: "Kuis Tantangan",
                    icon: "🎮",
                    isSelected: _selectedMode == 'kuis',
                    isDark: isDark,
                    onTap: () {
                      SoundService.playClick();
                      _showQuizReadyDialog(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // AI Audio Narration Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isPlaying
                    ? (isDark ? const Color(0xFF78350F) : AppTheme.warningOrangeLight)
                    : (isDark ? const Color(0xFF1E3A8A) : AppTheme.danaBlueLight),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isPlaying
                      ? AppTheme.warningOrange.withAlpha(102)
                      : (isDark ? const Color(0xFF3B82F6) : AppTheme.danaBlue.withAlpha(76)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isPlaying ? AppTheme.warningOrange : AppTheme.danaBlue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: _playAllStory,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPlaying ? "Robot AI Sedang Membaca..." : "Dengarkan Penjelasan AI",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isPlaying
                                ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFC2410C))
                                : (isDark ? const Color(0xFF93C5FD) : AppTheme.danaBlueDark),
                          ),
                        ),
                        Text(
                          isPlaying
                              ? "Tekan tombol stop bila ingin berhenti."
                              : "Dengarkan penjelasan suara ramah anak SD.",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Poin-Poin Penting Pelajaran",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textMain,
                  ),
                ),
                Text(
                  "${chapter.storyBody.length} Bahasan",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Paragraphs List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chapter.storyBody.length,
              itemBuilder: (ctx, index) {
                final paragraph = chapter.storyBody[index];
                final isThisSpeaking = isPlaying && _activeParagraphIndex == index;

                final parts = paragraph.split(':');
                final hasColon = parts.length > 1;
                final header = hasColon ? parts[0].trim() : "Poin ${index + 1}";
                final body = hasColon ? parts.sublist(1).join(':').trim() : paragraph;

                final palette = _studyPalettes[index % _studyPalettes.length];

                Color itemBg = isDark ? const Color(0xFF1E293B) : palette.lightBg;
                Color itemBorder = isDark ? palette.lightAccent.withAlpha(110) : palette.lightBorder;

                if (isThisSpeaking) {
                  itemBg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
                  itemBorder = AppTheme.starGold;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: itemBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: itemBorder,
                      width: isThisSpeaking ? 2.0 : 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : palette.lightAccent).withAlpha(isDark ? 50 : 25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                // Kotak Nomer Penuh Warna dengan Efek Gradien & Shadow
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [palette.lightAccent.withAlpha(160), palette.lightAccent]
                                          : palette.numberGradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDark ? Colors.black : palette.lightNumberShadow).withAlpha(80),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          header,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? Colors.white : palette.lightHeader,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            iconSize: 22,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isThisSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                              color: isThisSpeaking
                                  ? AppTheme.starGold
                                  : (isDark ? palette.lightAccent : palette.lightHeader),
                            ),
                            tooltip: "Dengarkan bagian ini",
                            onPressed: () => _playSingleParagraph(index, paragraph),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.55,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Claim Points / Finished Reading Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFFDE68A),
                  width: 1.6,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("🌟", style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selesaikan Pemahaman Modul",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppTheme.textMain,
                              ),
                            ),
                            Text(
                              readAlready
                                  ? "Misi membaca sudah diselesaikan (+10 ⭐ diraih)"
                                  : "Tekan tombol di bawah untuk klaim 10 Poin Prestasi!",
                              style: TextStyle(
                                fontSize: 12,
                                color: readAlready ? AppTheme.successGreen : (isDark ? Colors.white60 : AppTheme.textSecondary),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: readAlready ? null : _claimReadPoints,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: readAlready
                            ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                            : AppTheme.danaBlue,
                        foregroundColor: readAlready
                            ? (isDark ? Colors.white38 : AppTheme.textMuted)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        readAlready ? "Materi Sudah Dipahami ✅" : "Klaim +10 Poin Prestasi ⭐",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Start Quiz Button with Validation Dialog
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showQuizReadyDialog(context),
                icon: const Text("🎮", style: TextStyle(fontSize: 18)),
                label: const Text(
                  "Uji Pemahaman dengan Kuis Seru →",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D28D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildModeButton({
    required String id,
    required String label,
    required String icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (id == 'cerita' ? const Color(0xFF0284C7) : const Color(0xFF7C3AED))
                : (isDark ? const Color(0xFF334155) : AppTheme.borderLight),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (id == 'cerita' ? const Color(0xFF0284C7) : const Color(0xFF7C3AED))
                        .withAlpha(isDark ? 60 : 40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? const Color(0xFF93C5FD) : AppTheme.danaBlueDark)
                      : (isDark ? Colors.white60 : AppTheme.textSecondary),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
