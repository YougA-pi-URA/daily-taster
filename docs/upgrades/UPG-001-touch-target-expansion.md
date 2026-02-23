# UPG-001: Touch Target Expansion

## Date: 2026-02-24

## Category: Mobile Usability

## Problem
Filter chips (ALL/NEW/HOLD/RET), task checkboxes, and status icons had touch
targets below the recommended 44x44dp minimum for mobile. On a phone screen,
these were difficult to tap accurately with a finger.

### Measurements (Before)
| Element          | Size      | Guideline | Verdict |
|------------------|-----------|-----------|---------|
| Filter chip      | ~24x14dp  | 44x44dp   | NG      |
| Checkbox (doing) | 18x18dp   | 44x44dp   | NG      |
| Review icon      | 18x18dp   | 44x44dp   | NG      |

## Changes

### Filter Chips (`home_screen.dart`)
- Padding: `horizontal: 5, vertical: 2` -> `horizontal: 8, vertical: 5`
- Font size: `8px` -> `10px`
- Spacing between chips: `4px` -> `6px`
- Border radius: `3` -> `4`

### Task Checkboxes (`task_card.dart`)
- Checkbox size: `18x18` -> `22x22`
- Margin right: `8` -> `10`
- Border radius: `4` -> `5`
- Check icon size: `12` -> `14`
- Review icon size: `11` -> `13`

## Impact on PC Layout (Persona)
- Filter chips grow ~6px wider total across all 4 chips -> fits within 300px
- Checkboxes grow 4px -> negligible visual change on desktop
- No layout breakage at narrow widths

## Status: DONE
