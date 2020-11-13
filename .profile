#!/bin/zsh
echo ".profile"

# shellcheck shell=sh
# shellcheck disable=SC2034

# TOM_SYSTEMINFO {{{1

export TOM_SYSTEMINFO
TOM_SYSTEMINFO=$(uname -a)

# }}}1



export EDITOR VISUAL PAGER
if command -v nvim > /dev/null 2>&1; then
    EDITOR=nvim
elif command -v vim > /dev/null 2>&1; then
    EDITOR=vim
else
    EDITOR=vi
fi
VISUAL="$EDITOR"

if command -v nvimpager > /dev/null 2>&1; then
    PAGER=nvimpager
    alias less='nvimpager'
else
    PAGER=less
fi

export MANPAGER
MANPAGER='less -X'

go="$HOME/go"
gosrc="$go/src"
gobin="$go/bin"
[[ ! -d $gosrc ]] && mkdir -p $gosrc
[[ ! -d $gobin ]] && mkdir -p $gobin
export PATH="$PATH:$gobin"
export GOPATH="$go"
export XDG_CONFIG_HOME="$HOME/.config"
which dotnet >/dev/null 2>&1 && PATH="$PATH:~/.dotnet/tools"

# nvm
export NVM_DIR="$HOME/.config/nvm"
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"

# rvm
export PATH="$PATH:$HOME/.rvm/bin"
# export PATH="$HOME/.gem/ruby/2.7.0/bin:$PATH"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

export PATH="$PATH:$HOME/.local/bin:$HOME/bin"

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/src
# source /usr/bin/virtualenvwrapper.sh
export ENV
ENV="$HOME/.shrc"

export DOTBARE_DIR="$HOME/.pontos"
export EDITOR="nvim"




kil() {
    kcmd=killall
    $kcmd $1 1>$lfile 2>&1
    rc=$?
    $@ >/tmp/$1.log 2>&1 & disown
    rc=$?
}

# }}}1

# Source ~/.profile.local {{{1

if [ -f "$HOME/.profile.local" ]; then
	# shellcheck source=/dev/null
	. "$HOME/.profile.local"
fi

# }}}1
