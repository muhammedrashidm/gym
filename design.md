```markdown
# Design System Document: The Monolithic Editorial

## 1. Overview & Creative North Star
**Creative North Star: "The Architectural Void"**

This design system rejects the cluttered, high-energy tropes of traditional fitness applications. Instead of vibrant blues and chaotic "gamified" elements, we embrace a "Quiet Luxury" aesthetic. The goal is to make gym management feel like flipping through a high-end architectural digest or a premium fashion editorial.

We achieve this through **Organic Brutalism**: a philosophy where sharp, 0px border-radius geometry meets soft, expansive whitespace. The layout is intentionally asymmetrical, treating the screen not as a grid to be filled, but as a canvas where "nothingness" (whitespace) is as functional as the data itself. By removing all standard borders and rounding, we create a sense of permanence, authority, and professional rigor.

---

## 2. Colors & Tonal Depth

The palette is a sophisticated study in monochrome. We move away from the "digital blue" and into "physical slate," mimicking the materials of a premium boutique fitness studio—concrete, brushed steel, and matte charcoal.

### The "No-Line" Rule
**Borders are strictly prohibited for sectioning.** To separate content, designers must use background color shifts. 
- A section using `surface-container-low` (#f3f3f3) sitting on a `background` (#f9f9f9) creates a natural, sophisticated boundary that 1px lines cannot replicate.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked, fine-paper sheets. 
- **Base Level:** `surface` (#f9f9f9)
- **Secondary Level:** `surface-container-low` (#f3f3f3) for secondary content blocks.
- **Priority Level:** `surface-container-lowest` (#ffffff) for primary cards or interactive elements.
- **Deep Slate Accents:** Use `primary` (#000000) and `tertiary` (#3b3b3c) only for high-contrast moments or core CTAs.

### Signature Textures
To avoid a "flat" feel, use a subtle **linear gradient** for primary action areas: 
- From `primary` (#000000) to `primary-container` (#3c3b3b) at a 145-degree angle. This provides a "satin matte" finish that feels premium and tactile.

---

## 3. Typography

Typography is the primary engine of this system. We use a high-contrast scale to create an editorial rhythm.

*   **Display & Headlines (Manrope):** Our "voice." Manrope’s geometric yet warm curves provide the "Luxury" feel. 
    *   *Usage:* Use `display-lg` (3.5rem) with tight letter-spacing (-0.02em) for bold, asymmetrical hero statements.
*   **Body & Labels (Inter):** Our "function." Inter provides maximum readability for complex gym data, member lists, and scheduling.
    *   *Usage:* `body-md` (0.875rem) for all standard data. Ensure a generous line-height (1.6) to maintain the "editorial" breathability.

**Hierarchy Note:** High-contrast typography (Black `on-surface` against Off-White `surface`) is the primary way to guide the user's eye. If a screen feels cluttered, increase the size of the headline and the whitespace around it, rather than adding a divider.

---

## 4. Elevation & Depth

In a world without rounded corners, depth must be handled with extreme precision to avoid looking "flat" or "dated."

*   **The Layering Principle:** Depth is achieved by "stacking" tones. 
    *   *Example:* Place a `surface-container-lowest` (#ffffff) card on top of a `surface-container-high` (#e8e8e8) background. This creates a "soft lift" that feels architectural.
*   **Ambient Shadows:** For floating elements (like modals), use a "Ghost Shadow":
    *   `box-shadow: 0 20px 40px rgba(26, 28, 28, 0.06);` 
    *   The shadow color is a tinted version of `on-surface` (#1a1c1c) at a very low opacity.
*   **The "Ghost Border" Fallback:** If a boundary is required for accessibility, use `outline-variant` (#c6c6c6) at **15% opacity**. Never use a 100% opaque border.
*   **Glassmorphism:** For top navigation bars or floating action buttons, use `surface` (#f9f9f9) at 80% opacity with a `backdrop-blur` of 12px. This makes the UI feel like integrated frosted glass.

---

## 5. Components

### Buttons
*   **Primary:** `primary` (#000000) background, `on-primary` (#e5e2e1) text. **Square corners (0px).** High-padding: `spacing-3` (vertical) and `spacing-6` (horizontal).
*   **Secondary:** `surface-container-highest` (#e2e2e2) background. No border.
*   **Tertiary:** Text only in `primary` (#000000) with a 2px underline using `outline-variant` at 40% opacity.

### Cards & Lists
*   **Strict Rule:** No dividers. 
*   Separate list items using `spacing-4` of vertical whitespace. 
*   For complex gym schedules, use alternating background tints: `surface` vs `surface-container-low`.

### Input Fields
*   **Style:** Minimalist underline style or a subtle `surface-container-highest` (#e2e2e2) solid background. 
*   **Focus State:** The background shifts to `surface-container-lowest` (#ffffff) with a 1px `primary` (#000000) bottom border. No "glow" effects.

### Chips (Class Tags/Status)
*   **Style:** `surface-container-highest` (#e2e2e2) background, `label-md` typography. Rectangular (0px radius). Use for "Yoga," "HIIT," or "Member Status."

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical layouts. Push a headline to the far left and the data to the far right, leaving a "void" in the middle.
*   **Do** use `spacing-16` or `spacing-20` for section margins. Space is a luxury; use it.
*   **Do** use "all-caps" for `label-sm` to create a technical, high-end feel for metadata.

### Don't
*   **Don't** use border-radius. Every element (buttons, cards, inputs) must have a **0px radius**.
*   **Don't** use pure blue, red, or green for anything other than critical errors. Use `secondary` (#5f5e5e) for neutral states.
*   **Don't** use standard icons. Use thin-stroke (1px or 1.5px) monochrome icons to match the Inter typography weight.
*   **Don't** use drop shadows as a default. Use tonal background shifts first. Only use shadows for elements that physically "float" above the page (e.g., Popovers).

---

## 7. Spacing Scale & Rhythm

Use the spacing scale to create a "Pulse." 
- **Large Voids:** Use `spacing-12` (4rem) to separate major sections (e.g., Dashboard Header from Member List).
- **Content Grouping:** Use `spacing-4` (1.4rem) to group related items.
- **Micro-Detail:** Use `spacing-1` (0.35rem) for label-to-input relationships.

The lack of lines makes the **Spacing Scale** the most important tool in your kit. If the UI feels messy, you haven't used enough white space.```