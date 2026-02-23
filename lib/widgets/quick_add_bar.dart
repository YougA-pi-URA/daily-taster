import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme.dart';

class QuickAddBar extends StatefulWidget {
  const QuickAddBar({super.key});

  @override
  State<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends State<QuickAddBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _addAsDoing = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<TaskProvider>();
    provider.addTask(
      text,
      status: _addAsDoing ? TaskStatus.doing : TaskStatus.fresh,
    );
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Quick toggle: add to Stock or Doing
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _addAsDoing = !_addAsDoing),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    constraints: const BoxConstraints(minHeight: 36),
                    decoration: BoxDecoration(
                      color: _addAsDoing
                          ? AppColors.doingAccent.withValues(alpha: 0.2)
                          : AppColors.stockAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _addAsDoing
                            ? AppColors.doingAccent.withValues(alpha: 0.4)
                            : AppColors.stockAccent.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _addAsDoing ? Icons.play_arrow : Icons.inbox,
                          size: 13,
                          color: _addAsDoing
                              ? AppColors.doingAccent
                              : AppColors.stockAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _addAsDoing ? 'DOING' : 'STOCK',
                          style: TextStyle(
                            color: _addAsDoing
                                ? AppColors.doingAccent
                                : AppColors.stockAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Add task...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _submit(),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: 8),
                // Add button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _submit,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.doingAccent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.doingAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, size: 22, color: AppColors.background),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
