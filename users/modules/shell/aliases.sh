# Aliases that are expanded inline (without adding a space after)
balias lsl="exa -al"
balias lst="exa -alT -I '.git|target'"
balias lsta="exa -alT"

balias e="$EDITOR"
balias edit="$EDITOR"

balias r1="rustup run stage1"
balias r2="rustup run stage2"

balias ghg="git status"

# Status/info
balias ghg='git status'
balias ghf='git hist'
balias ghd='git diff --color-moved'
balias ghs='git diff --color-moved --cached'
balias gha='git stash list'

# Changes
balias gjg='git add'
balias gjf='git checkout --'
balias gjd='git add -p'
balias gjs='git reset HEAD --'
balias gja='git reset -p'

# Commit
balias gkg='git commit'
balias gkf='git commit --amend'
balias gkd='git commit -m'

# Push/pull
balias glg='git push'
balias glf='git push --force-with-lease'
balias gld='git push -u'
balias gls='git pull'
balias gla='git fetch -p --all'

# Rebase
balias gug='git rebase'
balias guf='git rebase --onto'
balias gud='git rebase -i'
balias gus='git rebase --continue'
balias gua='git rebase --abort'

# Branch/checkout
balias gig='git checkout'
balias gif='git branch -d'
balias gid='git checkout -b'
balias gis='git branch'
balias gia='git branch -r'

# Stash
balias gog='git stash push'
balias gof='git stash drop'
balias god='git stash push --keep-index'
balias gos='git stash pop'
balias goa='git stash apply'

# Bisect
balias gyg='git bisect start'
balias gyf='git bisect reset'
balias gyd='git bisect good'
balias gys='git bisect bad'
balias gya='git bisect run'

# Merge
balias gmg='git merge'
balias gmf='git merge --squash'
balias gmd='git merge --signoff'
balias gms='git merge --continue'
balias gma='git merge --abort'

# Full scripts
balias gnf='git bisect bad && git checkout develop && git bisect good && git bisect start'
balias gnd='git clone'

# Select which folders called target/ inside ~/src to delete
balias delete-targets="fd -It d '^target$' ~/src | fzf --multi --preview='exa -al {}/..' | xargs rm -r"

# Select git branches to delete
balias delete-branches="git branch | rg -v '\*' | cut -c 3- | fzf --multi --preview='git hist {}' | xargs git branch --delete --force"
