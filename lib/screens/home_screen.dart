import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme.dart';
import '../widgets/kanban_section.dart';
import '../widgets/quick_add_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const _Header(),
            // Progress bar
            const _ProgressBar(),
            const Divider(height: 1, color: AppColors.divider),
            // Kanban sections (scrollable)
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, provider, _) {
                  return ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    children: [
                      // DOING section - always on top, largest
                      KanbanSection(
                        title: 'DOING',
                        sectionKey: 'doing',
                        tasks: provider.doingTasks,
                        totalCount: provider.doingTasks.length,
                      ),
                      const Divider(height: 1, color: AppColors.divider, indent: 12, endIndent: 12),
                      // STOCK section with filter
                      KanbanSection(
                        title: 'STOCK',
                        sectionKey: 'stock',
                        tasks: provider.stockTasks,
                        totalCount: provider.stockTasks.length,
                        showStatusTags: true,
                        trailing: _StockFilter(provider: provider),
                      ),
                      const Divider(height: 1, color: AppColors.divider, indent: 12, endIndent: 12),
                      // REVIEW section
                      KanbanSection(
                        title: 'REVIEW',
                        sectionKey: 'review',
                        tasks: provider.reviewTasks,
                        totalCount: provider.reviewTasks.length,
                      ),
                      const Divider(height: 1, color: AppColors.divider, indent: 12, endIndent: 12),
                      // DONE section (collapsible)
                      KanbanSection(
                        title: 'DONE',
                        sectionKey: 'done',
                        tasks: provider.doneTasks,
                        totalCount: provider.doneTasks.length,
                        collapsible: true,
                        initiallyCollapsed: true,
                        trailing: provider.doneTasks.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _confirmClearDone(context, provider),
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(Icons.delete_sweep, size: 16, color: AppColors.textMuted),
                                ),
                              )
                            : null,
                      ),
                    ],
                  );
                },
              ),
            ),
            // Quick add bar
            const QuickAddBar(),
          ],
        ),
      ),
    );
  }

  void _confirmClearDone(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear completed tasks?', style: TextStyle(fontSize: 14)),
        content: Text(
          '${provider.doneTasks.length} completed tasks will be removed.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              provider.clearDone();
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.urgentPriority)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('M/d').format(now);
    final dayStr = DateFormat('E').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // App title
          const Text(
            'Daily Tasker',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Date
          Text(
            '$dateStr $dayStr',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final total = provider.totalTodayTasks;
        final done = provider.completedTasks;
        final progress = total > 0 ? done / total : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.doneAccent),
                    minHeight: 3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$done/$total',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StockFilter extends StatelessWidget {
  final TaskProvider provider;
  const _StockFilter({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilterChip(
          label: 'ALL',
          isActive: provider.stockFilter == null,
          onTap: () => provider.setStockFilter(null),
        ),
        const SizedBox(width: 6),
        _FilterChip(
          label: 'NEW',
          color: AppColors.freshTag,
          isActive: provider.stockFilter == TaskStatus.fresh,
          onTap: () => provider.setStockFilter(TaskStatus.fresh),
        ),
        const SizedBox(width: 6),
        _FilterChip(
          label: 'HLD',
          color: AppColors.holdTag,
          isActive: provider.stockFilter == TaskStatus.hold,
          onTap: () => provider.setStockFilter(TaskStatus.hold),
        ),
        const SizedBox(width: 6),
        _FilterChip(
          label: 'RET',
          color: AppColors.returnedTag,
          isActive: provider.stockFilter == TaskStatus.returned,
          onTap: () => provider.setStockFilter(TaskStatus.returned),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        constraints: const BoxConstraints(minHeight: 32),
        decoration: BoxDecoration(
          color: isActive ? chipColor.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? chipColor.withValues(alpha: 0.5) : AppColors.divider,
            width: isActive ? 1.0 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? chipColor : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
