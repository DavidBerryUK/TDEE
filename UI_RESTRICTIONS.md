# UI Restrictions - AI Agent Guidelines

## Overview
This file documents UI components that must NOT be modified without explicit user approval.

## Critical UI Components

### Picker Styles
- **Wheel Pickers** (`.pickerStyle(.wheel)`) - Used for:
  - Age selection
  - Weight selection (multi-wheel with unit support)
  - Height selection (multi-wheel with unit support)
  - Body fat percentage (integer + decimal wheels)
  - Activity level selection
  - Macro split selection

- **Segmented Controls** (`.pickerStyle(.segmented)`) - Used for:
  - Unit of measure selection (kg/lb/stones for weight, cm/inches/feet for height)
  - Body fat calculation method (Omit/Estimate/Manual Entry)
  - Calorie adjustment method (Maintain/Cut/Bulk)
  - Gender selection
  - Macro split method selection

## Expanding Panels
- **UILayoutExpandingPanel** - Used for conditional UI sections:
  - Body fat percentage picker shows only for "Manual Entry"
  - Calorie adjustment slider shows only for "Cut" or "Bulk"

## Rules
1. **NEVER** change `.pickerStyle(.wheel)` to `.pickerStyle(.menu)` or vice versa
2. **NEVER** remove option cases from picker views
3. **NEVER** modify expanding panel logic without approval
4. **NEVER** change animation parameters without approval
5. **ALWAYS** report back to user before making any UI changes

## Report Format
If you need to make changes to these files, report back with:
1. The specific file(s) to modify
2. The reason for the change
3. The proposed change details
4. Approval request
