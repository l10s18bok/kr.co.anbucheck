# Design System Strategy: The Gentle Guardian

## 1. Overview & Creative North Star
This design system is built upon the Creative North Star: **"The Gentle Guardian."** 

Unlike standard utility apps that feel clinical or purely functional, this system adopts a **High-End Editorial** approach. We are moving away from the "grid-of-boxes" aesthetic toward a layout that feels like a premium lifestyle publication—breathable, authoritative, and deeply human. By leveraging intentional asymmetry, high-contrast typography scales, and sophisticated tonal layering, we create an environment that feels safe for seniors and professional for guardians.

The goal is to provide "Digital Warmth." We replace harsh borders with soft transitions and use oversized, elegant typography to ensure that clarity never comes at the expense of beauty.

---

## 2. Colors & Atmospheric Tones
The palette is divided into two distinct emotional modes, unified by a clean, neutral foundation.

### Mode Logic
*   **Senior Mode (Teal - `primary`):** Focused on serenity. Use `#00685e` to anchor the experience in calm and safety.
*   **Guardian Mode (Indigo - `secondary`):** Focused on reliability. Use `#4355b9` to convey clinical precision and attentive care.

### The "No-Line" Rule
Standard UI relies on 1px borders to separate content. **In this system, 1px solid borders are prohibited for sectioning.** Boundaries must be defined through:
1.  **Background Color Shifts:** Use `surface-container-low` sections sitting on a `surface` background.
2.  **Tonal Transitions:** Defining the edge of a card through a subtle shift from `surface-container-lowest` to `surface-container`.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. 
*   **Base:** `surface` (#f9f9f9)
*   **Sectioning:** `surface-container-low` (#f3f3f3)
*   **Interactive Cards:** `surface-container-lowest` (#ffffff)
This nesting creates "soft depth," making the interface feel tactile and premium rather than flat.

### Signature Textures & Glassmorphism
To avoid an "out-of-the-box" Material feel, use **Glassmorphism** for floating headers or navigation bars. Use `surface` at 80% opacity with a `backdrop-blur`. For primary CTAs, apply a subtle linear gradient from `primary` (#00685e) to `primary_container` (#008377) to add "visual soul."

---

## 3. Typography: The Editorial Voice
Typography is our primary tool for accessibility. We use a dual-font strategy to balance character with legibility.

*   **Display & Headlines (Plus Jakarta Sans):** Used for high-impact moments. The generous x-height and modern curves of Plus Jakarta Sans provide an authoritative yet friendly tone.
    *   *Example:* `headline-lg` (2rem) for greeting the user.
*   **Body & Labels (Lexend):** Designed specifically to reduce cognitive load. Lexend’s hyper-legible letterforms are essential for senior users.
    *   *Example:* `body-lg` (1rem) for all status updates to ensure maximum readability.

**Hierarchy Strategy:** Use extreme scale contrast. A `display-sm` headline paired with a `label-md` creates an editorial look that guides the eye naturally, preventing the "wall of text" frustration often felt by seniors.

---

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are often messy. We achieve hierarchy through **Tonal Layering**.

*   **The Layering Principle:** Instead of a shadow, place a `surface-container-lowest` card on top of a `surface-container-high` background. This creates a natural "lift."
*   **Ambient Shadows:** When an element must float (e.g., a bottom sheet or FAB), use an "Ambient Shadow":
    *   *Value:* 0px 12px 32px
    *   *Color:* `on-surface` at 4-6% opacity. This mimics natural light.
*   **The "Ghost Border" Fallback:** If accessibility requires a stroke, use the `outline-variant` token at 15% opacity. Never use 100% opaque outlines.

---

## 5. Components: Principles of Interaction

### Primary Action Surfaces (Buttons)
*   **Style:** Use `rounded-xl` (1.5rem) for a friendly, pill-like shape that is easy to target.
*   **Senior Mode:** `primary` background with `on-primary` text.
*   **Guardian Mode:** `secondary` background with `on-secondary` text.
*   **Sizing:** Minimum height of 64px to accommodate decreased motor precision.

### Floating Information Cards
*   **Rule:** Forbid the use of divider lines.
*   **Spacing:** Use `spacing.8` (2.75rem) to separate content blocks within a card.
*   **Structure:** Use `surface-container-lowest` with a `rounded-lg` (1rem) corner radius. 

### Status Inputs & Selection
*   **Checkboxes & Radios:** Scaled up by 1.2x. Use `primary-fixed` backgrounds for checked states to provide a soft, non-aggressive "active" feel.
*   **Input Fields:** Use a "filled" style with `surface-container-highest` and no bottom line. The focus state should be a 2px "Ghost Border" using the `primary` token.

### Senior-Specific Components
*   **The "Check-In" Pulse:** A large, circular component using nested `primary-container` and `primary-fixed` rings with a slow, breathing scale animation.
*   **Status Timeline:** Instead of a thin line, use vertical spacing (`spacing.10`) and large icons to show chronological events.

---

## 6. Do’s and Don’ts

### Do
*   **Do** use `spacing.6` (2rem) as your default "breathing room" between major elements.
*   **Do** use `plusJakartaSans` for numbers—it provides a high-end, tabular feel for health metrics.
*   **Do** ensure all touch targets are at least 48x48dp, even if the visual element is smaller.
*   **Do** use "Warm Haptics"—combine visual transitions with subtle haptic feedback for confirmed actions.

### Don’t
*   **Don’t** use pure black (#000000). Use `on-surface` (#1a1c1c) to keep the contrast soft on aging eyes.
*   **Don’t** use "Alert Red" for everything. Use `error-container` for warnings to keep the atmosphere "Safe" rather than "Alarming."
*   **Don’t** crowd the screen. If it doesn't fit with `spacing.4`, it belongs on a different screen or a progressive disclosure layer.
*   **Don’t** use center-aligned long-form text. Keep body copy left-aligned for better readability (F-pattern).

---

## 7. Spacing & Rhythm
Rhythm is maintained through a strict adherence to the spacing scale.
*   **Layout Margins:** Always use `spacing.5` (1.7rem) for horizontal mobile margins.
*   **Vertical Stacking:** Use `spacing.8` (2.75rem) to separate distinct functional groups.
*   **Component Internal Padding:** Use `spacing.4` (1.4rem) to ensure elements inside cards feel luxurious and uncrowded.