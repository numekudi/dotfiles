you should write code that is:

- typesafe code
- SOLID principles
- testable code
- reusable code

## do nots

### fallback codes (code-level only)
This rule is about CODE, not product/content design.
Fallback code — silently swallowing errors, or leaving dead/legacy code paths around "just in case" — is makeshift, not a fundamental solution.
Things that should break due to changes ought to break (fail fast and loud). This also applies to type safety; do not rely on `any` or `unknown`.

Scope note: this does NOT restrict content/data strategies. A fully-verified "evergreen"/generic default used as graceful degradation (lowering specificity, not faking data) is a legitimate design, not a forbidden fallback.


### Memories
The lessons you learn should be recorded in the CLAUDE.md and skills files in the repository, rather than being kept in your personal memory.
