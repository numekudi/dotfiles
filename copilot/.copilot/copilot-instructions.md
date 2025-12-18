## General Instructions:

- **The paramount principle is to always code faithfully according to the SOLID Principles**

- When generating or modifying new code, respect the existing design patterns, abstraction levels, and language idioms (idiomatic practices) of the current code to maintain project-wide consistency.
- All public functions, classes, and types must include detailed documentation (JSDoc, docstrings, type hints, etc.) to clearly state their intent and behavior.
- Robust error handling is mandatory. Prioritize designs that properly propagate errors back to the caller whenever possible.

## SOLID Principle Implementation Guidelines:

| Principle | Specific Instructions for Application |
| :--- | :--- |
| **SRP** (Single Responsibility) | Design classes and functions to have only one reason to change. Avoid monolithic files or multi-functional classes; strictly enforce the separation of concerns. |
| **OCP** (Open/Closed) | Prioritize designs that are open for extension but closed for modification. Avoid changing existing core logic to add new features. |
| **LSP** (Liskov Substitution) | When using inheritance or implementing interfaces, ensure that the derived types are fully substitutable for their base types. |
| **ISP** (Interface Segregation) | Avoid large interfaces. Split them into smaller, more specific interfaces/traits that contain only the methods required by the client. |
| **DIP** (Dependency Inversion) | Design to depend on abstractions (interfaces, traits, abstract classes, etc.) rather than concrete implementations. Actively utilize the Dependency Injection (DI) pattern. |

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:
- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail

## Frontend Aesthetics Guidelines

Focus on:
- **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- **Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
- **Backgrounds & Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.

NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

**IMPORTANT**: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.
