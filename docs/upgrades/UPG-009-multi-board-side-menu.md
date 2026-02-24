# UPG-009 複数ボード対応 + 格納サイドメニュー

**日付**: 2026-02-24  
**対象ファイル**:
- `lib/models/task.dart` — boardId フィールド追加
- `lib/providers/task_provider.dart` — 全面改修（複数ボード管理）
- `lib/widgets/board_side_menu.dart` — **新規作成**（格納サイドメニュー）
- `lib/screens/home_screen.dart` — HomeScreen を StatefulWidget 化、メニュートグル追加

---

## 概要

ヘッダー左端のハンバーガーアイコンからスライドインするサイドメニューを実装し、  
複数のカンバンボードを切り替え・追加・削除できるようにした。

---

## 変更詳細

### `lib/models/task.dart`

| 変更 | 内容 |
|------|------|
| `boardId` フィールド追加 | `final String boardId` — タスクの所属ボードを識別 |
| `toMap()` | `boardId` をシリアライズ |
| `fromMap()` | `boardId` をデシリアライズ（旧データ互換: なければ `'default'`） |
| `copyWith()` | `boardId` パラメータ追加 |

### `lib/providers/task_provider.dart`

| 変更 | 内容 |
|------|------|
| `BoardMeta` クラス追加 | `id`・`name` を持つ軽量なボードメタ情報 |
| `_boards: List<BoardMeta>` | Hive `meta` ボックスの `boards` キーで永続化 |
| `_activeBoardId` | アクティブボード ID（`activeBoardId` キーで永続化） |
| `switchBoard(id)` | ボード切替、ストックフィルターをリセット |
| `addBoard(name)` | 新規ボード追加 + 即座に切替 |
| `setBoardNameFor(boardId, name)` | 任意ボードのリネーム（サイドメニューから呼び出し） |
| `deleteBoard(boardId)` | ボードと所属タスクを一括削除（最後の1枚は削除不可） |
| タスク CRUD | `addTask` に `boardId: _activeBoardId` を自動付与 |
| フィルター済みゲッター | `_activeTasks` でアクティブボードのタスクのみ返す |
| **旧データ互換** | `boards` キーが無い場合は `'default'` ボードを自動生成し旧 `boardName` を引き継ぐ |

### `lib/widgets/board_side_menu.dart`（新規）

| ウィジェット | 役割 |
|-------------|------|
| `BoardSideMenu` | トップレベルのオーバーレイ。`isOpen` prop で開閉、AnimationController でスライドイン |
| `_MenuPanel` | 幅 210px のパネル本体 |
| `_PanelHeader` | "BOARDS" ラベル + 閉じる（`chevron_left`）ボタン |
| `_BoardList` | ボード一覧 ListView、スクリムタップで閉じる |
| `_BoardTile` | 1ボード行。アクティブ強調（青枠）、インライン編集（✏️）、削除（🗑）アイコン付き |
| `_AddBoardButton` | "Add new board" ボタン → テキストフィールドで名前入力 → Enter/チェックで確定 |

**アニメーション**: `Offset(-1,0) → Offset(0,0)` のスライド + スクリム `0→0.45` フェード（220ms / easeOutCubic）

### `lib/screens/home_screen.dart`

| 変更 | 内容 |
|------|------|
| `HomeScreen` を `StatefulWidget` 化 | `_menuOpen: bool` 状態を保持 |
| ハンバーガーアイコン（`Icons.menu`） | ヘッダー左端に配置、タップで `_menuOpen` トグル |
| `Stack` レイアウト | カンバン本体 + `BoardSideMenu` をオーバーレイ |
| `_Header` に `onMenuTap` コールバック | ハンバーガーのタップを親に伝達 |

---

## UX 仕様

### サイドメニュー操作
1. ヘッダー左端の ☰ をタップ → パネルがスライドイン
2. ボード名タップ → そのボードに切り替え + メニューが閉じる
3. ✏️ タップ → インライン TextField でリネーム（Enter/フォーカスアウトで確定）
4. 🗑 タップ → 確認ダイアログ → ボードとタスクをまとめて削除
5. "Add new board" タップ → テキストフィールド表示 → 名前入力 → Enter で新規ボード追加 + 即座に切替
6. スクリム（暗部）タップ / `chevron_left` タップ → パネルを閉じる

### データ永続化（Hive）
| キー | 型 | 内容 |
|------|----|------|
| `meta.boards` | `List<Map>` | 全ボードの id・name リスト |
| `meta.activeBoardId` | `String` | 前回終了時のアクティブボード |
| `tasks.*` | `Map` | 全タスク（`boardId` フィールドで所属識別） |

### 旧データとの互換性
- `boardId` のないタスク → `fromMap` で `'default'` にフォールバック
- `boards` キーのない `meta` ボックス → 旧 `boardName` を引き継いで `id='default'` のボードを自動生成

---

## 将来拡張への備え
- `BoardMeta` にアイコン・カラー属性を追加することでボードの視覚識別が可能
- `switchBoard` がアクティブ ID を中心に管理するため、ボード数が増えても O(1) 切替
- タスクの boardId を変更する「移動」機能も `copyWith(boardId: ...)` で実装可能
