import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class NotificationModal extends StatefulWidget {
  final AppState state;
  final Function(int) onNavigateTab;

  const NotificationModal({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  static void show(BuildContext context, AppState state, Function(int) onNavigateTab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NotificationModal(state: state, onNavigateTab: onNavigateTab),
    );
  }

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  String _activeTab = 'all'; // 'all' | 'misi' | 'unread'

  Widget _getIconForNotification(NotificationItem item) {
    final text = "${item.title} ${item.message}".toLowerCase();
    String emoji = "🔔";
    Color bg = const Color(0xFFEFF6FF);

    if (text.contains("kuis") || text.contains("tantangan")) {
      emoji = "🎯";
      bg = const Color(0xFFFDF2F8);
    } else if (text.contains("poin") || text.contains("koin") || text.contains("skor")) {
      emoji = "⭐";
      bg = const Color(0xFFFEF3C7);
    } else if (text.contains("lencana") || text.contains("juara") || text.contains("ranking")) {
      emoji = "🏅";
      bg = const Color(0xFFFEF9C3);
    } else if (text.contains("robot") || text.contains("suara") || text.contains("dongeng")) {
      emoji = "🤖";
      bg = const Color(0xFFE0E7FF);
    } else if (text.contains("remedial") || text.contains("latihan")) {
      emoji = "💪";
      bg = const Color(0xFFFFF7ED);
    } else if (text.contains("misi") || text.contains("rangkuman")) {
      emoji = "📖";
      bg = const Color(0xFFECFDF5);
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final notifications = widget.state.notifications;

    final filtered = notifications.filter((n) {
      if (_activeTab == 'unread') return !n.isRead;
      if (_activeTab == 'misi') {
        final text = "${n.title} ${n.message}".toLowerCase();
        return text.contains("kuis") ||
            text.contains("poin") ||
            text.contains("misi") ||
            text.contains("level") ||
            text.contains("lencana") ||
            text.contains("ranking");
      }
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.danaBlueLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: AppTheme.danaBlue, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Pusat Notifikasi Siswa",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppTheme.textMain,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          // Filter Tab Bar & Mark all read button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                _buildFilterChip("Semua", "all", isDark),
                const SizedBox(width: 6),
                _buildFilterChip("Misi & Poin", "misi", isDark),
                const SizedBox(width: 6),
                _buildFilterChip("Belum Dibaca", "unread", isDark),
                const Spacer(),
                TextButton(
                  onPressed: () => widget.state.markAllNotificationsRead(),
                  child: const Text(
                    "Tandai Semua",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.danaBlue),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Notification List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("🎈", style: TextStyle(fontSize: 44)),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada pemberitahuan baru",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final item = filtered[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: item.isRead
                              ? (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC))
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFF0FDF4)),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: item.isRead
                                ? (isDark ? const Color(0xFF334155) : AppTheme.borderLight)
                                : const Color(0xFF86EFAC),
                            width: item.isRead ? 1 : 1.5,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            widget.state.markNotificationRead(item.id);
                            if (item.link.contains("kuis")) {
                              Navigator.pop(context);
                              widget.onNavigateTab(2);
                            } else if (item.link.contains("pelajar")) {
                              Navigator.pop(context);
                              widget.onNavigateTab(1);
                            }
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _getIconForNotification(item),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white : AppTheme.textMain,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item.createdAt,
                                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.message,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String tabKey, bool isDark) {
    final isSelected = _activeTab == tabKey;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tabKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.danaBlue
              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}

extension IterableFilter<E> on Iterable<E> {
  Iterable<E> filter(bool Function(E element) test) => where(test);
}
