# UPG-002: Section Header Padding & Tap Area

## Date: 2026-02-24

## Category: Mobile Usability / Visual Hierarchy

## Problem
Section headers (DOING/STOCK/REVIEW/DONE) had vertical padding of 8dp and no
minimum height constraint. On mobile, the tap area for collapsible sections
was too narrow and easy to miss. The DOING section didn't visually stand out
as the "primary" section.

### Measurements (Before)
| Element             | Height   | Guideline | Verdict |
|---------------------|----------|-----------|---------|
| Section header      | ~30dp    | 48dp min  | NG      |
| Collapse tap target | ~30dp    | 48dp min  | NG      |
| DOING vs others     | Same size| Hierarchy | NG      |

## Changes (`kanban_section.dart`)

### Header Padding & Min Height
- Vertical padding: `8dp` -> `12dp`
- Added `constraints: BoxConstraints(minHeight: 48)` for mobile tap compliance
- Added `behavior: HitTestBehavior.opaque` to GestureDetector for full-area tap

### DOING Section Visual Prominence
- DOING header font: `11px` -> `13px` (others remain `11px`)
- DOING left border: `3px` -> `4px` (others remain `3px`)
- DOING count badge font: `10px` -> `12px`
- DOING section background: subtle dark blue (`#1a2844`) to visually separate
- DOING section wrapped with rounded container + margin

### Collapse Icon
- Size: `18dp` -> `20dp`

### Section Bottom Spacing
- `SizedBox(height: 4)` -> `SizedBox(height: 6)`

## Impact on PC Layout (Persona)
- Headers grow ~8dp taller -> still compact, better scannability
- DOING prominence helps quick visual anchoring at narrow width
- Total vertical growth ~24dp across all 4 sections -> negligible on scroll

## Status: DONE
