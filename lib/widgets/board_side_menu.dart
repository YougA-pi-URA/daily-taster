import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme.dart';

const double _kMenuWidth = 210.0;

/// Slide-in board switcher panel from the left side.
/// Place inside a Stack on top of the main content.
class BoardSideMenu extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const BoardSideMenu({
    super.key,
    required this.isOpen,
    required this.onClose,
  });

  @override
  State<BoardSideMenu> createState() => _BoardSideMenuState();
}

class _BoardSideMenuState extends State<BoardSideMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 0.45)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    if (widget.isOpen) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(BoardSideMenu old) {
    super.didUpdateWidget(old);
    if (widget.isOpen != old.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        if (_ctrl.isDismissed) return const SizedBox.shrink();
        return Stack(
          children: [
            // Scrim
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                color: Colors.black.withValues(alpha: _fade.value),
              ),
            ),
            // Panel
            SlideTransition(
              position: _slide,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _MenuPanel(onClose: widget.onClose),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Panel content ──────────────────────────────────────────────────────────

class _MenuPanel extends StatelessWidget {
  final VoidCallback onClose;
  const _MenuPanel({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: SizedBox(
        width: _kMenuWidth,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelHeader(onClose: onClose),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (context, provider, _) {
                    return _BoardList(
                      provider: provider,
                      onClose: onClose,
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _AddBoardButton(onCreated: onClose),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Panel header ────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _PanelHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Text(
            'BOARDS',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.chevron_left,
                size: 18, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Board list ──────────────────────────────────────────────────────────────

class _BoardList extends StatelessWidget {
  final TaskProvider provider;
  final VoidCallback onClose;
  const _BoardList({required this.provider, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final boards = provider.boards;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: boards.length,
      itemBuilder: (context, i) {
        final board = boards[i];
        final isActive = board.id == provider.activeBoardId;
        return _BoardTile(
          board: board,
          isActive: isActive,
          canDelete: boards.length > 1,
          onTap: () {
            provider.switchBoard(board.id);
            onClose();
          },
          onRename: (name) => provider.setBoardNameFor(board.id, name),
          onDelete: () => _confirmDelete(context, provider, board.id, board.name),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    TaskProvider provider,
    String boardId,
    String boardName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete "$boardName"?',
          style: const TextStyle(fontSize: 14),
        ),
        content: const Text(
          'All tasks on this board will be deleted.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteBoard(boardId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.urgentPriority)),
          ),
        ],
      ),
    );
  }
}

// ─── Board tile ──────────────────────────────────────────────────────────────

class _BoardTile extends StatefulWidget {
  final dynamic board; // BoardMeta
  final bool isActive;
  final bool canDelete;
  final VoidCallback onTap;
  final void Function(String) onRename;
  final VoidCallback onDelete;

  const _BoardTile({
    required this.board,
    required this.isActive,
    required this.canDelete,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  State<_BoardTile> createState() => _BoardTileState();
}

class _BoardTileState extends State<_BoardTile> {
  bool _editing = false;
  late TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.board.name as String);
    _focus.addListener(() {
      if (!_focus.hasFocus && _editing) _save();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() {
      _ctrl.text = widget.board.name as String;
      _editing = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
      _ctrl.selection =
          TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
    });
  }

  void _save() {
    widget.onRename(_ctrl.text);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    return GestureDetector(
      onTap: _editing ? null : widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.stockAccent.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? AppColors.stockAccent.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              // Board name or text field
              Expanded(
                child: _editing
                    ? TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 2, horizontal: 4),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.stockAccent, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.stockAccent, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                        ),
                        onSubmitted: (_) => _save(),
                        textInputAction: TextInputAction.done,
                      )
                    : Text(
                        widget.board.name as String,
                        style: TextStyle(
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              const SizedBox(width: 4),
              // Action icons (only when not editing)
              if (!_editing) ...[
                GestureDetector(
                  onTap: _startEdit,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit, size: 13,
                        color: AppColors.textMuted),
                  ),
                ),
                if (widget.canDelete) ...[
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline, size: 13,
                          color: AppColors.textMuted),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add board button ────────────────────────────────────────────────────────

class _AddBoardButton extends StatelessWidget {
  final VoidCallback onCreated;
  const _AddBoardButton({required this.onCreated});

  Future<void> _create(BuildContext context) async {
    final provider = context.read<TaskProvider>();
    // 仮名: "Board N" (N = 既存ボード数 + 1)
    final n = provider.boards.length + 1;
    await provider.addBoard('Board $n');
    onCreated(); // メニューを閉じる
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => _create(context),
        child: Row(
          children: [
            const Icon(Icons.add, size: 16, color: AppColors.stockAccent),
            const SizedBox(width: 6),
            const Text(
              'Add new board',
              style: TextStyle(
                color: AppColors.stockAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
