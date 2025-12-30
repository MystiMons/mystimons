# Keyword Pools

Keyword pools define which **keywords** are legal for a given set.

- **allowed**: expected to appear in the set at meaningful density
- **experimental**: may appear, but must be monitored for exploits and UX burden
- **banned**: explicitly not allowed in the set (usually for spoiler-gates or complexity control)

## Source of truth
Canonical pools live in: `03_TCG/AUTHORING/KEYWORD_POOLS/*.keyword_pool.json`

For convenience, each set folder contains a copy at:
`03_TCG/sets/SET-XXX/keyword_pool.json`

If they diverge, **AUTHORING wins**; regenerate the set copy.

## Keyword definitions
Canonical keyword definitions live in:
`03_TCG/AUTHORING/KEYWORDS/keywords.json`

(Registry markdown in `01_REGISTRY/keywords/` may exist for human reading, but does not drive tooling.)
