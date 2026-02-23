# UPG-005: Bottom Sheet Action Chips

## Date: 2026-02-24

## Category: Mobile Usability / Action Accessibility

## Problem
When tapping a task card, the bottom sheet shows MOVE TO action chips
(DOING/REVIEW/HOLD/RETURN/DONE). These chips had small padding (12x6dp),
small font (11px), and small icons (14dp), making them hard to tap on mobile.

### Measurements (Before)
| Element        | Value     | Guideline | Verdict |
|----------------|-----------|-----------|---------|
| Chip padding   | 12x6dp    | 16x10dp   | NG      |
| Chip icon      | 14dp      | 18dp      | NG      |
| Chip font      | 11px      | 13px      | NG      |
| Chip spacing   | 8dp       | 10-12dp   | NG      |
| Label font     | 10px      | 11px      | NG      |

## Changes (`task_card.dart`)

### Action Chips (_ActionChip)
- Padding: `horizontal: 12, vertical: 6` -> `horizontal: 16, vertical: 10`
- Icon size: `14dp` -> `18dp`
- Icon-text gap: `4dp` -> `6dp`
- Font size: `11px` -> `13px`
- Border radius: `20` -> `22`

### Wrap Layout
- Chip spacing: `8dp` -> `10dp`
- Chip run spacing: `8dp` -> `10dp`

### MOVE TO Label
- Font size: `10px` -> `11px`
- Bottom margin: `8dp` -> `10dp`

## Impact on PC Layout (Persona)
- Bottom sheet is modal/overlay -> no impact on kanban layout
- Larger chips are beneficial on desktop too (easier click targets)
- Wrap layout handles narrow widths well

## Status: DONE
