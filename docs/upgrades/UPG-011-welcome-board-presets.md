# UPG-011 初回起動ウェルカムボード + プリセットタスク

**日付**: 2026-02-24  
**対象ファイル**:
- `lib/providers/task_provider.dart` — `_loadBoards` を `async` に昇格、初回判定ロジック追加、`_seedWelcomeTasks` 新設

---

## 概要

アプリを初めて起動したとき（Hive に `boards` キーが存在しない場合）に、  
チュートリアル兼ウェルカムページ用の専用ボードとプリセットタスクを自動生成するようにした。

---

## 変更内容

### `_loadBoards()` — `void` → `Future<void>` に昇格

初回判定に `await` が必要なため非同期化。`init()` の呼び出し側も `await _loadBoards()` に変更。

### 初回起動判定ロジック（3 分岐）

| 条件 | 処理 |
|------|------|
| `boards` キーあり（通常起動） | 既存ボードリストをそのまま復元 |
| `boards` なし・`boardName` あり（旧データ移行） | UPG-008 以前のデータを `id='default'` ボードとしてマイグレーション |
| `boards` なし・`boardName` なし（**初回起動**） | ウェルカムボードを作成し `_seedWelcomeTasks` を呼び出す |

### `_seedWelcomeTasks(String boardId)` — 新設

各カンバンセクションを体験できるよう 7 件のプリセットタスクを投入する。

| タスク名 | ステータス | 優先度 | note（操作説明） |
|---------|-----------|--------|-----------------|
| Daily Tasker を使ってみる | DOING | URGENT | 完了したら長押し → DONE へ移動しよう |
| チュートリアルを読む | DOING | NORMAL | ☰ メニューから新しいボードを作って実際に使い始めよう |
| 最初の本番ボードを作る | STOCK/NEW | NORMAL | ☰ → "+ Add new board" で仮名ボードが即作成される |
| タスクを追加してみる | STOCK/NEW | LOW | 画面下の入力欄に入力して Enter |
| 一時停止したいタスク | STOCK/HOLD | LOW | HOLD は「今日はやらない」タスク置き場 |
| レビュー依頼中のタスク | REVIEW | NORMAL | REVIEW は「誰かに渡した・返答待ち」のレーン |
| Daily Tasker をインストール | DONE | NORMAL | お疲れさまでした！上の DONE タスクを消すには 🗑 アイコンを使おう |

---

## ウェルカムボード仕様

| 項目 | 値 |
|------|----|
| ボード ID | `'welcome'`（固定文字列） |
| ボード名 | `Welcome to Daily Tasker` |
| 発火条件 | Hive `meta` ボックスに `boards` キーも `boardName` キーも存在しない場合のみ |
| 再生成 | しない（一度でも起動すれば `boards` キーが書き込まれるため二度と発火しない） |

---

## データ互換性

- 既存ユーザーへの影響：**なし**（`boards` キーが存在すれば新ロジックは通らない）
- 旧データ（`boardName` のみ）の移行：従来どおり `id='default'` ボードを生成
- ウェルカムボードは通常のボードと同じ CRUD 操作で編集・削除が可能
