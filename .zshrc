PATH=$PATH":/home/kalterfive/scripts"

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
 
setopt CORRECT_ALL 

zstyle ':completion:*' menu select=long-list select=0

lsn() {
    while read num name
    do
        echo "$num $name"
        declare -g "LS$num=$name"
    done <<< `ls -A1 "$@" | cat -n`
}

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kalterfive/.zshrc'
 
alias sysinf='alsi -n'
alias l='ls --color=auto'
alias ls='ls --color=auto'
alias ll='ls --color=auto -l'
alias la='ls --color=auto -a'
alias lal='ls --color=auto -la'
alias lddi='ls --color=auto -l /dev/disk/by-id'
alias pm='sudo pacman'
alias rg='ranger'
alias s='sudo '
alias rd='rm -rf'
alias q='exit'
alias mnt='sudo mount'
alias umnt='sudo umount'

hash -d cpkg=/var/cache/pacman/pkg/
hash -d clog=/var/log/
 
PROMPT='%B%n%b@%m %c $ '
 
autoload -U compinit
compinit
