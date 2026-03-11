# Black Notch Panel Implementation Plan

Created: 2026-03-11
Status: VERIFIED
Approved: Yes
Iterations: 0
Worktree: No
Type: Feature

## Summary

**Goal:** Make the NookClone expanded panel use a solid black background so it visually blends with the notch, replacing the current frosted-glass material appearance.
**Architecture:** Single-file change to NookPanelView.swift — swap the material fill for solid black, remove the white border stroke, keep the drop shadow.
**Tech Stack:** SwiftUI

## Scope

### In Scope
- Replace `.ultraThinMaterial` fill with solid `.black` fill on the expanded panel background
- Remove the white border stroke overlay
- Keep the existing drop shadow for depth

### Out of Scope
- Tab bar styling (already uses white-on-dark, will look fine on black)
- Widget content styling (already assumes dark background)
- Notch pill shape (already black)
- Shadow intensity adjustments

## Context for Implementer

> The expanded panel is defined in a single SwiftUI view file.

- **Key file:** `NookClone/Views/NookPanelView.swift` — the root SwiftUI view inside the notch window
- **Current styling (lines 13-19):** `RoundedRectangle` with `.fill(.ultraThinMaterial)`, `.strokeBorder(.white.opacity(0.12))` overlay, and `.shadow(color: .black.opacity(0.45), radius: 24, x: 0, y: 8)`
- **Pattern:** The notch pill (line 50-51) already uses `.fill(.black)` — the expanded panel should match this
- **Gotchas:** `.environment(\.colorScheme, .dark)` is already set on line 40, so all child views already render in dark mode — no child view changes needed

## Assumptions

- White text in WidgetContainerView and widget views will remain readable on solid black — supported by existing `.white` / `.white.opacity(...)` foreground styles throughout the widget system. Task 1 depends on this.
- The drop shadow works well with a black panel against typical macOS wallpapers — supported by the shadow already being dark-toned (`.black.opacity(0.45)`). Task 1 depends on this.

## Testing Strategy

- **Manual verification:** Build and launch the app, hover over the notch to expand the panel, verify:
  1. Panel background is solid black
  2. No visible border stroke
  3. Shadow is visible under the panel
  4. Tab bar text and icons remain readable
  5. Widget content renders correctly

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Panel blends too much with dark wallpapers | Low | Low | Shadow provides depth separation; user already requested this aesthetic |

## Pre-Mortem

*Assume this plan failed. Most likely internal reasons:*
1. **Panel corners visible against light wallpapers** (Task 1) — Trigger: black rounded corners create visible "ears" above the notch. Mitigation: the panel expands downward from the notch, so corners are below the notch area and the shadow handles edge separation.

## Goal Verification

### Truths
1. The expanded panel background is solid black (not translucent/blurred)
2. No white border stroke is visible around the panel
3. The drop shadow is still present under the panel
4. Widget tab bar and content remain legible

### Artifacts
- `NookClone/Views/NookPanelView.swift` — contains the background fill and overlay changes

### Key Links
- `NookPanelView.body` → expanded panel `RoundedRectangle` fill → visual appearance

## Progress Tracking

- [x] Task 1: Replace panel background with solid black
**Total Tasks:** 1 | **Completed:** 1 | **Remaining:** 0

## Implementation Tasks

### Task 1: Replace panel background with solid black

**Objective:** Change the expanded panel's frosted-glass material fill to solid black and remove the white border stroke overlay.
**Dependencies:** None

**Files:**
- Modify: `NookClone/Views/NookPanelView.swift`

**Key Decisions / Notes:**
- Change `.fill(.ultraThinMaterial)` to `.fill(.black)` on line 14
- Remove the entire `.overlay(...)` block (lines 15-18) that draws the white stroke border
- Keep the `.shadow(...)` modifier on line 19 as-is

**Definition of Done:**
- [ ] Panel background uses `.fill(.black)` instead of `.fill(.ultraThinMaterial)`
- [ ] White border stroke overlay is removed
- [ ] Drop shadow is preserved
- [ ] App builds without errors
- [ ] Panel visually blends with the notch when expanded

**Verify:**
- Build: `xcodebuild -project NookClone.xcodeproj -scheme NookClone -configuration Debug build 2>&1 | tail -5`
- Launch app and visually confirm panel appearance
