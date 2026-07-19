#!/usr/bin/env bash
set -euo pipefail

# Set up a development machine (auto-detects macOS vs Linux)
# ----------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# detect platform
OS="$(uname -s)"
MACOS=false
LINUX=false
if [[ "$OS" == "Darwin" ]]; then
    MACOS=true
elif [[ "$OS" == "Linux" ]]; then
    LINUX=true
else
    echo "Error: unsupported platform: $OS" >&2
    exit 1
fi
if [[ "$MACOS" == true && "$(uname -m)" != "arm64" ]]; then
    echo "Error: macOS setup requires Apple Silicon (arm64): detected $(uname -m)" >&2
    exit 1
fi

# parse options
GIT_USER=""
GIT_EMAIL=""
GITHUB_USER=""
SSH_KEY=""
SIGNING_KEY=""
HEADLESS=false
TEX=false
REPAIR=false

usage() {
    cat <<USAGE
Usage: setup.sh [options]

Set up a development machine (auto-detects macOS vs Linux).

Options:
    --user <user>           Git user name (default: OS account full name)
    --email <email>         Git user email (required)
    --github <user>         GitHub account for this workspace (required)
    --ssh-key <path>        SSH key for this workspace's repos (sets core.sshCommand)
    --signing-key <path>    SSH signing key for this workspace (signs commits)
    --headless              Skip GUI apps and editor configs (no effect on Linux)
    --tex                   Also install TeX/LaTeX (macOS only)
    --repair                Re-link configs only (skip all installs)
    --help|-h               Show this help message
USAGE
    exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --help | -h) usage ;;
        --user | --user=*)
            if [[ "$1" == *=* ]]; then
                GIT_USER="${1#*=}"
                shift
            elif [[ $# -ge 2 ]]; then
                GIT_USER="$2"
                shift 2
            else
                echo "Error: --user requires a value" >&2
                usage 1
            fi
            ;;
        --email | --email=*)
            if [[ "$1" == *=* ]]; then
                GIT_EMAIL="${1#*=}"
                shift
            elif [[ $# -ge 2 ]]; then
                GIT_EMAIL="$2"
                shift 2
            else
                echo "Error: --email requires a value" >&2
                usage 1
            fi
            ;;
        --github | --github=*)
            if [[ "$1" == *=* ]]; then
                GITHUB_USER="${1#*=}"
                shift
            elif [[ $# -ge 2 ]]; then
                GITHUB_USER="$2"
                shift 2
            else
                echo "Error: --github requires a value" >&2
                usage 1
            fi
            ;;
        --ssh-key | --ssh-key=*)
            if [[ "$1" == *=* ]]; then
                SSH_KEY="${1#*=}"
                shift
            elif [[ $# -ge 2 ]]; then
                SSH_KEY="$2"
                shift 2
            else
                echo "Error: --ssh-key requires a value" >&2
                usage 1
            fi
            ;;
        --signing-key | --signing-key=*)
            if [[ "$1" == *=* ]]; then
                SIGNING_KEY="${1#*=}"
                shift
            elif [[ $# -ge 2 ]]; then
                SIGNING_KEY="$2"
                shift 2
            else
                echo "Error: --signing-key requires a value" >&2
                usage 1
            fi
            ;;
        --headless)
            HEADLESS=true
            shift
            ;;
        --tex)
            TEX=true
            shift
            ;;
        --repair)
            REPAIR=true
            shift
            ;;
        *)
            echo "Error: unknown option: $1" >&2
            usage 1
            ;;
    esac
done
if [[ "$TEX" == true && "$MACOS" != true ]]; then
    echo "Error: --tex requires macOS" >&2
    exit 1
fi
if [[ -z "$GIT_EMAIL" ]]; then
    echo "Error: --email is required" >&2
    exit 1
fi
if [[ -z "$GITHUB_USER" ]]; then
    echo "Error: --github (GitHub username) is required" >&2
    exit 1
fi
if [[ -z "${USER:-}" ]]; then
    echo "Error: \$USER is not set" >&2
    exit 1
fi

# resolve git user name
if [[ "$MACOS" == true ]]; then
    NAME="$(id -F)"
elif [[ "$LINUX" == true ]]; then
    NAME="$(getent passwd "$USER" | cut -d: -f5 | cut -d, -f1)"
fi
NAME="${NAME:-$USER}"
GIT_USER="${GIT_USER:-$NAME}"

# ------ system preferences

if [[ "$MACOS" == true && "$REPAIR" == false ]]; then
    defaults write com.apple.dock workspaces-auto-swoosh -bool false
    killall Dock || true
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    defaults write com.apple.screencapture location ~/Downloads
    killall SystemUIServer || true
    sudo softwareupdate --install-rosetta --agree-to-license
fi

# ------ homebrew

# set brew prefix
if [[ "$MACOS" == true ]]; then
    BREW_PREFIX="/opt/homebrew"
elif [[ "$LINUX" == true ]]; then
    BREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# install brew
if [[ "$REPAIR" == false ]]; then
    echo "==> installing brew"
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Reusing existing brew install; run 'brew update' to refresh"
    fi
fi
# add brew to PATH for this script
if [[ ! -x "${BREW_PREFIX}/bin/brew" ]]; then
    echo "Error: brew not found at ${BREW_PREFIX}/bin/brew" >&2
    exit 1
fi
eval "$("${BREW_PREFIX}"/bin/brew shellenv)"
# add brew shellenv to .zprofile for non-interactive login shells
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
    (
        echo
        echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\""
    ) >>"$HOME/.zprofile"
    echo "Added brew shellenv to ~/.zprofile"
fi

# install packages
if [[ "$REPAIR" == false ]]; then
    # install Zsh and plugins
    brew install zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
    # install starship prompt
    brew install starship
    # install command-line tools
    brew install tree bat ripgrep fd fzf zoxide cloc tokei jq yq xh httpie
    # install shell tools
    brew install shellcheck shfmt direnv
    # install system tools
    brew install htop btop tmux
    # install Git tools
    brew install git git-lfs git-delta lazygit
    # install GitHub CLI
    brew install gh
    # install GNU tools
    brew install coreutils wget gawk gnu-sed gnu-getopt gettext gnuplot
    # install build tools
    brew install make cmake pkg-config openssl
    # install compilers
    brew install llvm gcc
    # install Javascript tools
    brew install node yarn pnpm
    # install Vim and Neovim
    brew install vim neovim
    # install Python tools
    brew install pyenv pyenv-virtualenv uv pre-commit
    # install Sphinx
    brew install sphinx-doc
    # install AWS CLI
    brew install awscli
    # install AI tools
    curl -fsSL https://claude.ai/install.sh | bash
    curl -fsSL https://chatgpt.com/codex/install.sh | bash
    brew install opencode
fi

# install macOS desktop apps
if [[ "$MACOS" == true ]] && [[ "$HEADLESS" == false ]] && [[ "$REPAIR" == false ]]; then
    # install terminals
    brew install --cask ghostty
    brew install --cask iterm2
    # install editors
    brew install --cask visual-studio-code
    brew install --cask cursor
    brew install --cask obsidian
    # install AI tools
    brew install --cask claude
    brew install --cask chatgpt
    # install dev tools
    brew install --cask github
    brew install --cask docker
    brew install --cask tableplus
    brew install --cask postman
    # install utilities
    brew install --cask 1password
    brew install --cask 1password-cli
    brew install --cask rectangle
    brew install --cask monitorcontrol
    # install productivity apps
    brew install --cask granola
    brew install --cask notion
    brew install --cask linear-linear
    brew install --cask microsoft-office
    brew install --cask adobe-acrobat-pro
    # install communication apps
    brew install --cask slack
    brew install --cask zoom
    brew install --cask microsoft-teams
fi

# install LaTeX (macOS only)
if [[ "$TEX" == true && "$REPAIR" == false ]]; then
    brew install --cask mactex
    brew install --cask tex-live-utility
fi

# clean up Homebrew
if [[ "$REPAIR" == false ]]; then
    echo "==> cleaning up brew"
    brew cleanup
    brew doctor || echo "Warning: brew doctor reported issues; re-run 'brew doctor' later if something breaks" >&2
fi

# ------ shell

# install Oh My Zsh and extensions
if [[ "$REPAIR" == false ]]; then
    echo "==> installing oh-my-zsh"
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Reusing existing ~/.oh-my-zsh; delete it and re-run to refresh"
    fi
    if ! grep -qx "$(command -v zsh)" /etc/shells 2>/dev/null; then
        sudo sh -c "echo $(command -v zsh) >> /etc/shells"
    fi
    if [[ "$SHELL" != "$(command -v zsh)" ]]; then
        chsh -s "$(command -v zsh)" || echo "Warning: could not change login shell; run 'chsh -s $(command -v zsh)' later" >&2
    fi

    # clone or update Oh My Zsh extensions
    echo "==> configuring oh-my-zsh extensions"
    ZSH_COMPLETIONS="$HOME/.oh-my-zsh/custom/plugins/zsh-completions"
    if [[ ! -d $ZSH_COMPLETIONS ]]; then
        git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_COMPLETIONS"
    else
        git -C "$ZSH_COMPLETIONS" pull
    fi
    ZSH_AUTOSUGGESTIONS="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    if [[ ! -d $ZSH_AUTOSUGGESTIONS ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AUTOSUGGESTIONS"
    else
        git -C "$ZSH_AUTOSUGGESTIONS" pull
    fi
    ZSH_SYNTAX_HIGHLIGHTING="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    if [[ ! -d $ZSH_SYNTAX_HIGHLIGHTING ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING"
    else
        git -C "$ZSH_SYNTAX_HIGHLIGHTING" pull
    fi
fi

# suppress last login time
touch ~/.hushlogin

# symlink zsh config
echo "==> configuring zsh"
ln -sfn "$(pwd)/zsh/.zshrc" ~/.zshrc
echo "Linked ~/.zshrc -> zsh/.zshrc"

# symlink starship config
echo "==> configuring starship"
mkdir -p ~/.config
ln -sfn "$(pwd)/starship/starship.toml" ~/.config/starship.toml
echo "Linked ~/.config/starship.toml -> starship/starship.toml"

# symlink ghostty config
echo "==> configuring ghostty"
mkdir -p ~/.config/ghostty
ln -sfn "$(pwd)/ghostty/config" ~/.config/ghostty/config
echo "Linked ~/.config/ghostty/config -> ghostty/config"

# ------ iterm

if [[ "$MACOS" == true && "$HEADLESS" == false ]]; then
    echo "==> configuring iterm"
    mkdir -p ~/.iterm/settings
    for f in iterm/*.plist; do
        ln -sfn "$(pwd)/$f" ~/.iterm/settings/"$(basename "$f")"
        echo "Linked ~/.iterm/settings/$(basename "$f") -> $f"
    done
    if [[ "$REPAIR" == false ]]; then
        curl -fsSL https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
    fi
fi

# ------ git

echo "==> configuring git"
if [[ -f ./git/.gitignore ]]; then
    ln -sfn "$(pwd)/git/.gitignore" ~/.gitignore
    git config --global core.excludesfile ~/.gitignore
    echo "Linked ~/.gitignore -> git/.gitignore"
fi
if [[ -d .git && -d agents ]]; then
    mkdir -p .git/info
    EXCLUDE=.git/info/exclude
    START="# >>> Agent skills (symlinks) >>>"
    END="# <<< Agent skills (symlinks) <<<"
    PRESERVED=""
    [[ -f "$EXCLUDE" ]] && PRESERVED="$(awk -v s="$START" -v e="$END" 'i{if($0==e)i=0;next} $0==s{i=1;next} 1' "$EXCLUDE")"
    {
        [[ -n "$PRESERVED" ]] && printf '%s\n\n' "$PRESERVED"
        echo "$START"
        find agents -type l | sort
        echo "$END"
        echo
    } >"$EXCLUDE"
    echo "Wrote agent skill symlinks to $EXCLUDE"
fi
git config --global user.useConfigOnly true

# scope git identity to this dev repo's workspace via a conditional
# include, so every repo under the workspace uses it and each workspace
# (e.g. plasma vs plasma-internal) keeps its own; no global identity is
# set, so with user.useConfigOnly a repo outside any configured workspace
# must declare its own name/email rather than fall back to a wrong default
WORKSPACE_DIR="$(cd .. && pwd)"
WORKSPACE_GITCONFIG="$HOME/.config/git/$(basename "$WORKSPACE_DIR").gitconfig"
mkdir -p "$(dirname "$WORKSPACE_GITCONFIG")"
echo "# $WORKSPACE_DIR" >"$WORKSPACE_GITCONFIG"
git config --file "$WORKSPACE_GITCONFIG" user.name "$GIT_USER"
git config --file "$WORKSPACE_GITCONFIG" user.email "$GIT_EMAIL"
git config --file "$WORKSPACE_GITCONFIG" github.user "$GITHUB_USER"
# pin the HTTPS credential username so fetch/push hit this workspace's GitHub account
git config --file "$WORKSPACE_GITCONFIG" "credential.https://github.com.username" "$GITHUB_USER"
# use a dedicated SSH key so fetch/push hit this workspace's GitHub account
if [[ -n "$SSH_KEY" ]]; then
    git config --file "$WORKSPACE_GITCONFIG" core.sshCommand "ssh -i $SSH_KEY -o IdentitiesOnly=yes"
fi
# sign commits with this workspace's SSH signing key
if [[ -n "$SIGNING_KEY" ]]; then
    git config --file "$WORKSPACE_GITCONFIG" gpg.format ssh
    git config --file "$WORKSPACE_GITCONFIG" user.signingkey "$SIGNING_KEY"
    git config --file "$WORKSPACE_GITCONFIG" commit.gpgsign true
fi
git config --global "includeIf.gitdir:$WORKSPACE_DIR/.path" "$WORKSPACE_GITCONFIG"
echo "Wrote workspace git identity to $WORKSPACE_GITCONFIG"

git config --global init.defaultBranch 'main'
git config --global pull.rebase false
git config --global core.fileMode false
git config --global alias.update '!update() {
    git fetch --all && git pull
}; update'
# shellcheck disable=SC2016  # literal $d/$@ expand inside the git alias, not here
git config --global alias.all '!all() {
    for d in */; do
        git -C "$d" rev-parse --git-dir >/dev/null 2>&1 && {
            echo "== ${d%/} =="
            git -C "$d" "$@"
        }
    done
}; all'
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
if [[ "$MACOS" == true ]]; then
    git config --global credential.helper osxkeychain
fi
echo "Wrote global git defaults to ~/.gitconfig"

# ------ python

if [[ "$REPAIR" == false ]]; then
    # load Python version variables from .zshrc
    eval "$(grep -E '^export PYTHON_(STABLE|LATEST)=' ~/.zshrc)"
    if [[ -z "${PYTHON_STABLE:-}" ]]; then
        echo "Error: PYTHON_STABLE not found in ~/.zshrc" >&2
        exit 1
    elif [[ -z "${PYTHON_LATEST:-}" ]]; then
        echo "Error: PYTHON_LATEST not found in ~/.zshrc" >&2
        exit 1
    fi
    # install pyenv versions
    echo "==> installing pyenv versions"
    eval "$(pyenv init - --no-rehash zsh)"
    pyenv install --skip-existing "$PYTHON_STABLE"
    pyenv install --skip-existing "$PYTHON_LATEST"
    pyenv global "$PYTHON_STABLE"
fi

# ------ poetry

if [[ "$REPAIR" == false ]]; then
    echo "==> installing poetry"
    curl -sSL https://install.python-poetry.org | python3 -
fi

# ------ agent config

# link the shared agent config into the parent workspace. Absolute targets keep
# this working whatever the repo is named; existing real files are left untouched.
agentlink() {
    if [[ -e "$2" && ! -L "$2" ]]; then
        echo "skipping $2 (exists and is not a symlink)"
        return
    fi
    ln -sfn "$1" "$2"
    echo "Linked $2 -> $1"
}
agentlink "$(pwd)/AGENTS.md" ../AGENTS.md
agentlink "$(pwd)/AGENTS.md" ../CLAUDE.md
agentlink "$(pwd)/agents" ../.agents
agentlink "$(pwd)/claude" ../.claude
agentlink "$(pwd)/codex" ../.codex

# ------ editors

if [[ "$MACOS" == true ]] && [[ "$HEADLESS" == false ]]; then
    # configure Visual Studio Code
    CODE_PATH="/Applications/Visual Studio Code.app"
    if [[ -d "$CODE_PATH" ]]; then
        CODE_LIB="$HOME/Library/Application Support/Code"
        mkdir -p "$CODE_LIB/User/"
        for f in vscode/*.json; do
            ln -sfn "$(pwd)/$f" "$CODE_LIB/User/$(basename "$f")"
            echo "Linked $CODE_LIB/User/$(basename "$f") -> $f"
        done
    fi
    if [[ "$REPAIR" == false ]] && command -v code &>/dev/null; then
        code --install-extension github.vscode-pull-request-github
        code --install-extension ms-vsliveshare.vsliveshare
        code --install-extension donjayamanne.python-extension-pack
        code --install-extension yzhang.markdown-all-in-one
        code --install-extension tamasfe.even-better-toml
        code --install-extension james-yu.latex-workshop
        code --install-extension tecosaur.latex-utilities
        code --install-extension streetsidesoftware.code-spell-checker
        code --install-extension jpcrs.gruvbox-material-modern
        mkdir -p "$HOME/.vscode/extensions"
        ln -sfn "$(pwd)/vscode/yaml-doc" "$HOME/.vscode/extensions/yaml-doc"
        echo "Linked ~/.vscode/extensions/yaml-doc -> vscode/yaml-doc"
    fi
    # configure Cursor
    CURSOR_PATH="/Applications/Cursor.app"
    if [[ -d "$CURSOR_PATH" ]]; then
        CURSOR_LIB="$HOME/Library/Application Support/Cursor"
        mkdir -p "$CURSOR_LIB/User/"
        for f in cursor/*.json; do
            ln -sfn "$(pwd)/$f" "$CURSOR_LIB/User/$(basename "$f")"
            echo "Linked $CURSOR_LIB/User/$(basename "$f") -> $f"
        done
    fi
    if [[ "$REPAIR" == false ]] && command -v cursor &>/dev/null; then
        cursor --install-extension github.vscode-pull-request-github
        cursor --install-extension donjayamanne.python-extension-pack
        cursor --install-extension yzhang.markdown-all-in-one
        cursor --install-extension tamasfe.even-better-toml
        cursor --install-extension james-yu.latex-workshop
        cursor --install-extension tecosaur.latex-utilities
        cursor --install-extension streetsidesoftware.code-spell-checker
        cursor --install-extension sainnhe.gruvbox-material
        mkdir -p "$HOME/.cursor/extensions"
        ln -sfn "$(pwd)/cursor/yaml-doc" "$HOME/.cursor/extensions/yaml-doc"
        echo "Linked ~/.cursor/extensions/yaml-doc -> cursor/yaml-doc"
    fi
fi

# ------ exit

cat <<NEXT
Setup complete. Start a shell that picks up the new configuration:

    exec zsh

Or open a new terminal window.
NEXT
