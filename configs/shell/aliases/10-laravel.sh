#!/bin/zsh
# Laravel Development Aliases

# Laravel Mode Toggle System
LARAVEL_MODE_FILE="$HOME/.laravel_mode"

# Initialize mode if file doesn't exist (default to sail)
if [[ ! -f "$LARAVEL_MODE_FILE" ]]; then
    echo "sail" > "$LARAVEL_MODE_FILE"
fi

# Read current mode
LARAVEL_MODE=$(cat "$LARAVEL_MODE_FILE")

# Function to get the current Laravel command prefix
get_laravel_cmd() {
    if [[ "$LARAVEL_MODE" == "php" ]]; then
        echo "php artisan"
    else
        echo "sh \$([ -f sail ] && echo sail || echo vendor/bin/sail) artisan"
    fi
}

# Function to toggle Laravel mode
toggle_sail() {
    local current_mode=$(cat "$LARAVEL_MODE_FILE")
    if [[ "$current_mode" == "sail" ]]; then
        echo "php" > "$LARAVEL_MODE_FILE"
        echo "🔄 Laravel mode switched to: php artisan"
        LARAVEL_MODE="php"
    else
        echo "sail" > "$LARAVEL_MODE_FILE"
        echo "🔄 Laravel mode switched to: sail artisan"
        LARAVEL_MODE="sail"
    fi
    # Update the variable and re-define aliases
    _reload_laravel_aliases
}

# Function to show current Laravel mode
laravel_mode_status() {
    local current_mode=$(cat "$LARAVEL_MODE_FILE")
    echo "📋 Current Laravel mode: $current_mode artisan"
}

# Function to reload all Laravel aliases
_reload_laravel_aliases() {
    # Aliases using dynamic command
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias artisan="$(get_laravel_cmd)"
alias tinker="$(get_laravel_cmd) tinker"
alias duster="$(get_laravel_cmd | sed 's/artisan/bin/') duster fix"

# Development
alias pas="$(get_laravel_cmd) serve"
alias pats="$(get_laravel_cmd) test"
alias pascw="$(get_laravel_cmd) schedule:work"

# Database
alias pam="$(get_laravel_cmd) migrate"
alias pamf="$(get_laravel_cmd) migrate:fresh"
alias pamfs="$(get_laravel_cmd) migrate:fresh --seed"
alias pamr="$(get_laravel_cmd) migrate:rollback"
alias pads="$(get_laravel_cmd) db:seed"
alias padw="$(get_laravel_cmd) db:wipe"
alias pamte="$(get_laravel_cmd) migrate --env=testing"
alias pamtef="$(get_laravel_cmd) migrate:fresh --env=testing"

# Makers
alias pamm="$(get_laravel_cmd) make:model"
alias pammi="$(get_laravel_cmd) make:migration"
alias pamc="$(get_laravel_cmd) make:controller"
alias pams="$(get_laravel_cmd) make:seeder"
alias pamt="$(get_laravel_cmd) make:test"
alias pamfa="$(get_laravel_cmd) make:factory"
alias pamp="$(get_laravel_cmd) make:policy"
alias pame="$(get_laravel_cmd) make:event"
alias pamj="$(get_laravel_cmd) make:job"
alias paml="$(get_laravel_cmd) make:listener"
alias pamn="$(get_laravel_cmd) make:notification"
alias pampp="$(get_laravel_cmd) make:provider"
alias pamcl="$(get_laravel_cmd) make:class"
alias pamen="$(get_laravel_cmd) make:enum"
alias pami="$(get_laravel_cmd) make:interface"
alias pamtr="$(get_laravel_cmd) make:trait"

# Clears
alias pacac="$(get_laravel_cmd) cache:clear"
alias pacoc="$(get_laravel_cmd) config:clear"
alias pavic="$(get_laravel_cmd) view:clear"
alias paroc="$(get_laravel_cmd) route:clear"
alias paopc="$(get_laravel_cmd) optimize:clear"

# Queues
alias paqf="$(get_laravel_cmd) queue:failed"
alias paqft="$(get_laravel_cmd) queue:failed-table"
alias paql="$(get_laravel_cmd) queue:listen"
alias paqr="$(get_laravel_cmd) queue:retry"
alias paqt="$(get_laravel_cmd) queue:table"
alias paqw="$(get_laravel_cmd) queue:work"
}

# Load aliases initially
_reload_laravel_aliases 