# UPG-006: Swipe Gestures for Status Movement

## Date: 2026-02-24

## Category: Mobile UX / Gesture Interaction

## Problem
On mobile, moving a task between statuses required tapping the card, waiting
for the bottom sheet, then tapping the target status chip. This 3-step flow
is acceptable on desktop (mouse click) but slow on mobile where swipe gestures
are the natural interaction pattern.

### User Flow (Before)
1. Tap card -> bottom sheet opens
2. Read options
3. Tap target status chip
**3 steps, ~2 seconds**

### User Flow (After)
1. Swipe card in the appropriate direction
**1 step, ~0.5 seconds**

## Changes (`task_card.dart`)

### Swipe Direction Mapping

| Current Status | Swipe Right (->)  | Swipe Left (<-)   |
|----------------|--------------------|--------------------|
| Stock (NEW)    | -> DOING (amber)   | -                  |
| Stock (HOLD)   | -> DOING (amber)   | -                  |
| Stock (RET)    | -> DOING (amber)   | -                  |
| DOING          | -> REVIEW (cyan)   | <- HOLD (gray)     |
| REVIEW         | -> DONE (green)    | <- RETURN (purple) |
| DONE           | (no swipe)         | (no swipe)         |

### Implementation
- Wrapped TaskCard with `Dismissible` widget
- `confirmDismiss` returns `false` to prevent card removal (moves instead)
- Colored swipe backgrounds with icon + label hint
- `_SwipeConfig` class defines per-status swipe behavior
- `_SwipeBackground` widget shows directional hint

### Design Rationale
- **Right swipe = forward** (progress in workflow)
- **Left swipe = backward** (hold/return)
- **Done items don't swipe** (prevents accidental reopen)
- Visual background shows where the task will go before releasing

## Impact on PC Layout (Persona)
- Swipe is mobile-only gesture; on desktop, mouse users continue to
  use tap -> bottom sheet flow (unchanged)
- No visual or layout changes to the card itself
- Tap still works as before (additive, not replacing)

## Status: DONE
