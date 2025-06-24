#!/bin/zsh
# Laravel Development Aliases

# Basics
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias artisan='sail artisan'
alias tinker='sail artisan tinker'
alias duster='sail bin duster fix'

# Development
alias pas='sail artisan serve'
alias pats='sail artisan test'
alias pascw='sail artisan schedule:work'

# Database
alias pam='sail artisan migrate'
alias pamf='sail artisan migrate:fresh'
alias pamfs='sail artisan migrate:fresh --seed'
alias pamr='sail artisan migrate:rollback'
alias pads='sail artisan db:seed'
alias padw='sail artisan db:wipe'
alias pamte='sail artisan migrate --env=testing'
alias pamtef='sail artisan migrate:fresh --env=testing'

# Makers
alias pamm='sail artisan make:model'
alias pammi='sail artisan make:migration'
alias pamc='sail artisan make:controller'
alias pams='sail artisan make:seeder'
alias pamt='sail artisan make:test'
alias pamfa='sail artisan make:factory'
alias pamp='sail artisan make:policy'
alias pame='sail artisan make:event'
alias pamj='sail artisan make:job'
alias paml='sail artisan make:listener'
alias pamn='sail artisan make:notification'
alias pampp='sail artisan make:provider'
alias pamcl='sail artisan make:class'
alias pamen='sail artisan make:enum'
alias pami='sail artisan make:interface'
alias pamtr='sail artisan make:trait'

# Clears
alias pacac='sail artisan cache:clear'
alias pacoc='sail artisan config:clear'
alias pavic='sail artisan view:clear'
alias paroc='sail artisan route:clear'
alias paopc='sail artisan optimize:clear'

# Queues
alias paqf='sail artisan queue:failed'
alias paqft='sail artisan queue:failed-table'
alias paql='sail artisan queue:listen'
alias paqr='sail artisan queue:retry'
alias paqt='sail artisan queue:table'
alias paqw='sail artisan queue:work' 