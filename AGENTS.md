# AGENTS

This file provides guidance to coding agents (Claude Code, Codex) when working
with code in this organization. It is the org-wide root file — every repository
under the org loads it alongside its own `AGENTS.md`, so only org-wide guidance
belongs here; repo-specific guidance belongs in each repository's own file.

Especially important points to keep in mind (each expanded in its section
below):

- **Questions are not edit requests.** When a message asks a question without
  explicitly requesting a change, answer and stop (Communication).
- **Write clear and concise English.** Write clear, concise, plain English which
  can be quickly and easily parsed by the user - answer questions directly in
  short form unless elaboration is requested (Writing Style).
- **Seek the best solution, not agreement.** When you think the user is wrong,
  don't be afraid to say so — the right answer matters more than the path of
  least resistance (Pushing Back).

## Workflow

### Git Workflow

- **Do not create git commits unless explicitly asked.** Never auto-commit
  during implementations.
- **Never touch the staging area or stash.** Do not run `git add`, `git reset`,
  `git stash`, `git checkout -- <file>`, `git restore`, `git clean`, or any
  other command that stages, unstages, stashes, or discards changes. The user
  uses the staging area to track approved work — modifying it destroys their
  workflow. This applies even when debugging (e.g. do not stash to test original
  code — use `git show HEAD:<file>` or `git diff HEAD` to inspect the original
  state without modifying the working tree).
- Leave all committing to the user. Make code changes, run tests, run
  pre-commit, but stop before committing.
- **No session identifiers or tool footers in anything published.** Commit
  messages end at the co-author trailer (`Co-Authored-By: ...`) — never append
  session or conversation identifiers, links back into an agent harness, or
  trailers of that kind (e.g. `Claude-Session:`) to commits, PR or issue bodies,
  comments, release notes, or any committed file. Do not add "Generated with
  ..." footers or tool badges to PRs or issues either; the co-author trailer is
  the only attribution that belongs anywhere. Harness trailers found in existing
  git history are a defect being scrubbed, not a pattern to imitate.
- **Exception for fractal.** When running the `/fractal` skill or operating a
  fractal node, commit fractal's own setup/seed/config artifacts autonomously
  and without asking — `fractal init`'s output (`.fractal/` and the wiki
  scaffold it creates), the node seed, and the baseline and child config commits
  the fractal skill instructs you to make. Never ask the user whether to commit
  them. Ordinary project work in the user's main worktree still follows the
  rules above.

### Plan Files

Create every plan with the `plan` command (defined in `dev/zsh/.zshrc` and
symlinked to `~/.zshrc`), which gets the UTC timestamp, writes the file in
`$PLANS_DIR`, and seeds the title and author header for you:

```shell
plan <short_descriptive_name> <agent>
```

- `<short_descriptive_name>` uses underscores and no dashes, except an optional
  trailing `-v{version}` (e.g. `refactor_node_events`,
  `refactor_node_events-v2`); `<agent>` is the agent name with its model in
  parentheses, quoted since it contains spaces (e.g. `"Claude (Fable 5)"` or
  `"Codex (GPT-5.6)"`). The command prints the created path
  (`$PLANS_DIR/<ISO 8601 UTC timestamp>-<name>.md`) — write your plan into that
  file. Do not hand-compute timestamps or use the auto-generated plan-mode
  filename.
- `$PLANS_DIR` defaults to the `scratch/plans` directory beside the `dev` repo;
  override it to point plans elsewhere. Plans from all agents share
  `$PLANS_DIR`.
- The command seeds the file with a title and author header. The seeded title is
  just the name with underscores turned into spaces — rewrite it into a proper
  descriptive title (e.g. `# Refactor Node Event Handling`).

Create a `-v{version}` successor (e.g.
`plan refactor_node_events-v2 "Claude (Fable 5)"`) only when a plan is truly
superseded. Iterating on a plan — feedback rounds, rewrites, restructuring while
the plan is still being shaped — updates the file in place regardless of session
or how substantial the edits are.

After saving a new plan, print its full contents in the conversation so the user
can review it inline. While iterating, print only the changed parts — the
updated sections or new Decision lines — and re-print the whole plan only when
the user asks or a rewrite touches most of the file.

**Save early, update often.** Write the plan file to disk as soon as the first
draft is ready — do not wait for user approval or iteration to complete. Update
the file in place as the plan evolves through feedback. This ensures there is
always a saved artifact even if the conversation is interrupted.

**Questions section.** Plans with open decisions carry a Questions section — see
Asking Questions under Communication for the format and how decisions are
recorded.

**Style pass after implementation.** After completing the first pass of a plan's
implementation, do a thorough style review of all new code. Read the surrounding
files for local patterns, re-read the Consistency section of this file, and
evaluate every new line against both. Fix any deviations before finalizing.

## Consistency

The single most important pattern in this codebase is the pattern of **adhering
to patterns**. Every convention documented here exists so that the code reads as
if one person wrote it. This matters more than any individual style preference
because it enables:

- **Fast visual scanning** — when code follows predictable shapes, deviations
  jump out immediately
- **Regex-based refactoring** — consistent patterns mean find-and-replace works
  across the codebase
- **Trustworthy AI-generated code** — the user must be able to review the
  agent's output and have it look indistinguishable from their own

When writing or modifying code:

1. **Read the surrounding code first.** Match its patterns exactly — variable
   names, comment style, line breaking, method ordering, everything.
2. **Do not silently "improve" patterns.** If the existing code uses a
   particular structure, use that same structure in your current task. But if
   you see a genuinely better convention — clearer, safer, more idiomatic —
   **propose it explicitly.** The priority is consistency, not preservation of
   the status quo. Consistently good beats consistently bad, so make the case
   for why a change is worth the churn and the user will adopt it.
3. **Do not rename variables** that shadow outer scopes if it is sensible to
   reuse that variable name (and is unlikely to become a bug).
4. **Do not reformat** existing comments, reorder methods, or restructure
   working code unless specifically asked.
5. **Do not remove comments.** Line-by-line comments are intentional — they help
   the user maintain order and scan code quickly. Emulate existing comment
   patterns in new code.
6. **When in doubt, emulate.** Find the nearest analogous code in the codebase
   and mirror its structure.
7. **End files with a trailing newline.** Every committed file ends with one —
   the `end-of-file-fixer` hook enforces it.

### Adapting to the Codebase

The patterns documented here are a starting point, not an exhaustive rulebook.
The codebase is the authoritative style guide — these docs just accelerate your
ramp-up.

- **Pattern discovery over pattern memorization.** When working in a file, treat
  the local code as the authority. If a file uses a pattern not documented here,
  adopt it — don't introduce the documented pattern as a "correction."
- **Resolve conflicts in favor of local code.** If a documented pattern
  conflicts with what you see in the file you're editing, follow the file. Flag
  the discrepancy but don't "fix" it unilaterally.
- **New patterns propagate by observation.** The codebase evolves. When you
  encounter a pattern that's clearly intentional but not documented, follow it
  in your new code. The user will correct you if it's a mistake.
- **Scan before writing.** Before adding a new method, class, or module, find a
  few analogous examples in the codebase and mirror their structure. This
  applies to everything: error handling shape, docstring phrasing, test
  organization, import style, comment density.
- **Keep these docs up to date.** When you discover conventions or patterns
  through the user's feedback or codebase observation that aren't yet
  documented, add them to the appropriate `AGENTS.md`: repo-specific conventions
  belong in the repo's own file; org-wide conventions belong in the shared
  sections, which are maintained at the organization level — make shared-section
  changes at the org root (or flag them for promotion) and propagate them to
  repo copies.

**Propose better conventions.** If you see a pattern that could be improved
across the codebase — a more readable structure, a safer error handling
approach, a cleaner naming convention — say so. Explain *why* it's worth the
migration cost. The user values consistency over any particular style, and will
always prefer being consistently good over consistently familiar. The rule is:
don't deviate silently, but do advocate openly.

## Templates

When updating boilerplate files like build configs, linter configs, CI configs,
etc. (e.g. `pyproject.toml`, `.pre-commit-config.yaml`), always check whether
the same change should also be applied to the corresponding `cookiecutter`
template files — whether they live in the `templates` repository, in an in-repo
`templates/` directory, or upstream in the template this project is derived from
(see `.cruft.json`). Templates and the projects derived from them should stay in
sync.

## Scope Discipline

- **Do not add defensive code for impossible cases.** Trust internal code and
  framework guarantees. Only validate at system boundaries — user input,
  external APIs, deserialized data. Adding error handling "just in case" adds
  noise that obscures the cases that actually matter.
- **Do not add abstractions for one-time operations.** A few similar lines of
  code is better than a premature helper function. Build abstractions when the
  third caller arrives, not when the first one does.
- **Do not add features that weren't requested.** No feature flags, no
  backwards-compatibility shims, no "while I'm here" improvements. If something
  adjacent should change, mention it — don't do it silently.
- **Do not leave cleanup artifacts.** No `# removed` comments, no re-exported
  unused symbols, no renamed `_old_thing` variables. If something is unused,
  delete it completely.
- **Do not mix refactoring with implementation.** Deliver the requested change
  against the current code, then propose refactors separately. Mixing the two
  makes review impossible.
- **Do not change signatures of functions you're not tasked with changing.**
  Adding parameters, changing defaults, or renaming arguments in existing
  functions cascades through callers and is a separate task.

## Communication

- **Questions are not edit requests.** Before acting on any message, find the
  words that request action ("fix it", "update X", "go ahead") — if you cannot
  quote them, answer and stop. A question gets an answer, not an edit. That
  holds even when the question implies something is wrong, when you discover a
  real bug while answering, or when the fix seems small and obvious: answer,
  propose the change, and wait for the user to ask. When in doubt, treat the
  message as a question — a proposal costs one turn; an unwanted edit costs a
  revert.
- **Wait for an explicit go-ahead.** An action proposed or offered earlier stays
  pending until the user clearly says to proceed — discussing it or deferring it
  ("before we do that, ...") is not approval, and approval covers only the
  action it names. When iterating, apply only the edits the current message asks
  for, and check that the user is ready before starting anything still queued.
- **Lead with the answer.** When the user asks a question, answer it in the
  first sentence. Provide reasoning and context after, not before. If a task is
  complete, say so — don't narrate what you did step by step unless the user
  asks.
- **Match the answer to the question.** A direct question gets a direct answer —
  a sentence or two of prose, not sections and bullet lists. Add only the
  context that changes what the user does next; skip background they didn't ask
  for. If there is more worth saying, give the short answer first and offer to
  expand.
- **Be direct about uncertainty.** If you're unsure about something, say so
  plainly. "I'm not sure whether X — let me check" is better than hedging
  language that buries the uncertainty. If you made a mistake, state it clearly
  and correct it.
- **Flag first, fix later.** When you notice something wrong that's outside the
  scope of the current task — a bug in adjacent code, an inconsistency in
  naming, a missing edge case — mention it. Do not fix it unilaterally. The user
  tracks their own priorities.

### Writing Style

Write all conversational prose — chat replies, questions, plans — in clear,
concise, plain English that is easy to read. Plain does not mean imprecise —
technical terms stay. These rules govern how sentences read, not what they say.
Docs, commit messages, and code comments follow local conventions.

- **Short sentences, common words.** One idea per sentence. Prefer the simple
  word over the impressive one.
- **Front-load the point.** Conclusion first, reasoning after.
- **Concrete over abstract.** Name the file, the command, the number.
- **No unexplained jargon.** Expand abbreviations on first use; define terms the
  reader may not know.
- **No flourishes.** No metaphors, no rhetorical buildup, no cleverness.
- **Cut content, not grammar.** Concision comes from dropping less-important
  points, never from compressing sentences into jargon fragments. Every sentence
  that survives stays a plain subject-verb sentence describing what actually
  happens in clear, plain English.
- **The two-read test.** If a sentence needs a second read, rewrite it.

### Asking Questions

When decisions need the user's input — design choices, competing approaches,
ambiguous requirements — batch them into questions the user can answer without
looking anywhere else. Print them in plain text in chat rather than through a
clickable question prompt; save such prompts for a single quick blocking fork
mid-execution.

- **Groups, questions, options.** Group questions under lettered headings (A, B,
  C, ...), each with a short blurb at the top, when a large batch needs the
  extra structure. Ungrouped is the default — don't group a short list
  (single-question groups are allowed but discouraged). Number questions with
  their group letter (A1, A2, ..., B1, B2, ...), or plainly (1, 2, 3, ...) when
  there are no groups. Give each question lettered options (a, b, c, ...), where
  (a) is always the recommendation.
- **One decision per question.** Do not combine decisions unless their answers
  are structurally correlated — one answer clearly implies the others.
- **Summary first.** Start each question with a one-sentence summary in italics,
  separated from longer context by a newline.
- **Self-contained context.** Give every question and option enough context to
  decide without opening files or scrolling back.
- **Scale down.** With one group, drop the group letter and blurb. With one
  question, keep just the italic summary, context, and lettered options.

In plans, record open decisions in a Questions section, usually the last
section, and still print them in chat for the user to answer. Update the plan in
place as each decision lands: mark the question DECIDED in its heading or
summary line and append a bold **Decision:** line with the choice and any
modifications. Open questions are the ones without a Decision line.

## Pushing Back

The user is sometimes wrong, and quiet compliance produces bad code that the
user later has to undo. When you think the user is wrong:

- **Say so plainly.** "I think you're wrong about X — here's why" beats silently
  going along. The user prefers being told they're wrong over being agreed with
  falsely.
- **Distinguish misreads from disagreements.** If the user misunderstood a piece
  of code, restate what you think they meant and what's actually there. If you
  disagree on direction, lay out the reasoning.
- **Hold ground when you have evidence.** Do not fold at the first sign of
  pushback. The right answer matters more than the path of least resistance.
- **Concede when convinced.** When the user produces a reason you hadn't
  considered, say so explicitly. This is calibration, not weakness.

## Thinking Before Coding

For non-trivial tasks, lead with planning, not code:

- **Surface assumptions.** State what you're assuming before you implement. If
  something is unclear, ask — a five-second question beats a five-minute
  reversal.
- **Present alternatives instead of picking silently.** When a request has
  multiple reasonable interpretations, lay them out for the user to choose.
- **Define success criteria upfront.** "Add validation" is weak; "tests for
  invalid inputs pass" is strong. For multi-step work, sketch a brief plan with
  verifiable checks per step.
- **Apply the surgical-change test.** Every changed line should trace directly
  back to the user's request. If you can't justify a line, remove it.
- **Push back on overcomplication.** If the requested approach is more complex
  than the problem demands, say so before writing 200 lines.
- **Verify the current state before changing it.** Read the function, class, or
  module you're about to modify — don't assume its structure from memory or from
  a similar file.

## Testing

### Philosophy

Prefer ground-up test rewrites over incremental patches — design the test suite
that *should* exist from first principles rather than patching existing tests.

**Test behavior, not implementation.** The question a test should answer is
"does the code work?" — not "is the code implemented exactly how it's
implemented right now?" Expect frequent renaming, restructuring, and
refactoring. Tests that are tightly coupled to internal structure (checking
specific attribute names, exact method call sequences, or internal state) break
constantly and provide little value. Tests that verify end-to-end behavior
survive refactors.

**Fewer, better tests.** Prefer a smaller number of end-to-end test cases that
exercise real workflows over a large number of trivial unit tests. A single test
that constructs real objects, exercises them through a realistic scenario, and
verifies the output tests more meaningful behavior than ten tests that
individually check field initialization. When a test can only fail if the code
it tests is also changed in the same commit, it's testing implementation, not
behavior — remove it.

**Readability and parameterization.** Tests should be readable as documentation
of what the code does. Use the language's native parameterization or data-driven
testing mechanisms to cover variations instead of duplicating test functions
with different constants. Avoid random magic numbers — use descriptive variable
names or setup helpers that make the test's intent clear.

**Red before green across boundaries.** A failing test that must land before its
fix — crossing a commit or merge boundary — carries the test framework's strict
expected-failure marker naming the reason; the fix commit removes the marker,
and strict mode makes a lingering marker fail the suite. A red-then-fix chain
inside a single change stays bare-red and never commits red.

### Good Tests

- **Tests a real workflow:** constructs objects, exercises them, checks
  observable results
- **Survives refactors:** doesn't break when internals are renamed or
  restructured
- **Has a clear purpose:** the test name and body make it obvious what behavior
  is being verified
- **Uses parameterization:** variations are covered via data-driven patterns,
  not copy-pasted functions
- **Avoids mocking internals:** mock external boundaries (network, filesystem)
  but not internal classes

### Bad Tests

- Tests that check exact internal/private state rather than observable behavior
- Tests that duplicate another test with a trivially different input
- Tests that only verify string representation or debug output format
- Tests that test the testing infrastructure itself (helpers testing helpers)
- Tests where the assertion is essentially restating the implementation
