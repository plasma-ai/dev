# Adapted from Oh My Zsh .zshrc template (https://github.com/ohmyzsh/ohmyzsh/blob/master/templates/zshrc.zsh-template)

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Important variables
# USER      = $USER
# TIMESTAMP = $(date +'%s')
# DATETIME  = $(date +'%Y-%m-%dT%H:%M:%SZ')

# macOS variables
# NAME      = $(id -F)
# SYSTEM    = $(sw_vers -productName)
# VERSION   = $(sw_vers -productVersion)
# BUILD     = $(sw_vers -buildVersion)
# ADDRESS   = $(ipconfig getifaddr en0)

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    colored-man-pages
    command-not-found
    extract
    fzf
    git
    iterm2
    macos
    pip
    poetry
    pre-commit
    python
    safe-paste
    sudo
    uv
    vscode
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
)

# Detect platform
OS="$(uname -s)"
MACOS=false
LINUX=false
if [[ "$OS" == "Darwin" ]]; then
    MACOS=true
elif [[ "$OS" == "Linux" ]]; then
    LINUX=true
else
    echo "unsupported platform: $OS" >&2; return 1
fi

# Add Homebrew to PATH (must run before oh-my-zsh source for plugins)
if [[ "$MACOS" == true && -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ "$LINUX" == true && -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Source Oh My Zsh installation
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n "$SSH_CONNECTION" ]]; then
    export EDITOR="vim"
else
    export EDITOR="nvim"
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Unset bracketed paste option
if [[ "$TERM" == dumb ]]; then
    unset zle_bracketed_paste
fi

# Starship prompt
eval "$(starship init zsh)"

# Zoxide (z command)
eval "$(zoxide init zsh)"

# Direnv (auto per-directory env)
eval "$(direnv hook zsh)"

# iTerm shell integration
export ITERM2_SQUELCH_MARK=1
if [[ -f "$HOME/.iterm2_shell_integration.zsh" ]]; then
    source "$HOME/.iterm2_shell_integration.zsh"
fi

# Multiprocessing
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY="YES"

# Export Python versions
export PYTHON_STABLE="3.13.12"
export PYTHON_LATEST="3.14.3"

# Pyenv setup
if command -v pyenv &>/dev/null; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    export PYENV_VERSION="$PYTHON_STABLE"
    export PYENV_ROOT="$HOME/.pyenv"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# Poetry setup
export PATH="$HOME/.local/bin:$PATH"

# SSH key paths
export DEFAULT_SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
# SSH_KEY_ROOT keeps a literal "~" for ssh config files (ssh expands ~ itself);
# SSH_KEY_PATH is the expanded form for filesystem operations.
export SSH_KEY_ROOT="~/.ssh"
export SSH_KEY_PATH="$HOME/.ssh"

# Plans directory: scratch/plans beside the dev repo
export PLANS_DIR="${PLANS_DIR:-${${(%):-%x}:A:h:h:h}/scratch/plans}"

# Generate an SSH key and register it in ~/.ssh/config
sshkey () {
    # Name is the first positional arg, email the second. --host/--user set
    # the config entry (--github = --host=github.com --user=git); --default
    # also copies it to the default key path; --copy copies the public key
    # to the clipboard.

    # Parse options
    ARGS=()
    SSH_HOST=""
    SSH_USER=""
    DEFAULT=false
    COPY=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help | -h)
                cat <<USAGE
Usage: sshkey <name> <email> [options]

Generate an SSH key and register it in ~/.ssh/config.

Options:
    --host=<host>    HostName for the config entry
    --user=<user>    User for the config entry
    --github         Shorthand for --host=github.com --user=git
    --default        Also copy the key to the default key path
    --copy           Copy the public key to the clipboard
    --help|-h        Show this help message
USAGE
                return 0
                ;;
            --host=*) SSH_HOST="${1#*=}" ;;
            --user=*) SSH_USER="${1#*=}" ;;
            --github) SSH_HOST="github.com"; SSH_USER="git" ;;
            --default) DEFAULT=true ;;
            --copy) COPY=true ;;
            *) ARGS+=("$1") ;;
        esac
        shift
    done
    KEYNAME="${ARGS[1]}"
    EMAIL="${ARGS[2]}"
    KEYPATH="$SSH_KEY_PATH/$KEYNAME"
    KEYPATH_ROOT="$SSH_KEY_ROOT/$KEYNAME"

    # Email passed and private or public key does not exist
    if [[ -n "$EMAIL" ]] && [[ (! -f "$KEYPATH") || (! -f "$KEYPATH.pub") ]]; then
        echo "generating new ssh key for $EMAIL"
        # Make new ~/.ssh/config file if one does not exist
        SSH_CONFIG="$HOME/.ssh/config"
        if [[ ! -f "$SSH_CONFIG" ]]; then
            touch "$SSH_CONFIG"
        fi
        # Add host entry to ~/.ssh/config file
        # Append newline if file doesn't already end with one
        if [[ -s "$SSH_CONFIG" ]] && [[ "$(tail -c 1 "$SSH_CONFIG")" != "" ]]; then
            echo "" >> "$SSH_CONFIG"
        fi
        CONFIG=(
            "Host $KEYNAME"
            "  HostName $SSH_HOST"
            "  User $SSH_USER"
            "  AddKeysToAgent yes"
        )
        if [[ "$MACOS" == true ]]; then
            CONFIG+=("  UseKeychain yes")
        fi
        CONFIG+=("  IdentityFile $KEYPATH_ROOT")
        printf '%s\n' "${CONFIG[@]}" >> "$SSH_CONFIG"
        # Generate new ssh key
        ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEYPATH"
        # Start ssh-agent if not running
        if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
            eval "$(ssh-agent -s)"
        fi
    fi
    if [[ "$MACOS" == true ]]; then
        ssh-add --apple-use-keychain "$KEYPATH"
    else
        ssh-add "$KEYPATH"
    fi
    # Copy as default key
    if [[ "$DEFAULT" == true ]]; then
        cp "$KEYPATH" "$DEFAULT_SSH_KEY_PATH"
        cp "$KEYPATH.pub" "$DEFAULT_SSH_KEY_PATH.pub"
    fi
    # Copy public key to clipboard
    if [[ "$COPY" == true ]]; then
        if command -v pbcopy &>/dev/null; then
            pbcopy < "$KEYPATH.pub"
        elif command -v wl-copy &>/dev/null; then
            wl-copy < "$KEYPATH.pub"
        elif command -v xclip &>/dev/null; then
            xclip -selection clipboard < "$KEYPATH.pub"
        elif command -v xsel &>/dev/null; then
            xsel --clipboard --input < "$KEYPATH.pub"
        else
            echo "no clipboard tool found; install wl-clipboard or xclip" >&2
        fi
    fi
}

# Archive dirs and files
archive () {
    NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    ARGS=()
    COPY=false
    CLEAN=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --copy) COPY=true ;;
            --clean) CLEAN=true ;;
            *) ARGS+=("$1") ;;
        esac
        shift
    done

    if [[ -n "${ARGS[1]}" ]]; then
        FROM=$(realpath -- "${ARGS[1]}")
        NAME=$(basename -- "${ARGS[1]}")
        DIR=$(dirname -- "${ARGS[1]}")
        mkdir -p "$DIR/.archive"
        if [[ -d "$FROM" ]]; then
            TO="$DIR/.archive/$NAME ($NOW)"
            if [[ "$COPY" == true ]]; then
                rsync -a "$FROM/" "$TO"
            else
                mv "$FROM" "$TO"
            fi
            # --clean permanently removes ignored and untracked files in the archived copy
            if [[ "$CLEAN" == true ]] && git -C "$TO" rev-parse --is-inside-work-tree &>/dev/null; then
                (cd "$TO" && git clean -xdf) > /dev/null
            fi
        elif [[ -f "$FROM" ]]; then
            EXT="${NAME##*.}"
            NAME="${NAME%.*}"
            TO="$DIR/.archive/$NAME ($NOW).$EXT"
            if [[ "$COPY" == true ]]; then
                cp "$FROM" "$TO"
            else
                mv "$FROM" "$TO"
            fi
        fi
    fi
}

# Symlink agent config into a project
agentconf () {
    DIR="${1:-.}"
    DEV="${2:-../dev}"
    for SUB in agents claude codex; do
        DEST="$DIR/.$SUB"
        if [[ -e "$DEST" && ! -L "$DEST" ]]; then
            echo "skipping $DEST (exists and is not a symlink)"
            continue
        fi
        ln -sfn "$DEV/$SUB" "$DEST"
    done
}

# Print plan usage
_plan_usage () {
    cat <<USAGE
Usage: plan <name> <author>

Initialize a timestamped plan file in \$PLANS_DIR.

Arguments:
    name      Short descriptive name
    author    Plan author (e.g. Claude, Codex)
USAGE
}

# Initialize a timestamped plan file in $PLANS_DIR
plan () {
    # Name is the first positional arg; author the second.
    # Writes "$PLANS_DIR/<UTC timestamp>-<name>.md" with a title and author
    # header, then prints the path.
    # Show usage on --help
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        _plan_usage
        return 0
    fi
    # Require name and author
    NAME="$1"
    AUTHOR="$2"
    if [[ -z "$NAME" || -z "$AUTHOR" ]]; then
        _plan_usage >&2
        return 1
    fi
    # Require PLANS_DIR
    if [[ -z "$PLANS_DIR" ]]; then
        echo "PLANS_DIR is not set" >&2
        return 1
    fi
    # Build the timestamped plan path
    NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    FILE="$PLANS_DIR/$NOW-$NAME.md"
    mkdir -p "$PLANS_DIR"
    # Derive a human title from the name (underscores -> spaces)
    TITLE="${NAME//_/ }"
    # Write the title and author header
    {
        echo "# $TITLE"
        echo ""
        echo "Written by: $AUTHOR"
    } > "$FILE"
    # Print the created path
    echo "$FILE"
}
