# dev

[![license](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

Plasma development environments.

## Branching

Shared defaults live on `main`. Collaborators (with write access) should
create a personal branch named after their GitHub username. Use your
personal branch freely; the only rule is to never push to someone else's
branch. Periodically merge `main` into your branch to pick up shared
updates. If you do not have write access, you can fork the repo to
maintain your own version.

## Structure

```
dev/
├── AGENTS.md       # Shared agent instructions (ground truth)
├── agents/         # Generic agent config discovered through .agents/
├── claude/         # Claude Code (CLAUDE.md -> ../AGENTS.md, settings, skills)
├── codex/          # Codex (config.toml, AGENTS.md -> ../AGENTS.md, skills)
├── cursor/         # Cursor settings, keybindings, extensions
├── vscode/         # VS Code settings, keybindings, extensions
├── git/            # Global gitignore
├── ghostty/        # Ghostty terminal config
├── iterm/          # iTerm2 settings
├── starship/       # Starship prompt config
├── zsh/            # Zsh configuration
├── setup.sh        # Machine setup script
└── README.md
```

Personal branches may add additional directories as needed.

`setup.sh` symlinks the agent config (`AGENTS.md`, `agents/`, `claude/`,
`codex/`) into the parent directory so tools find it at the expected
paths (e.g. `../AGENTS.md`, `../CLAUDE.md`, `../.agents`). Existing
non-symlink files are left untouched.

To symlink the agent config (`.agents/`, `.claude/`, `.codex/`) into a
project, run `agentconf <project> [<dev-path>]` from the parent of
`dev/` (or `agentconf` from inside the project). `<dev-path>` defaults
to `../dev`. The function is defined in `zsh/.zshrc`.

The `plan` command (also defined in `zsh/.zshrc`) writes timestamped
plan files to `$PLANS_DIR`, which defaults to `scratch/plans` beside the
`dev` repo (created automatically if missing). Set `PLANS_DIR` in your
environment to put plans elsewhere.

## Setup

The setup script provisions a development machine: Homebrew, CLI tools,
programming languages, AI coding agents, applications, shell
configuration, and editor settings. It auto-detects macOS vs Linux.

> [!NOTE]
> - `--email` and `--github` are required on every run.
> - `--user` defaults to your OS account full name (e.g. "First Last").

> [!WARNING]
> `setup.sh` is opinionated and makes sweeping changes. It runs `sudo`,
> changes your login shell with `chsh`, writes macOS defaults (Dock,
> screenshots, key-repeat), pipes several `curl | bash` installers, and
> installs ~80 Homebrew packages including paid casks (1Password,
> Microsoft Office, Adobe Acrobat Pro, TablePlus).

```shell
chmod +x ./dev/setup.sh

# Full install
./dev/setup.sh --email=<email> --github=<user>

# Headless install (skip GUI apps and editor configuration)
./dev/setup.sh --headless --email=<email> --github=<user>

# Full install, plus TeX/LaTeX (macOS only)
./dev/setup.sh --tex --email=<email> --github=<user>

# Repair symlinks and reconfigure (skip all installs)
./dev/setup.sh --repair --email=<email> --github=<user>
```

Run `./dev/setup.sh --help` to see all options.

You'll be prompted for input at a few points. Most prompts should be
accepted, **except** when asked to modify the `PATH` variable by
changing `.zshrc`.

Following installation, open iTerm2 and navigate via the menu bar to
`iTerm2 > Settings > General > Settings`. Select
`Load settings from a custom folder or URL` and choose
`~/.iterm/settings`. If asked whether to save current settings, choose
"Don't Copy". Restart iTerm2 to load the settings.

## Skills

All agent skills live in `agents/skills/`; `claude/skills/` and
`codex/skills/` are symlinks to it. Through the parent-directory
symlinks created by `setup.sh` and `agentconf`, agents discover the
skills at:

- `.agents/skills/` — read natively by Codex
- `.claude/skills/` — read by Claude Code
- `.codex/skills/` — future-proofing, should Codex add that scan path

Each skill is a subdirectory containing a `SKILL.md` file whose
frontmatter defines `name` and `description`, plus optional fields
such as `argument-hint`.

## License

Licensed under the Apache License 2.0 — see [LICENSE](LICENSE).
