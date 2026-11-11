import 'package:flutter/material.dart';
import '../data/local_catalog.dart';
import '../models/quiz.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_rgb_background.dart';
import '../widgets/confirm_exit_quiz_dialog.dart';

class QuizScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onFinishQuiz;

  const QuizScreen({
    super.key,
    required this.state,
    required this.onFinishQuiz,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int? _selectedOption;
  bool _showHint = false;
  String? _feedbackMessage;
  String _answerStatus = 'idle'; // 'idle' | 'correct' | 'wrong'
  bool _isSubmitting = false;
  bool _isLoadingQuestions = true;
  bool _hasStarted = false; // Status apakah kuis sudah di-start

  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    widget.state.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (!widget.state.isQuizActive && _hasStarted && mounted) {
      setState(() {
        _hasStarted = false;
        _selectedOption = null;
        _feedbackMessage = null;
        _answerStatus = 'idle';
      });
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChange);
    widget.state.setQuizActive(false);
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoadingQuestions = true);

    final activeMod = widget.state.activeTeacherModule ?? widget.state.currentChapter;
    if (activeMod.customQuizQuestions != null && activeMod.customQuizQuestions!.isNotEmpty) {
      final firstQuestions = activeMod.customQuizQuestions!.values.firstWhere(
        (list) => list.isNotEmpty,
        orElse: () => [],
      );
      if (firstQuestions.isNotEmpty) {
        setState(() {
          _questions = firstQuestions;
          _questionIndex = 0;
          _selectedOption = null;
          _showHint = false;
          _feedbackMessage = null;
          _answerStatus = 'idle';
          _isSubmitting = false;
          _isLoadingQuestions = false;
        });
        return;
      }
    }

    final questions = await ApiService.fetchQuizQuestions(1);
    setState(() {
      _questions = questions.isNotEmpty
          ? questions
          : (LocalCatalog.quizQuestions[1] ?? []);
      _questionIndex = 0;
      _selectedOption = null;
      _showHint = false;
      _feedbackMessage = null;
      _answerStatus = 'idle';
      _isSubmitting = false;
      _isLoadingQuestions = false;
    });
  }

  void _handleSubmitAnswer() {
    if (_questions.isEmpty || _isSubmitting) return;

    if (_selectedOption == null) {
      SoundService.playWrong();
      setState(() {
        _feedbackMessage = "Pilih jawabanmu dulu ya! 😊";
      });
      return;
    }

    final currentQ = _questions[_questionIndex];
    final isCorrect = _selectedOption == currentQ.correctOption;

    if (isCorrect) {
      SoundService.playCorrect();
      SoundService.playCoin();
    } else {
      SoundService.playWrong();
    }

    setState(() {
      _isSubmitting = true;
      _answerStatus = isCorrect ? 'correct' : 'wrong';
      _feedbackMessage = isCorrect
          ? "🎉 Hebat Banget! Jawabanmu Benar! +10 Poin Prestasi ⭐"
          : "💪 Belum tepat, tidak apa-apa! Simak petunjuk rahasia dan terus semangat! ✨";
    });

    if (isCorrect) {
      widget.state.addPoints(10);
      if (_questionIndex <= 1) {
        widget.state.completeMission('quizLevel1', 10);
      } else if (_questionIndex <= 3) {
        widget.state.completeMission('quizLevel2', 20);
      } else {
        widget.state.completeMission('quizLevel3', 30);
      }
    }

    Future.delayed(Duration(milliseconds: isCorrect ? 1400 : 1600), () {
      if (!mounted) return;

      final nextIndex = _questionIndex + 1;
      if (nextIndex >= _questions.length) {
        _handleQuizCompleted();
      } else {
        setState(() {
          _questionIndex = nextIndex;
          _selectedOption = null;
          _showHint = false;
          _feedbackMessage = null;
          _answerStatus = 'idle';
          _isSubmitting = false;
        });
      }
    });
  }

  void _handleQuizCompleted() {
    SoundService.playBadgeFanfare();
    widget.state.setQuizActive(false);
    final activeMod = widget.state.activeTeacherModule ?? widget.state.currentChapter;
    widget.state.markChapterCompleted(activeMod.id);
    // Menuntaskan seluruh misi harian (Memahami Materi, Audio AI, dan Kuis)
    widget.state.completeMission('readSummary', 10);
    widget.state.completeMission('listenedAudio', 10);
    widget.state.completeMission('quizLevel1', 10);
    widget.state.completeMission('quizLevel2', 20);
    widget.state.completeMission('quizLevel3', 30);
    widget.state.completeMission('completedQuiz', 20, "Juara! Seluruh Soal Kuis Selesai! +20 Poin 🏆");
    _showGrandChampionDialog();
  }

  void _showGrandChampionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Juara Hebat Ksatria Pintar! 🏆", style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("👑", style: TextStyle(fontSize: 54)),
            const SizedBox(height: 12),
            Text(
              "Wah, kamu Hebat Sekali! 🎉 Seluruh Soal Kuis Berhasil Dituntaskan! Kamu sekarang punya ${widget.state.totalPoints} Poin Prestasi! 🌟",
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              SoundService.playClick();
              Navigator.pop(ctx);
              setState(() {
                _hasStarted = false;
                _questionIndex = 0;
                _selectedOption = null;
                _feedbackMessage = null;
                _answerStatus = 'idle';
              });
            },
            child: const Text("Ulangi Kuis 🔄", style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          ElevatedButton(
            onPressed: () {
              SoundService.playClick();
              Navigator.pop(ctx);
              widget.onFinishQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danaBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Ke Beranda 🎒", style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _handleExit() async {
    SoundService.playClick();
    final shouldExit = await showConfirmExitQuizDialog(context, isDark: widget.state.isDarkMode);
    if (shouldExit && mounted) {
      widget.state.setQuizActive(false);
      setState(() {
        _hasStarted = false;
        _selectedOption = null;
        _feedbackMessage = null;
        _answerStatus = 'idle';
      });
    }
  }

  Widget _buildQuizStartScreen(bool isDark) {
    final activeMod = widget.state.activeTeacherModule ?? widget.state.currentChapter;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: "Kembali ke Beranda",
          onPressed: widget.onFinishQuiz,
        ),
        title: const Text(
          "Arena Kuis Pintar SD",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppTheme.danaBlue,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(isDark ? 30 : 220),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text("⭐", style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  "${widget.state.totalPoints} Poin",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
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
              // 1. Hero Card: Arena Kuis Seru
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text("🎮", style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBBF24),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "TANTANGAN SISWA CERDAS",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF78350F),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Tantangan Kuis Berhadiah",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Jawab pertanyaan pilihan ganda dengan tepat untuk mengumpulkan poin bintang emas dan rebut posisi puncak di tangga juara kelas!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. Modul Pelajaran yang Diuji (Khusus Materi Validasi Guru)
              Text(
                "Materi Pelajaran yang Diujikan:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
                    width: 1.5,
                  ),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: activeMod.subject == 'pkn'
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          activeMod.subject == 'pkn' ? "🇮🇩" : "🎭",
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  activeMod.chapterCode,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "✓ Tervalidasi Guru",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeMod.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.textMain,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. Panduan Aturan Singkat
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : AppTheme.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    _buildFeatureRow("📝", "Soal Interaktif Adaptif", "Dirancang khusus menguji daya tangkap materi kurikulum.", isDark),
                    const Divider(height: 16),
                    _buildFeatureRow("💡", "Petunjuk Pintar AI", "Tersedia tips & ulasan jika kamu belum yakin menjawab.", isDark),
                    const Divider(height: 16),
                    _buildFeatureRow("🏆", "Naikkan Peringkat", "Setiap jawaban benar langsung menambahkan poin prestasi!", isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Tombol Start Besar & Ceria
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    SoundService.playClick();
                    setState(() {
                      _hasStarted = true;
                      _questionIndex = 0;
                      _selectedOption = null;
                      _feedbackMessage = null;
                      _answerStatus = 'idle';
                      _isSubmitting = false;
                    });
                    widget.state.setQuizActive(true);
                  },
                  icon: const Text("🚀", style: TextStyle(fontSize: 20)),
                  label: const Text(
                    "Mulai Kuis Seru Sekarang!",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 4,
                    shadowColor: const Color(0xFF7C3AED).withAlpha(120),
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

  Widget _buildFeatureRow(String icon, String title, String desc, bool isDark) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.textMain,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Kartu Pilihan Jawaban Grid 2x2 (Persis Web)
  Widget _buildOptionCard(Question currentQ, int optIdx) {
    if (optIdx >= currentQ.options.length) return const SizedBox.shrink();

    final optionText = currentQ.options[optIdx];
    final isSelected = _selectedOption == optIdx;
    final isCorrectChoice = optIdx == currentQ.correctOption;

    final badgeColors = [
      const Color(0xFF0EA5E9), // A: Sky
      const Color(0xFF10B981), // B: Emerald
      const Color(0xFFF59E0B), // C: Amber
      const Color(0xFF8B5CF6), // D: Purple
    ];
    final letterBadgeColor = badgeColors[optIdx % badgeColors.length];
    final letters = ["A", "B", "C", "D"];
    final letter = letters[optIdx % letters.length];

    Color cardBg = widget.state.isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    Color cardBorder = widget.state.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    Color textColor = widget.state.isDarkMode ? Colors.white : const Color(0xFF1E293B);
    Widget? statusChip;

    if (_answerStatus == 'correct' && isSelected) {
      cardBg = const Color(0xFFECFDF5);
      cardBorder = const Color(0xFF10B981);
      textColor = const Color(0xFF065F46);
      statusChip = _buildAnswerChip("🎉", "Tepat!", const Color(0xFF059669));
    } else if (_answerStatus == 'wrong' && isSelected) {
      cardBg = const Color(0xFFFFF1F2);
      cardBorder = const Color(0xFFF43F5E);
      textColor = const Color(0xFF881337);
      statusChip = _buildAnswerChip("❌", "Belum", const Color(0xFFE11D48));
    } else if (_answerStatus == 'wrong' && isCorrectChoice) {
      cardBg = const Color(0xFFECFDF5);
      cardBorder = const Color(0xFF10B981);
      textColor = const Color(0xFF065F46);
      statusChip = _buildAnswerChip("✅", "Tepat", const Color(0xFF059669));
    } else if (isSelected) {
      cardBg = const Color(0xFFFFFBEB);
      cardBorder = const Color(0xFFF59E0B);
      textColor = const Color(0xFF78350F);
      statusChip = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFD97706),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withAlpha(80),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("★", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            SizedBox(width: 3),
            Text(
              "Dipilih",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorder,
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: cardBorder.withAlpha(90),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(widget.state.isDarkMode ? 30 : 10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _isSubmitting
              ? null
              : () {
                  SoundService.playClick();
                  setState(() {
                    _selectedOption = optIdx;
                    _feedbackMessage = null;
                  });
                },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Letter Badge (A, B, C, D)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: letterBadgeColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: letterBadgeColor.withAlpha(80),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    if (statusChip != null) statusChip,
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  optionText,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerChip(String icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingQuestions) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.danaBlue),
              SizedBox(height: 12),
              Text(
                "Menyiapkan Soal Kuis Tantangan... 🎮",
                style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = widget.state.isDarkMode;

    // Jika belum menekan tombol start, tampilkan layar Start Kuis Ceria
    if (!_hasStarted) {
      return _buildQuizStartScreen(isDark);
    }

    final totalQuestions = _questions.isNotEmpty ? _questions.length : 5;
    final progressPercent = ((_questionIndex + 1) / totalQuestions).clamp(0.0, 1.0);
    final currentQ = _questions.isNotEmpty ? _questions[_questionIndex] : null;
    final activeMod = widget.state.activeTeacherModule ?? widget.state.currentChapter;

    return Scaffold(
      backgroundColor: widget.state.isDarkMode ? const Color(0xFF0B1329) : const Color(0xFFF0F9FF),
      body: AnimatedRgbBackground(
        isDark: isDark,
        child: SafeArea(
          child: currentQ == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Soal belum tersedia untuk bab ini."),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: widget.onFinishQuiz,
                        child: const Text("Kembali"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TOP STATUS BAR (Fun & Bubbly - Persis seperti QuizClient.tsx di Web)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.state.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: const Color(0xFFFACC15), // Yellow 400
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFACC15).withAlpha(40),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Target Icon Badge
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDB2777), // Pink 600
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFDB2777).withAlpha(70),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text("🎯", style: TextStyle(fontSize: 22)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "KUIS TANTANGAN SD 🎯",
                                        style: TextStyle(
                                          color: Color(0xFFDB2777),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Materi: ${activeMod.chapterCode} • ${activeMod.title}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: widget.state.isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Tutup Kuis Button
                                InkWell(
                                  onTap: _handleExit,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: widget.state.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: widget.state.isDarkMode ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Tutup",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: widget.state.isDarkMode ? Colors.white : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Progress Indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Perjalanan",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                                Text(
                                  "${_questionIndex + 1} dari $totalQuestions Soal",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 12,
                                child: LinearProgressIndicator(
                                  value: progressPercent,
                                  backgroundColor: const Color(0xFFDBEAFE),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. QUESTION CARD (Big, Colorful Indigo Gradient - Persis Web)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.state.isDarkMode
                                ? [const Color(0xFF312E81), const Color(0xFF581C87)]
                                : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFF818CF8),
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withAlpha(80),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Yellow Pill Badge
                            Transform.rotate(
                              angle: -0.03,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFACC15),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "PERTANYAAN ${_questionIndex + 1}",
                                  style: const TextStyle(
                                    color: Color(0xFF713F12),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Question Text
                            Text(
                              currentQ.question,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1.35,
                                letterSpacing: -0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            // Pilihan Jawaban Jejer 2 2 (2x2 Grid Persis Tampilan Web)
                            Column(
                              children: [
                                for (int r = 0; r < (currentQ.options.length / 2).ceil(); r++) ...[
                                  if (r > 0) const SizedBox(height: 10),
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(child: _buildOptionCard(currentQ, r * 2)),
                                        const SizedBox(width: 10),
                                        if (r * 2 + 1 < currentQ.options.length)
                                          Expanded(child: _buildOptionCard(currentQ, r * 2 + 1))
                                        else
                                          const Expanded(child: SizedBox.shrink()),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),

                          // Feedback Banner (Overlay & Peringatan Belum Memilih Jawaban - Persis Web)
                          if (_feedbackMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _answerStatus == 'correct'
                                      ? [const Color(0xFF34D399), const Color(0xFF10B981)]
                                      : _answerStatus == 'wrong'
                                          ? [const Color(0xFFFB7185), const Color(0xFFF43F5E)]
                                          : [const Color(0xFFFDE047), const Color(0xFFF59E0B)], // Amber yellow cerah persis web
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _answerStatus == 'idle'
                                      ? const Color(0xFFB45309)
                                      : Colors.white,
                                  width: 2.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_answerStatus == 'idle'
                                            ? const Color(0xFFF59E0B)
                                            : Colors.black26)
                                        .withAlpha(80),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_answerStatus == 'idle') ...[
                                    const Text("⚠️ ", style: TextStyle(fontSize: 16)),
                                  ],
                                  Flexible(
                                    child: Text(
                                      _feedbackMessage!,
                                      style: TextStyle(
                                        color: _answerStatus == 'idle'
                                            ? const Color(0xFF78350F)
                                            : Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. ACTION BAR (Tombol Petunjuk & Jawab)
                    Row(
                      children: [
                        // Petunjuk Button
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              SoundService.playClick();
                              setState(() => _showHint = !_showHint);
                            },
                            icon: const Text("💡", style: TextStyle(fontSize: 16)),
                            label: Text(
                              _showHint ? "Tutup" : "Petunjuk",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF78350F).withAlpha(80) : const Color(0xFFFEF3C7),
                              side: BorderSide(
                                color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFFBBF24),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Submit Answer Button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _handleSubmitAnswer,
                            icon: const Text("🚀", style: TextStyle(fontSize: 16)),
                            label: const Text(
                              "Kirim Jawaban!",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                              shadowColor: const Color(0xFF10B981).withAlpha(100),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Hint Box (Bantuan Pintar AI)
                    if (_showHint) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFBBF24),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("🤖", style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Petunjuk Pintar AI:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentQ.hint.isNotEmpty
                                        ? currentQ.hint
                                        : "Baca kembali materi di Ruang Belajar untuk menemukan jawaban yang paling tepat ya!",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white70 : const Color(0xFF78350F),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
