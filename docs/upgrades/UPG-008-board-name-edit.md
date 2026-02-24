# UPG-008 ボード名インライン編集

**日付**: 2026-02-24  
**対象ファイル**:
- `lib/screens/home_screen.dart`
- `lib/providers/task_provider.dart`

---

## 概要

ヘッダーの「Daily Tasker」テキストをボード名欄として機能させ、タップ/クリックで直接編集できるようにした。

---

## 変更内容

### `lib/providers/task_provider.dart`

| 変更点 | 内容 |
|--------|------|
| 定数追加 | `_metaBoxName = 'meta'` |
| プロパティ追加 | `String _boardName`、getter `boardName` |
| `init()` 変更 | `_metaBox` を open し、保存済みボード名を復元 |
| メソッド追加 | `setBoardName(String name)` — Hive に永続化後 `notifyListeners()` |

### `lib/screens/home_screen.dart`

| 変更点 | 内容 |
|--------|------|
| `_Header` を `StatelessWidget` → `StatefulWidget` に変更 | `_HeaderState` を新設 |
| 編集開始 | テキスト/ペンアイコンをタップで `TextField` に切り替え |
| 編集確定 | Enter キーまたはフォーカスアウト（`FocusNode.addListener`）で `TaskProvider.setBoardName()` を呼び出し |
| 空欄保存防止 | 空文字を保存しようとすると `'Daily Tasker'` にフォールバック |
| UI | 通常時は小さなペンアイコン（`Icons.edit`, size 11）を右に表示 |

---

## UX 仕様

- **通常状態**: ボード名 + 鉛筆アイコン（控えめ）
- **編集状態**: `TextField`（青枠）にフォーカス、テキスト全選択
- **確定**: Enter or フォーカス外れ
- **永続化**: Hive `meta` ボックスに `boardName` キーで保存（アプリ再起動後も維持）

---

## 将来拡張への備え

- `TaskProvider` のボード名は **1件** のみ管理（シングルボード）
- 複数ボードへの拡張時は `meta` ボックスのスキーマを `boards: List` 形式に変更予定
- `_Header` のタップ動作をボード切替メニューのトリガーに転用できる設計
