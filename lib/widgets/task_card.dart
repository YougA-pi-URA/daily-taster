import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool showStatusTag;

  const TaskCard({
    super.key,
    required this.task,
    this.showStatusTag = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();

    // Determine swipe actions based on current status
    final swipeConfig = _getSwipeConfig();

    Widget cardWidget = Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showTaskActions(context, provider),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: AppColors.priorityColor(task.priority),
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              // Checkbox (only for doing tasks)
              if (task.status == TaskStatus.doing)
                GestureDetector(
                  onTap: () => provider.moveTask(task.id, TaskStatus.review),
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: AppColors.textMuted,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.transparent),
                  ),
                ),
              // Done checkbox
              if (task.status == TaskStatus.review)
                GestureDetector(
                  onTap: () => provider.moveTask(task.id, TaskStatus.done),
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: AppColors.reviewAccent,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.visibility, size: 13, color: AppColors.reviewAccent),
                  ),
                ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Status tag (for stock items)
                        if (showStatusTag) ...[
                          _StatusTag(status: task.status),
                          const SizedBox(width: 6),
                        ],
                        // Priority dot
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 7),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.priorityColor(task.priority),
                          ),
                        ),
                        // Title
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: task.status == TaskStatus.done
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              decoration: task.status == TaskStatus.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (task.note != null && task.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          task.note!,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with Dismissible if swipe actions are available
    if (swipeConfig == null) return cardWidget;

    return Dismissible(
      key: Key('swipe_${task.id}'),
      direction: swipeConfig.direction,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && swipeConfig.rightAction != null) {
          provider.moveTask(task.id, swipeConfig.rightAction!);
          return false; // Don't actually dismiss, just move
        } else if (direction == DismissDirection.endToStart && swipeConfig.leftAction != null) {
          provider.moveTask(task.id, swipeConfig.leftAction!);
          return false;
        }
        return false;
      },
      background: swipeConfig.rightAction != null
          ? _SwipeBackground(
              color: swipeConfig.rightColor!,
              icon: swipeConfig.rightIcon!,
              label: swipeConfig.rightLabel!,
              alignment: Alignment.centerLeft,
            )
          : const SizedBox.shrink(),
      secondaryBackground: swipeConfig.leftAction != null
          ? _SwipeBackground(
              color: swipeConfig.leftColor!,
              icon: swipeConfig.leftIcon!,
              label: swipeConfig.leftLabel!,
              alignment: Alignment.centerRight,
            )
          : const SizedBox.shrink(),
      child: cardWidget,
    );
  }

  _SwipeConfig? _getSwipeConfig() {
    switch (task.status) {
      case TaskStatus.fresh:
      case TaskStatus.hold:
      case TaskStatus.returned:
        // Stock -> swipe right to DOING
        return _SwipeConfig(
          direction: DismissDirection.startToEnd,
          rightAction: TaskStatus.doing,
          rightColor: AppColors.doingAccent,
          rightIcon: Icons.play_arrow,
          rightLabel: 'DOING',
        );
      case TaskStatus.doing:
        // Doing -> swipe right to REVIEW, swipe left to HOLD
        return _SwipeConfig(
          direction: DismissDirection.horizontal,
          rightAction: TaskStatus.review,
          rightColor: AppColors.reviewAccent,
          rightIcon: Icons.visibility,
          rightLabel: 'REVIEW',
          leftAction: TaskStatus.hold,
          leftColor: AppColors.holdTag,
          leftIcon: Icons.pause,
          leftLabel: 'HOLD',
        );
      case TaskStatus.review:
        // Review -> swipe right to DONE, swipe left to RETURN
        return _SwipeConfig(
          direction: DismissDirection.horizontal,
          rightAction: TaskStatus.done,
          rightColor: AppColors.doneAccent,
          rightIcon: Icons.check_circle,
          rightLabel: 'DONE',
          leftAction: TaskStatus.returned,
          leftColor: AppColors.returnedTag,
          leftIcon: Icons.replay,
          leftLabel: 'RETURN',
        );
      case TaskStatus.done:
        return null; // No swipe on done items
    }
  }

  void _showTaskActions(BuildContext context, TaskProvider provider) {
    final List<_ActionItem> actions = [];

    // Move actions based on current status
    if (task.isStock) {
      actions.add(_ActionItem(
        icon: Icons.play_arrow,
        label: 'DOING',
        color: AppColors.doingAccent,
        onTap: () => provider.moveTask(task.id, TaskStatus.doing),
      ));
    }
    if (task.status == TaskStatus.doing) {
      actions.add(_ActionItem(
        icon: Icons.visibility,
        label: 'REVIEW',
        color: AppColors.reviewAccent,
        onTap: () => provider.moveTask(task.id, TaskStatus.review),
      ));
      actions.add(_ActionItem(
        icon: Icons.pause,
        label: 'HOLD',
        color: AppColors.holdTag,
        onTap: () => provider.moveTask(task.id, TaskStatus.hold),
      ));
    }
    if (task.status == TaskStatus.review) {
      actions.add(_ActionItem(
        icon: Icons.replay,
        label: 'RETURN',
        color: AppColors.returnedTag,
        onTap: () => provider.moveTask(task.id, TaskStatus.returned),
      ));
      actions.add(_ActionItem(
        icon: Icons.check_circle,
        label: 'DONE',
        color: AppColors.doneAccent,
        onTap: () => provider.moveTask(task.id, TaskStatus.done),
      ));
    }
    if (task.status == TaskStatus.done) {
      actions.add(_ActionItem(
        icon: Icons.replay,
        label: 'REOPEN',
        color: AppColors.freshTag,
        onTap: () => provider.moveTask(task.id, TaskStatus.fresh),
      ));
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task title
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.priorityColor(task.priority),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Move actions
              if (actions.isNotEmpty) ...[
                const Text(
                  'MOVE TO',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: actions
                      .map((a) => _ActionChip(action: a, ctx: ctx))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              const Divider(color: AppColors.divider),
              // Edit / Priority / Delete
              ListTile(
                dense: true,
                leading: const Icon(Icons.edit, size: 18),
                title: const Text('Edit', style: TextStyle(fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditDialog(context, provider);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.flag, size: 18, color: AppColors.urgentPriority),
                title: const Text('Priority', style: TextStyle(fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showPriorityPicker(context, provider);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.delete_outline, size: 18, color: AppColors.urgentPriority),
                title: const Text('Delete', style: TextStyle(fontSize: 13, color: AppColors.urgentPriority)),
                onTap: () {
                  provider.deleteTask(task.id);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TaskProvider provider) {
    final controller = TextEditingController(text: task.title);
    final noteController = TextEditingController(text: task.note ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Task', style: TextStyle(fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Task title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              decoration: const InputDecoration(hintText: 'Note (optional)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.editTask(
                  task.id,
                  title: controller.text.trim(),
                  note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPriorityPicker(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Set Priority', style: TextStyle(fontSize: 14)),
        children: TaskPriority.values.map((p) {
          return SimpleDialogOption(
            onPressed: () {
              provider.editTask(task.id, priority: p);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.priorityColor(p),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  p == TaskPriority.urgent
                      ? 'Urgent'
                      : p == TaskPriority.normal
                          ? 'Normal'
                          : 'Low',
                  style: TextStyle(
                    fontSize: 13,
                    color: task.priority == p
                        ? AppColors.doingAccent
                        : AppColors.textPrimary,
                    fontWeight:
                        task.priority == p ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final TaskStatus status;
  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (status) {
      case TaskStatus.fresh:
        label = 'NEW';
        break;
      case TaskStatus.hold:
        label = 'HOLD';
        break;
      case TaskStatus.returned:
        label = 'RET';
        break;
      default:
        label = '';
    }
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.statusTagColor(status).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.statusTagColor(status),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ActionChip extends StatelessWidget {
  final _ActionItem action;
  final BuildContext ctx;
  const _ActionChip({required this.action, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          action.onTap();
          Navigator.pop(ctx);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 18, color: action.color),
              const SizedBox(width: 6),
              Text(
                action.label,
                style: TextStyle(
                  color: action.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeConfig {
  final DismissDirection direction;
  final TaskStatus? rightAction;
  final Color? rightColor;
  final IconData? rightIcon;
  final String? rightLabel;
  final TaskStatus? leftAction;
  final Color? leftColor;
  final IconData? leftIcon;
  final String? leftLabel;

  const _SwipeConfig({
    required this.direction,
    this.rightAction,
    this.rightColor,
    this.rightIcon,
    this.rightLabel,
    this.leftAction,
    this.leftColor,
    this.leftIcon,
    this.leftLabel,
  });
}

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: alignment,
      padding: EdgeInsets.only(
        left: isLeft ? 16 : 0,
        right: isLeft ? 0 : 16,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLeft) ...[
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(icon, color: color, size: 18),
          if (isLeft) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
