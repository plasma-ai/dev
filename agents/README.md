# Shared Agent Skills

`dev/agents/skills/` is the canonical skills directory, symlinked into
both `.claude/skills/` and `.codex/skills/` (and read natively as
`.agents/skills/`). All three paths resolve to the same directory.

## Why this works

Both Claude Code and Codex implement the
[Agent Skills](https://agentskills.io) open standard. Each skill is a
directory with a `SKILL.md` file (YAML frontmatter + Markdown body). The
tools extend the base spec differently:

- **Claude Code** adds top-level frontmatter fields
  (`disable-model-invocation`, `context`, `model`, `effort`, `hooks`,
  `paths`, `arguments`, etc.)
- **Codex** uses a sidecar file (`agents/openai.yaml`) for UI metadata,
  policy, and dependencies

Neither tool looks for the other's extensions. Codex silently ignores
unknown frontmatter fields (its Rust parser uses serde defaults, no
`deny_unknown_fields`). Claude ignores `agents/openai.yaml` because it
never looks for it. So a single SKILL.md can carry the union of both
tools' config.

## Skill directory structure

```
my-skill/
  SKILL.md              # Shared — union of both tools' frontmatter
  agents/openai.yaml    # Codex-specific (ignored by Claude)
  scripts/              # Optional (spec-defined, not enforced)
  references/           # Optional (spec-defined, not enforced)
  assets/               # Optional (spec-defined, not enforced)
```

## Wrinkles

**Spec validator rejects unknown fields.** The `skills-ref validate`
tool has an explicit allowlist and treats Claude-specific top-level
frontmatter as errors. Skills will pass both runtimes but fail the
official linter. The spec's intended extension point is the `metadata`
map, not top-level fields -- Claude Code deviates from this.

**Future risk.** Codex could add `deny_unknown_fields` to its parser,
which would break skills with Claude-specific frontmatter. This seems
unlikely given the sidecar design, but it is not guaranteed by the spec.

**Codex symlink is redundant.** Codex natively reads `.agents/skills/`,
so the `.codex/skills/` symlink is unnecessary today. It is included for
symmetry and to future-proof against Codex adding a `.codex/skills/`
scan path. Codex deduplicates by resolved path, so it will not
double-load skills if it finds them through both directories.

**No write contamination.** Neither tool writes into repo skill
directories. Codex writes `.system/` files to `~/.codex/skills/`, not to
the project. Symlinks are safe.
