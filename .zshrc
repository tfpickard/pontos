#!/usr/bin/zsh
# vi: ft=zsh

if [[ $0 == 'ksh' ]] || [[ $0 == 'sh' ]]; then
  source "$HOME/.shrc" && exit
elif [[ $0 == 'bash' ]]; then
  source "$HOME/.bashrc" && exit
fi

# }}}1

# Begin .zshrc benchmarks {{{1

# To run zprof, execute
#
#   env ZSH_PROF='' zsh -ic zprof
# (( $+ZSH_PROF )) && zmodload zsh/zprof
DOZOPROF=false
[[ true == $DOZOPROF ]] && zmodload zsh/zprof

# For simple script running times, execute
#
#     TOM_BENCHMARKS=1
#
# before sourcing.

if (( TOM_BENCHMARKS )); then
  if (( $+TOM_ZSHENV_BENCHMARK )); then
    print ".zshenv loaded in ${TOM_ZSHENV_BENCHMARK}ms total."
    unset TOM_ZSHENV_BENCHMARK
  fi
  typeset -F SECONDS=0
fi

# }}}1

# compile_or_recompile() {{{1

###########################################################
# If files do not have compiled forms, compile them;
# if they have been compiled, recompile them when necessary
#
# Arguments:
#   $1, etc.  Shell scripts to be compiled
###########################################################
compile_or_recompile() {
  local file
  for file in "$@"; do
    if [[ -f $file ]] && [[ ! -f ${file}.zwc ]] \
      || [[ $file -nt ${file}.zwc ]]; then
      zcompile "$file"
    fi
  done
}

compile_or_recompile "${HOME}/.profile" "${HOME}/.zprofile" "${HOME}/.zshenv" \
  "${HOME}/.zshenv.local" "${HOME}/.zshrc" "${HOME}/.zshrc.local" \
  "${HOME}/.shrc" "${HOME}/.shrc.local"

# }}}1

# (Compile and) source ~/.shrc {{{1

if [[ -f ${HOME}/.shrc ]];then
  if (( TOM_BENCHMARKS )); then
    (( $+EPOCHREALTIME )) || zmodload zsh/datetime
    typeset -g TOM_ZSHRC_START=$(( EPOCHREALTIME * 1000 ))
    TOM_ZSHRC_LOADING=1 source "${HOME}/.shrc"
    printf '.shrc loaded in %dms.\n' $(( (EPOCHREALTIME * 1000) - TOM_ZSHRC_START ))
    unset TOM_ZSHRC_START
  else
    source "${HOME}/.shrc"
  fi
fi

# }}}1
#
export XDG_CONFIG_HOME="$HOME/.config"
export UPDATE_INTERVAL=15
export DOTS="$HOME/.dots"
export ZSH="$DOTS/zsh"
zmodload zsh/curses


if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P \
      "%F{33}▓▒░%F{220}%F{33}DHARMA%F{220} Initiative (%F{33}ZINIT%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

typeset -A ZINIT
compdump="${HOME}/.zcompdump-$(hostname)-${ZSH_VERSION}"
ZINIT[ZCOMPDUMP_PATH]=$compdump
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light nailshard/pure
zt()  { zinit depth'3' lucid ${1/#[0-9][a-c]/wait"$1"} "${@:2}"; }
zct() {
    thmf="${ZINIT[PLUGINS_DIR]}/_local---config-files/themes"
    if [[ ${1} != ${MYPROMPT=p10k} ]] && { ___turbo=1; .zinit-ice \
    load"[[ \${MYPROMPT} = ${1} ]]" unload"[[ \${MYPROMPT} != ${1} ]]" }
    .zinit-ice atload'! [[ -f "${thmf}/${MYPROMPT}-post.zsh" ]] && source "${thmf}/${MYPROMPT}-post.zsh"' \
    nocd id-as"${1}-theme";
    ICE+=("${(kv)ZINIT_ICES[@]}"); ZINIT_ICES=();
}

##########################
# General ZSH Settings   #
##########################
bindkey -v 
typeset -g HISTSIZE=290000 SAVEHIST=290000 HISTFILE=~/.zhistory
setopt hist_ignore_dups
setopt extended_history       # Save time stamps and durations
setopt hist_expire_dups_first
setopt inc_append_history
setopt share_history

setopt interactive_comments
setopt octal_zeroes
setopt no_prompt_cr
setopt complete_in_word
setopt auto_menu
setopt auto_pushd
setopt pushd_ignore_dups
setopt glob_complete
setopt glob_dots
setopt c_bases
setopt numeric_glob_sort
setopt promptsubst
setopt no_auto_cd
setopt rc_quotes
setopt extendedglob
setopt notify

# setopt no_always_to_end  append_history list_packed
zmodload -i zsh/complist
autoload -Uz allopt zed zmv zcalc colors
colors
autoload -Uz edit-command-line
zle -N edit-command-line

autoload -Uz select-word-style
select-word-style shell

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
##########################
# Programs/Binaries  s   #
##########################
zinit ver"develop" lucid wait for \
      agkozak/zhooks \
      #
# zsh-titles causes dittography in Emacs shell and Vim terminal
if (( ! $+EMACS )) && [[ $TERM != 'dumb' ]] && (( ! $+VIM_TERMINAL )); then
    zinit lucid wait for jreese/zsh-titles
fi

zinit lucid wait'1' for zdharma/zbrowse
zinit wait"2" lucid for \
    zdharma/declare-zsh \
 trigger-load'!crasis' \
    zdharma/zinit-crasis \

##########################
# OMZ Libs and Plugins   #
##########################
zinit lucid for \
    atinit"
        ZSH_TMUX_FIXTERM=true
        ZSH_TMUX_AUTOSTART=False
        ZSH_TMUX_AUTOCONNECT=true
    " \
    OMZP::tmux \
    atinit"HIST_STAMPS=dd.mm.yyyy" \
      OMZL::history.zsh \


# zinit wait lucid light-mode for \
zt light-mode for \
	OMZL::clipboard.zsh \
    trigger-load'!man' \
      ael-code/zsh-colored-man-pages \
	OMZL::compfix.zsh \
	OMZL::correction.zsh \
    atload"
        alias ..='cd ..'
        alias ...='cd ../..'
        alias ....='cd ../../..'
        alias .....='cd ../../../..'
    " \
	OMZL::directories.zsh \
    trigger-load'!x' \
      OMZP::extract \
	OMZL::git.zsh \
	OMZL::grep.zsh \
	OMZL::key-bindings.zsh \
	OMZL::spectrum.zsh \
	OMZL::termsupport.zsh \
    atload"
        alias gcd='gco dev'
    " \
	OMZP::git \
	OMZP::fzf \
    OMZP::fasd \
    atload"
        alias dcupb='docker-compose up --build'
    " \
	OMZP::docker-compose \
	as"completion" \
    OMZP::docker/_docker \
    trigger-load'!updatelocal' blockf \
      NICHOLAS85/updatelocal \
    djui/alias-tips \
    softmoth/zsh-vim-mode \
    trigger-load'!gencomp' pick'zsh-completion-generator.plugin.zsh' blockf \
          atload'\
            alias gencomp="zinit silent nocd as\"null\" wait\"2\" \
              atload\"zinit creinstall -q _local/config-files; zicompinit\" \
              for /dev/null; gencomp"' \
      RobSis/zsh-completion-generator \
    trigger-load'!zshz' blockf \
      agkozak/zsh-z
    # hlissner/zsh-autopair \
    # chriskempson/base16-shell \

#####################
# PLUGINS           #
#####################

zt 0a light-mode for \
    OMZL::completion.zsh \
    OMZP::pip \
    if'false' ver'dev' \
        marlonrichert/zsh-autocomplete \
    has'systemctl' \
        OMZP::systemd/systemd.plugin.zsh \
    OMZP::sudo/sudo.plugin.zsh \
    blockf \
        zsh-users/zsh-completions \
    compile'{src/*.zsh,src/strategies/*}' pick'zsh-autosuggestions.zsh' \
        atload'_zsh_autosuggest_start' \
        zsh-users/zsh-autosuggestions \
    pick'fz.sh' atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert __fz_zsh_completion)' \
        changyuheng/fz 

zt 0b light-mode for \
  autoload'#manydots-magic' \
    knu/zsh-manydots-magic \
  pick'autoenv.zsh' nocompletions \
    Tarrasch/zsh-autoenv \
  OMZP::command-not-found/command-not-found.plugin.zsh \
  pick'autopair.zsh' nocompletions atload'bindkey "^H" backward-kill-word; \
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
    hlissner/zsh-autopair


zinit load zinit-zsh/z-a-meta-plugins
zinit for \
    annexes \
    console-tools \
    developer \
    ext-git \
    fuzzy \
    molovo \
    zdharma \
    zdharma2 \
    zsh-users+fast

zt 0c light-mode for \
    pack'bgn-binary' \
        junegunn/fzf \
    sbin from'gh-r' submods'NICHOLAS85/zsh-fast-alias-tips -> plugin' pick'plugin/*.zsh' \
        sei40kr/fast-alias-tips-bin

zt 0c light-mode binary for \
    sbin'fd*/fd;fd*/fd -> fdfind' from"gh-r" \
         @sharkdp/fd \
    sbin'bin/git-ignore' atload'export GI_TEMPLATE="$PWD/.git-ignore"; alias gi="git-ignore"' \
        laggardkernel/git-ignore
# zsh-autopair
# zinit ice wait lucid
# zinit load hlissner/zsh-autopair

zinit ice wait"1" lucid
zinit load psprint/zsh-navigation-tools

zinit ice atclone'PYENV_ROOT="$HOME/.pyenv" ./libexec/pyenv init - > zpyenv.zsh' \
    atinit'export PYENV_ROOT="$HOME/.pyenv"' atpull"%atclone" \
    as'command' pick'bin/pyenv' src"zpyenv.zsh" nocompile'!'
zinit light pyenv/pyenv

zinit ice wait"2" lucid from"gh-r" as"program" mv"exa* -> exa"
zinit light ogham/exa

zinit ice from"gh-r" as"program" mv"direnv* -> direnv"
zinit light direnv/direnv

zinit ice from"gh-r" as"program" mv"shfmt* -> shfmt"
zinit light mvdan/sh

zinit ice as"program" pick"yank" make
zinit light mptre/yank

zinit ice wait"2" lucid as'command' pick'src/vramsteg' \
    atclone'cmake .' atpull'%atclone' make  # use Turbo mode
zinit light psprint/vramsteg-zsh

zinit light kazhala/dotbare

zinit wait lucid for \
    \
    light-mode lukechilds/zsh-nvm \
    \
    light-mode asciinema/asciinema \
    \
    pick'fz.sh' \
    light-mode zdharma/zzcomplete \
    \
    light-mode zdharma/zsh-lint \
    \
    light-mode zsh-users/zsh-history-substring-search

#####################
# SETTINGS          #
#####################
# setopt COMPLETE_ALIASES
autoload -Uz compinit
compinit -u -d $compdump

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='underline'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''
zle -N history-substring-search-up
zle -N history-substring-search-down

zmodload zsh/complist
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom

# Use Esc-K for run-help
bindkey -M vicmd '?' run-help

# Allow v to edit the command line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line


# Borrowed from emacs mode
bindkey '^R' history-incremental-search-backward
# setopt NO_FLOW_CONTROL                          # Or the next command won't work
bindkey '^S' history-incremental-search-forward


# zstyle ':completion::complete:*' gain-privileges 1
# Customize to your needs...
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' \
    select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '-- %d --'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:complete:*:options' sort false
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':completion:*:*:*:*:processes' \
    command 'ps -u $USER -o pid,user,comm,cmd -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts \
    --preview=$extract'ps --pid=$in[(w)1] -o cmd \
    --no-headers -w -w' --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:cd:*' extra-opts \
    --preview=$extract'exa -1 --color=always ${~ctxt[hpre]}$in' 

zstyle :history-search-multi-word page-size 10
zstyle :history-search-multi-word highlight-color fg=red,bold
zstyle :plugin:history-search-multi-word reset-prompt-protect 1
#
# 10ms for key sequences
KEYTIMEOUT=1
alias which &> /dev/null && unalias which

# While tinkering with ZSH-z
if (( SHLVL == 1 )); then
  [[ ! -d ${HOME}/.zbackup ]] && mkdir "${HOME}/.zbackup"
  cp "${HOME}/.z" "${HOME}/.zbackup/.z_${EPOCHSECONDS}" 2> /dev/null
fi
compile_or_recompile $compdump

[[ true == $DOZOPROF ]] && zprof && zmodload -u zsh/zprof

