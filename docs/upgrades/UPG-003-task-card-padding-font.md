# UPG-003: Task Card Padding & Font Size

## Date: 2026-02-24

## Category: Mobile Readability / Touch Usability

## Problem
Task cards had tight padding (10x8dp) and a 13px title font. On mobile, this
made cards feel cramped and text was slightly hard to read at arm's length.
The card-to-card spacing (3dp margin) left minimal visual separation.

### Measurements (Before)
| Element        | Value  | Recommended | Verdict |
|----------------|--------|-------------|---------|
| Card padding H | 10dp   | 12-16dp     | NG      |
| Card padding V | 8dp    | 10-14dp     | NG      |
| Title font     | 13px   | 14-16px     | NG      |
| Note font      | 11px   | 12px        | NG      |
| Card margin V  | 3dp    | 4-6dp       | NG      |
| Priority dot   | 6dp    | 7-8dp       | Borderline |

## Changes

### Task Card (`task_card.dart`)
- Card inner padding: `horizontal: 10, vertical: 8` -> `horizontal: 12, vertical: 11`
- Title font size: `13px` -> `14px`
- Title line height: added `height: 1.3` for better readability
- Note font size: `11px` -> `12px`
- Priority dot: `6x6dp` -> `7x7dp`, margin `6` -> `7`

### Theme (`theme.dart`)
- Card vertical margin: `3dp` -> `4dp`

## Impact on PC Layout (Persona)
- Cards grow ~6dp taller each -> with max 5 tasks/day, total ~30dp growth
- Improved scannability at narrow 300px width
- Font size 14px is still compact for desktop use
- No horizontal overflow risk

## Status: DONE
