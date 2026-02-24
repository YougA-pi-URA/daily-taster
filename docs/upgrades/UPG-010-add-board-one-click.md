# UPG-010 Add new board — ワンクリック仮名作成 & 即遷移

**日付**: 2026-02-24  
**対象ファイル**:
- `lib/widgets/board_side_menu.dart` — `_AddBoardButton` を全面改修

---

## 概要

「+ Add new board」クリック時の動作を  
**「名前入力フォームを開く」→「仮名でボードを即作成してメニューを閉じ、そのボードに遷移」** へ変更した。

---

## 変更前後の比較

| 項目 | 変更前 | 変更後 |
|------|--------|--------|
| クリック動作 | TextField + ✓/✕ ボタンを展開 | 仮名でボードを即作成 |
| 名前入力 | 作成前に入力が必要 | 不要（後から ✏️ でリネーム可） |
| 遷移 | TextField で Enter 後に切替 | 作成と同時にアクティブボードに切替 |
| メニュー | 作成後も開いたまま | 作成と同時にメニューが閉じる |
| ウィジェット型 | `StatefulWidget`（TextField・FocusNode 管理） | `StatelessWidget`（状態不要） |

---

## 変更内容

### `_AddBoardButton`（`board_side_menu.dart`）

**削除したもの**
- `StatefulWidget` / `State` クラス
- `_adding: bool` 状態フラグ
- `TextEditingController` / `FocusNode`
- TextField 展開 UI（hintText, ✓ ボタン, ✕ ボタン）

**追加したもの**
- `StatelessWidget` に簡素化
- `onCreated: VoidCallback` コンストラクタ引数（`_MenuPanel` から `onClose` を渡す）
- `_create(context)` 非同期メソッド
  1. `provider.boards.length + 1` を N として仮名 `'Board N'` を生成
  2. `provider.addBoard('Board N')` を `await`（内部で `switchBoard` も実行）
  3. `onCreated()` を呼び出しメニューを閉じる

### `_MenuPanel`（`board_side_menu.dart`）

```dart
// 変更前
_AddBoardButton()

// 変更後
_AddBoardButton(onCreated: onClose)
```

---

## UX フロー（変更後）

```
☰ を開く
  └─ "+ Add new board" クリック
       ├─ "Board 2"（仮名）を即座に作成
       ├─ アクティブボードが "Board 2" に切替
       └─ メニューが閉じる → カンバン画面に戻る

必要に応じてヘッダーまたはサイドメニューの ✏️ でリネーム
```

---

## 設計メモ

- 仮名番号は `provider.boards.length + 1` で算出するため、ボードを削除して数が減っても重複は生じない（ID は timestamp ベース）
- `addBoard` 内で `switchBoard` が呼ばれるため、`_create` 側で別途切替処理は不要
