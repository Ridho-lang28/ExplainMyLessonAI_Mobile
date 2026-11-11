import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubjectTabs extends StatelessWidget {
  final String activeSubject;
  final ValueChanged<String> onSelectSubject;

  const SubjectTabs({
    super.key,
    required this.activeSubject,
    required this.onSelectSubject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              id: 'pkn',
              label: 'Pendidikan Pancasila',
              icon: '🇮🇩',
              isActive: activeSubject == 'pkn',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTab(
              id: 'bjawa',
              label: 'Basa Jawa SD',
              icon: '🎭',
              isActive: activeSubject == 'bjawa',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String id,
    required String label,
    required String icon,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onSelectSubject(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                  color: isActive ? AppTheme.danaBlueDark : AppTheme.textSecondary,
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
