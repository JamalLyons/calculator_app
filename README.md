# Calculator State Lab (Alternate Edition)

**Student**: Jamal Lyons  
**Course**: CSC 4360 / 6370 Mobile Application Development  
**Assignment**: Assignment 01 | Calculator State Lab (Alternate Edition)  
**Deliverables**:
- Plain Text: `github_link.txt`
- Android APK: `JamalLyons_CalculatorApp.apk`
- Word Document: `JamalLyons_Implementation.docx`

---

## 1. Project Overview & Architectural Foundation

This Flutter application implements a reliable, testable, and accessible calculator following the **Alternate Edition** course specification. The core computational paradigm is a **left-to-right (L→R) running total** without conventional operator precedence:
```
2 + 3 × 4 = (2 + 3) × 4 = 20
```
Every binary operator commits the previously pending operation immediately, updating the accumulator and presenting a visible running total.

In addition to the core running total engine, this project implements **all** feature options across both the Undergraduate and Graduate pathways.

---

## 2. Implemented Feature Set

### Core Requirements
- **Number Keypad & Operators**: Full keypad supporting `0`–`9`, `+`, `-`, `×`, `÷`, and `=`.
- **Left-to-Right Chained Arithmetic**: Evaluates chained expressions sequentially (e.g. `2 + 3 × 4 = 20`).
- **Operator Replacement**: Consecutive operators replace the pending operation (e.g. `9 + × 2 = 18`).
- **Idempotent Equals Waiting for Operand**: Pressing `=` when waiting for an operand leaves the accumulator and pending operator intact (e.g. `7 + =`).
- **Stateful AC Reset**: Clear / All Clear resets all accumulator, pending operator, and display states (e.g. `8 + 2 × AC 4 + 1 = 5`).
- **Fresh Calculation After Equals**: Tapping a digit after `=` immediately starts a new calculation.

### Undergraduate Pathway Features
- **Decimal Support (Required)**: Full floating-point arithmetic across all operations; prevents multiple decimal points in a single operand; normalizes IEEE-754 precision artifacts (`0.1 + 0.2 = 0.3`).
- **Theme Toggle**: Real-time switching between Light and Dark themes with WCAG-compliant high-contrast surfaces and `AnimatedTheme` transitions.
- **Clear / All Clear & Clear Entry**: `AC` completely resets state; `CE` resets only the active operand without altering the accumulator.
- **Error Handling & Recovery**: Traps division by zero (`Cannot divide by 0`), invalid roots, and overflow with actionable recovery prompts.
- **Button Animations**: Press feedback with dynamic scale (`AnimatedScale` to 0.92) and Material ink ripples, strictly respecting the minimum 48×48dp accessible touch target.
- **Percentage & Sign Toggle**: Standalone percentage (`50% = 0.5`) and relative calculation (`200 + 10% = 220`); positive/negative sign toggle (`±`) with zero-protection.

### Graduate Pathway Features
- **Calculation History**: Modal history sheet logging timestamps, mode, equations, and results; tap any past result to load it into the active calculator; includes a one-click history clear action.
- **Advanced Operations**: Square root (`√`) with negative input validation, percentage (`%`), and sign toggle (`±`).
- **Backspace & Delete**: Single-digit deletion, decimal point erasure handling, and long-press clear gesture support on `⌫`.
- **Dual Mode: Parentheses & Conventional Precedence (PEMDAS)**: Top AppBar switch toggles between L→R Running Total mode and conventional PEMDAS mode. In PEMDAS mode, `(`, `)`, and operator precedence are evaluated via Dijkstra's Shunting-yard algorithm (`2 + 3 × 4 = 14`, `(2 + 3) × 4 = 20`).
- **Responsive Landscape Mode**: Adapts dynamically via `OrientationBuilder` into an expanded 6-column scientific layout, preserving all ongoing calculation state across device rotations.

---

## 3. State Machine & Invariant Contract

The calculation logic is isolated within `lib/logic/calculator_engine.dart` and governed by four authoritative state variables:
- `double? accumulator`: The authoritative accumulated numeric value.
- `String currentOperand`: Keystrokes for the uncommitted number being entered.
- `String? pendingOperator`: The waiting operator (`+`, `-`, `×`, `÷`).
- `InputPhase inputPhase`: State enum (`enteringFirstOperand`, `waitingForOperand`, `enteringSubsequentOperand`, `showResult`, `error`).

### Derived State
- `displayText` and `formula` are **purely derived** from the authoritative state variables. This eliminates dual-source-of-truth bugs.

### Primary State Invariants
1. When `inputPhase == waitingForOperand`: `accumulator != null`, `pendingOperator != null`, and `currentOperand.isEmpty`.
2. When `inputPhase == enteringSubsequentOperand`: `accumulator != null`, `pendingOperator != null`, and `currentOperand.isNotEmpty`.
3. When `inputPhase == showResult`: `pendingOperator == null`, and `accumulator` holds the exact evaluated result.

---

## 4. Project Structure

```
calculator_app/
├── lib/
│   ├── main.dart                      # Root application entry point with animated theme management
│   ├── models/
│   │   ├── calculator_mode.dart       # RunningTotal vs Precedence enum
│   │   └── history_item.dart          # Calculation history data model
│   ├── logic/
│   │   ├── calculator_engine.dart     # Core L→R state machine and arithmetic rules
│   │   └── expression_evaluator.dart  # Shunting-yard parser for PEMDAS precedence & parentheses
│   └── ui/
│       ├── calculator_screen.dart     # Responsive screen handling portrait & landscape layouts
│       ├── calculator_button.dart     # Animated, tactile, accessible button widget (>=48dp)
│       ├── display_panel.dart         # Formula trace, mode pill, and liveRegion display
│       ├── keypad_grid.dart           # Keypad layouts for Portrait and Landscape modes
│       ├── history_sheet.dart         # Modal bottom sheet for calculation history
│       └── theme_data.dart            # Light and Dark theme specifications
├── test/
│   ├── calculator_engine_test.dart    # Comprehensive unit tests for all state transitions
│   ├── expression_evaluator_test.dart # Tests for PEMDAS precedence, parentheses, and errors
│   └── widget_test.dart               # Flutter UI widget tests for rendering, themes, and accessibility
├── build/app/outputs/flutter-apk/
│   └── app-release.apk                # Release APK build
├── JamalLyons_CalculatorApp.apk       # Deliverable release APK
├── JamalLyons_Implementation.docx     # Deliverable implementation document
└── github_link.txt                    # Deliverable repository link
```

---

## 5. Verification & Test Commands

### Run Static Analysis
```bash
flutter analyze
```
*Result*: `No issues found!`

### Run Automated Unit and Widget Tests
```bash
flutter test
```
*Result*: `All 29 tests passed!`

### Build Release APK
```bash
flutter build apk --release
```
*Result*: Release APK output to `build/app/outputs/flutter-apk/app-release.apk`.
