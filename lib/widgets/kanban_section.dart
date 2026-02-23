import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme.dart';
import 'task_card.dart';

class KanbanSection extends StatelessWidget {
  final String title;
  final String sectionKey;
  final List<Task> tasks;
  final int totalCount;
  final bool collapsible;
  final bool initiallyCollapsed;
  final Widget? trailing;
  final bool showStatusTags;

  const KanbanSection({
    super.key,
    required this.title,
    required this.sectionKey,
    required this.tasks,
    required this.totalCount,
    this.collapsible = false,
    this.initiallyCollapsed = false,
    this.trailing,
    this.showStatusTags = false,
  });

  @override
  Widget build(BuildContext context) {
    return _KanbanSectionStateful(
      title: title,
      sectionKey: sectionKey,
      tasks: tasks,
      totalCount: totalCount,
      collapsible: collapsible,
      initiallyCollapsed: initiallyCollapsed,
      trailing: trailing,
      showStatusTags: showStatusTags,
    );
  }
}

class _KanbanSectionStateful extends StatefulWidget {
  final String title;
  final String sectionKey;
  final List<Task> tasks;
  final int totalCount;
  final bool collapsible;
  final bool initiallyCollapsed;
  final Widget? trailing;
  final bool showStatusTags;

  const _KanbanSectionStateful({
    required this.title,
    required this.sectionKey,
    required this.tasks,
    required this.totalCount,
    required this.collapsible,
    required this.initiallyCollapsed,
    required this.trailing,
    required this.showStatusTags,
  });

  @override
  State<_KanbanSectionStateful> createState() => _KanbanSectionStatefulState();
}

class _KanbanSectionStatefulState extends State<_KanbanSectionStateful> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.sectionAccent(widget.sectionKey);

    final isDoing = widget.sectionKey == 'doing';
    final headerFontSize = isDoing ? 13.0 : 11.0;
    final borderWidth = isDoing ? 4.0 : 3.0;
    final sectionBg = isDoing
        ? const Color(0xFF1a2844)
        : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: sectionBg,
        borderRadius: isDoing ? BorderRadius.circular(8) : null,
      ),
      margin: isDoing
          ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
          : EdgeInsets.zero,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.collapsible ? () => setState(() => _isCollapsed = !_isCollapsed) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: accentColor, width: borderWidth),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 6),
                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.totalCount}',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: isDoing ? 12.0 : 10.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.trailing != null) widget.trailing!,
                if (widget.collapsible)
                  Icon(
                    _isCollapsed ? Icons.expand_more : Icons.expand_less,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        // Task list
        if (!_isCollapsed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: widget.tasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          widget.sectionKey == 'doing'
                              ? Icons.arrow_downward
                              : widget.sectionKey == 'stock'
                                  ? Icons.add_circle_outline
                                  : widget.sectionKey == 'review'
                                      ? Icons.swap_horiz
                                      : Icons.check_circle_outline,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.sectionKey == 'doing'
                                ? 'STOCKからタスクを移動、または下から追加'
                                : widget.sectionKey == 'stock'
                                    ? '下の入力欄からタスクを追加'
                                    : widget.sectionKey == 'review'
                                        ? 'DOINGから手離れしたタスクがここに'
                                        : 'タスクなし',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: widget.tasks
                        .map((t) => TaskCard(
                              task: t,
                              showStatusTag: widget.showStatusTags,
                            ))
                        .toList(),
                  ),
          ),
        const SizedBox(height: 6),
      ],
    ),
    );
  }
}
