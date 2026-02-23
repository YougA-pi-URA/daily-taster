# UPG-004: Quick Add Bar Usability

## Date: 2026-02-24

## Category: Mobile Usability / Input Ergonomics

## Problem
The quick add bar at the bottom of the screen had small touch targets and tight
spacing. The STOCK/DOING toggle was tiny (9px font, 6x3 padding) and the + button
(32x32dp) was below the 44dp mobile minimum. Text input padding was cramped.

### Measurements (Before)
| Element        | Size       | Guideline | Verdict |
|----------------|------------|-----------|---------|
| Toggle button  | ~40x18dp   | 44x44dp   | NG      |
| + button       | 32x32dp    | 44x44dp   | NG      |
| Bar padding    | 10x8dp     | 12-16dp   | NG      |
| Input font     | 13px       | 14-16px   | NG      |
| Input padding  | 10x8dp     | 12x10dp   | NG      |

## Changes (`quick_add_bar.dart`)

### Container Padding
- `horizontal: 10, vertical: 8` -> `horizontal: 12, vertical: 10`

### STOCK/DOING Toggle
- Padding: `horizontal: 6, vertical: 3` -> `horizontal: 10, vertical: 6`
- Added `minHeight: 36` constraint
- Font size: `9px` -> `10px`
- Border radius: `4` -> `6`
- Added icon (play_arrow / inbox) for visual affordance
- Added subtle border for better definition
- Added `HitTestBehavior.opaque` for full tap area

### Text Input
- Font size: `13px` -> `14px`
- Content padding: `horizontal: 10, vertical: 8` -> `horizontal: 12, vertical: 10`

### Add (+) Button
- Size: `32x32dp` -> `44x44dp` (meets 44dp minimum)
- Border radius: `8` -> `10`
- Icon size: `18` -> `22`
- Added amber glow shadow for visual prominence
- Added `HitTestBehavior.opaque` for full tap area

## Impact on PC Layout (Persona)
- Bar grows ~6dp taller -> acceptable at bottom of screen
- + button grows 12dp -> still fits within narrow layout
- Toggle now more informative with icon + text

## Status: DONE
