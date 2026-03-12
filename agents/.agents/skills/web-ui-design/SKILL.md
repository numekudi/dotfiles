---
name: web-ui-design
description: Guide for designing user interfaces.
---
## Prohibited Practices

- **No cards**: Do not use card-based layouts with bordered or elevated containers to group content. Use flat, open layouts instead.
- **No gradients**: Do not apply gradient fills to backgrounds, buttons, or any UI elements. Use solid, flat colors only.
- **No emoji**: Do not use emoji characters anywhere in the interface, including headings, labels, buttons, or body text.
- **No icons in section titles**: Do not place icons alongside or within section headings. Section titles must be text-only.
- **No low-contrast combinations**: Do not use color pairings that result in insufficient contrast. All text and interactive elements must meet or exceed WCAG AA contrast ratios (4.5:1 for normal text, 3:1 for large text and UI components).

## Recommended Practices

- **Object-Oriented UI (OOUI)**: Design interfaces around objects that users recognize and manipulate directly. Structure screens so that objects are presented first, and actions are associated with those objects. This reduces cognitive load and aligns the interface with the user's mental model rather than organizing by tasks or system functions.
- **OKLCH Color Space**: Define all colors using the OKLCH color space (`oklch()` in CSS). OKLCH provides perceptually uniform lightness, making it easier to create consistent, accessible color palettes. Use the lightness channel to guarantee contrast requirements and the chroma and hue channels to build harmonious, predictable color systems.

## maintainability
- use CSS variables for color and spacing values to make it easy to update them across the interface.
- Don't repeat yourself (DRY) — define shared styles and components in reusable modules.
