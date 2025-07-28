# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

ON_CLUSTER="no"

# Cluster specific bits
# Herts
if [[ "$HOSTNAME" = "uhhpc.herts.ac.uk" ]] || [[ "$HOSTNAME" =~ headnode* ]] || [[ "$HOSTNAME" =~ ^(node)[0-9]+ ]]; then
    ON_CLUSTER="yes"
fi

# UCL
if [[ "$SGE_CLUSTER_NAME" == "kathleen" ]] || [[ "$SGE_CLUSTER_NAME" == "myriad" ]] || [[ "$HOSTNAME" =~ "ad.ucl.ac.uk" ]] || [[ "$HOSTNAME" =~ ^node-* ]]; then
    ON_CLUSTER="yes"
fi

# gnome-keyring should be started on logging in on gnome.
# it should set the SSH_AUTH_LOCK environment variable when it runs.
# If gnome-keyring is not running (if not logged in via gdm), check for an
# ssh-agent and start a new one if it does not exist
function start_ssh_agent {
    local myid
    myid="$(id -u)"
    if ss -xl | grep -q "/run/user/${myid}/keyring/ssh"
    then
        export SSH_AUTH_SOCK="/run/user/${myid}/keyring/ssh"
    else
        if ! pgrep -fa -U "${myid}" ssh-agent > /dev/null
        then
            if command -v ssh-agent > /dev/null
            then
                eval "$(ssh-agent -s)"
            else
                echo "ssh-agent command not found"
            fi
        else
            echo "Agent already running"
        fi
    fi
}

# Test and start agent when logging in over SSH
if shopt -q login_shell && [ -z "${SSH_AUTH_SOCK}" ]
then
    start_ssh_agent
fi

# Only when it is an interactive shell, not a login shell
if [[ $- == *i* ]] ; then

    # Common settings
    # User specific aliases and functions

    # do not enable on cluster, slows down prompt
    if [[ "$ON_CLUSTER" = "no" ]]; then
        if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]
        then
            source /usr/share/git-core/contrib/completion/git-prompt.sh
            export GIT_PS1_SHOWDIRTYSTATE=1
            export GIT_PS1_SHOWSTASHSTATE=1
            export GIT_PS1_SHOWUPSTREAM="auto"
            export GIT_PS1_SHOWUNTRACKEDFILES=1
        fi
    else
        # define empty function
        __git_ps1 ()
        {
            true
        }
    fi

    alias timestamp='date +%Y%m%d%H%M'
    alias rm='rm -i'
    alias lsd='ls -d */ --color=auto'
    alias lash='ls -lAshv --color=auto'
    alias egrep='egrep --color=auto'
    alias bt='echo 0 | gdb -batch-silent -ex "run" -ex "set logging overwrite on" -ex "set logging file gdb.bt" -ex "set logging on" -ex "set pagination off" -ex "handle SIG33 pass nostop noprint" -ex "echo backtrace:\n" -ex "backtrace full" -ex "echo \n\nregisters:\n" -ex "info registers" -ex "echo \n\ncurrent instructions:\n" -ex "x/16i \$pc" -ex "echo \n\nthreads backtrace:\n" -ex "thread apply all backtrace" -ex "set logging off" -ex "quit" --args'
    # Set vi mode
    set -o vi
    # Enable globstar
    if shopt -q globstar
    then
        shopt -s globstar
    fi

    # append to the history file, don't overwrite it
    if shopt -q histappend
    then
        shopt -s histappend
    fi

    # check the window size after each command and, if necessary,
    # update the values of LINES and COLUMNS.
    if shopt -q checkwinsize
    then
        shopt -s checkwinsize
    fi

    # Common settings for clusters, where settings for my local machines do not apply
    if [[ "$ON_CLUSTER" = "yes" ]]; then
        # set all options here in case my vim config isn't on the system
        vman() {
            /usr/bin/man -w "$@" && /usr/bin/man "$@" | col -b | vim  -c 'setlocal nomod nolist noexpandtab tabstop=8 softtabstop=8 shiftwidth=8 nonu noma noswapfile colorcolumn=0' -c 'set ft=man' -c 'nmap q :q<cr>' -; 
            }
    # for all my other machines
    else
        # these are repeated in vimrc
        vman() {
            /usr/bin/man -w "$@" > /dev/null 2>&1 && { /usr/bin/man "$@" | col -bx | vim  -c 'set ft=man' -c 'setlocal nomod nolist noexpandtab tabstop=8 softtabstop=8 shiftwidth=8 nonu noma noswapfile colorcolumn=0' -c 'IndentLinesDisable' -c 'nmap q :q<cr>' -; } || { echo "No man page found for $@" ; echo "Related man pages:" ; apropos "$@" ; }
        }
        fortune | cowsay -f vader
        export PATH="$PATH:/usr/lib64/ccache:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$HOME/.local/bin:$HOME/bin:$HOME/.node_modules_global/bin/"

        # Flags but only if I'm on an RPM based machine
        if [ -x "$(command -v rpm)"  ]
        then
            CFLAGS=$(rpm -E %optflags); export CFLAGS
            CXXFLAGS=$(rpm -E %optflags); export CXXFLAGS
        fi

        ulimit -c unlimited

        # For qutebrowser
        export QT_QPA_PLATFORM=xcb

        # Vim with X support
        alias vim='vimx --servername $(pwgen 8 1)'

        # For the vim man viewer
        complete -o default -o nospace -F _man vman

        alias trp='trash-put'
        alias trl='trash-list'
        alias tre='trash-restore'
        alias latex-clean='rm -fv *.aux *.bbl *.blg *.log *.nav *.out *.snm *.toc *.dvi *.vrb *.bcf *.run.xml *.cut *.lo*'

        # to prefer pushd popd
        # adapted from: https://unix.stackexchange.com/a/4291/30628
        pd()
        {
          if [ $# -eq 0 ]; then
            DIR="${HOME}"
          else
            DIR="$1"
          fi

          builtin pushd "${DIR}" > /dev/null
          echo -n "DIRSTACK: "
          dirs
        }

        pp()
        {
          builtin popd > /dev/null
          echo -n "DIRSTACK: "
          dirs
        }
        # ALT O for popd
        bind -m emacs-standard -x '"\eo": "pp"'
        bind -m vi-command -x '"\eo": "pp"'
        bind -m vi-insert -x '"\eo": "pp"'

        # fzf on Fedora
        if [ -x "$(command -v fzf)"  ]
        then
            source /usr/share/fzf/shell/key-bindings.bash
            # To not have to use gio open each time, from:
            # https://unix.stackexchange.com/a/518900/30628
            bind -m emacs-standard -x '"\C-o": file="$(fzf --height 40% --reverse --prompt="Open file>")" && [ -f "$file" ] &&  history -s gio open "\"${file}\"" && gio open "${file}"'
            bind -m vi-command -x '"\C-o": file="$(fzf --height 40% --reverse --prompt="Open file>")" && [ -f "$file" ] &&  history -s gio open "\"${file}\"" && gio open "${file}"'
            bind -m vi-insert -x '"\C-o": file="$(fzf --height 40% --reverse --prompt="Open file>")" && [ -f "$file" ] &&  history -s gio open "\"${file}\"" && gio open "${file}"'
            # use fd for default command so it ignores .gitignore etc.
            export FZF_DEFAULT_COMMAND='fd --type f'
            #
            # add fzf based command that uses pushd instead of cd
            # ref: https://github.com/junegunn/fzf/blob/master/shell/key-bindings.bash
            # use Alt P
            __fzf_pushd__() {
              local cmd opts dir
              cmd="${FZF_ALT_P_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
                -o -type d -print 2> /dev/null | command cut -b3-"}"
              opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse --scheme=path ${FZF_DEFAULT_OPTS-} ${FZF_ALT_P_OPTS-} +m"
              dir=$(set +o pipefail; eval "$cmd" | FZF_DEFAULT_OPTS="$opts" $(__fzfcmd)) && printf 'builtin pushd -- %q' "$dir"
            }

            # ALT-P - pushd into the selected directory
            bind -m emacs-standard '"\ep": " \C-b\C-k \C-u`__fzf_pushd__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
            bind -m vi-command '"\ep": "\C-z\ep\C-z"'
            bind -m vi-insert '"\ep": "\C-z\ep\C-z"'
        fi

        # vit related functions, instead of aliases
        TASK_FILTERS="project!~research.lit.bucket tags!~tickler project!~agenda"
        vit-tl ()
        {
            vit ${TASK_FILTERS}
        }
        vit-today () {
            vit ${TASK_FILTERS} 'due.by:eod'
        }
        vit-this-week () {
            vit ${TASK_FILTERS} 'due.by:eow'
        }
        vit-this-month () {
            vit ${TASK_FILTERS} 'due.by:eom'
        }
        vit-in-a-week () {
            vit ${TASK_FILTERS} 'due.by:1w'
        }
        vit-in-a-month () {
            vit ${TASK_FILTERS} 'due.by:1m'
        }
        vit-in-six-months () {
            vit ${TASK_FILTERS} 'due.by:6m'
        }
        vit-in-a-year () {
            vit ${TASK_FILTERS} 'due.by:1y'
        }
        vit-rl () {
            vit 'project:research.lit'
        }
        vit-ticklers () {
            vit 'tags:tickler'
        }
        vit-agenda () {
            vit 'project~agenda'
        }
        vit-on-wait () {
            vit 'tags:on-wait'
        }
        vit-next () {
            echo "Active tasks:"
            echo
            task active
            echo
            echo
            echo "Next ${1:-2} tasks:"
            echo
            task ${TASK_FILTERS} limit:"${1:-2}"
            echo
            echo
        }
        taskestimate-tl ()
        {
            taskestimate ${TASK_FILTERS}
        }
        taskestimate-today () {
            taskestimate ${TASK_FILTERS} 'due.by:eod'
        }
        taskestimate-this-week () {
            taskestimate ${TASK_FILTERS} 'due.by:eow'
        }
        taskestimate-this-month () {
            taskestimate ${TASK_FILTERS} 'due.by:eom'
        }
        taskestimate-in-a-week () {
            taskestimate ${TASK_FILTERS} 'due.by:1w'
        }
        taskestimate-in-a-month () {
            taskestimate ${TASK_FILTERS} 'due.by:1m'
        }
        taskestimate-in-six-months () {
            taskestimate ${TASK_FILTERS} 'due.by:6m'
        }
        taskestimate-in-a-year () {
            taskestimate ${TASK_FILTERS} 'due.by:1y'
        }
        taskestimate-rl () {
            taskestimate 'project:research.lit'
        }

        alias neomutt-work='neomutt -F ~/Sync/99_private/work.neomuttrc'
        alias neomutt-all='neomutt -F ~/Sync/99_private/all.neomuttrc'

        # pdftotext to get word count
        latex_wc () {
            if [ -x "$(command -v pdftotext)" ]
            then
                pdftotext -nopgbrk "${1}" - | wc
            else
                echo "Please install pdftotext"
            fi
        }

    fi
    alias man='vman'
    export EDITOR='vim'

    # for gpg agent
    GPG_TTY="$(tty)"; export GPG_TTY

    # For 256 colours in xterm
    if [ "$TERM" == "xterm" ] || [ "$TERM" == "screen" ] || [ "$TERM" == "screen-256color" ] || [ "$TERM" == "xterm-256color" ]; then
        # comment out, unclear why I need this given that I set PS1 below anyway
        # export PROMPT_COMMAND='printf "\033]0;%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'

        # append to history after each command: combines histories of all terminals, so not very useful
        # export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

        # Bash prompt
        # Colours:
    #    txtblk='\e[0;30m' # Black - Regular
    #    txtred='\e[0;31m' # Red
    #    txtgrn='\e[0;32m' # Green
    #    txtylw='\e[0;33m' # Yellow
    #    txtblu='\e[0;34m' # Blue
    #    txtpur='\e[0;35m' # Purple
    #    txtcyn='\e[0;36m' # Cyan
    #    txtwht='\e[0;37m' # White
    #    bldblk='\e[1;30m' # Black - Bold
    #    bldred='\e[1;31m' # Red
    #    bldgrn='\e[1;32m' # Green
    #    bldylw='\e[1;33m' # Yellow
    #    bldblu='\e[1;34m' # Blue
    #    bldpur='\e[1;35m' # Purple
    #    bldcyn='\e[1;36m' # Cyan
    #    bldwht='\e[1;37m' # White
    #    unkblk='\e[4;30m' # Black - Underline
    #    undred='\e[4;31m' # Red
    #    undgrn='\e[4;32m' # Green
    #    undylw='\e[4;33m' # Yellow
    #    undblu='\e[4;34m' # Blue
    #    undpur='\e[4;35m' # Purple
    #    undcyn='\e[4;36m' # Cyan
    #    undwht='\e[4;37m' # White
    #    bakblk='\e[40m'   # Black - Background
    #    bakred='\e[41m'   # Red
    #    badgrn='\e[42m'   # Green
    #    bakylw='\e[43m'   # Yellow
    #    bakblu='\e[44m'   # Blue
    #    bakpur='\e[45m'   # Purple
    #    bakcyn='\e[46m'   # Cyan
    #    bakwht='\e[47m'   # White
    #    txtrst='\e[0m'    # Text Reset

        # using tput commands
        FGBLK=$( tput setaf 0 ) # 000000
        FGRED=$( tput setaf 1 ) # ff0000
        FGGRN=$( tput setaf 2 ) # 00ff00
        FGYLO=$( tput setaf 3 ) # ffff00
        FGBLU=$( tput setaf 4 ) # 0000ff
        FGMAG=$( tput setaf 5 ) # ff00ff
        FGCYN=$( tput setaf 6 ) # 00ffff
        FGWHT=$( tput setaf 7 ) # ffffff

        BGBLK=$( tput setab 0 ) # 000000
        BGRED=$( tput setab 1 ) # ff0000
        BGGRN=$( tput setab 2 ) # 00ff00
        BGYLO=$( tput setab 3 ) # ffff00
        BGBLU=$( tput setab 4 ) # 0000ff
        BGMAG=$( tput setab 5 ) # ff00ff
        BGCYN=$( tput setab 6 ) # 00ffff
        BGWHT=$( tput setab 7 ) # ffffff

        RESET=$( tput sgr0 )
        BOLDM=$( tput bold )
        UNDER=$( tput smul )
        REVRS=$( tput rev )

        PS1="\[$FGGRN\][\u@\h \[$FGBLU\] \W\[$FGRED\]\$(__git_ps1 \(%s\))\[$FGGRN\]]\$ \[$RESET\]"

    else
        PS1="[\u@\h \W\$(__git_ps1 \(%s\))]\$ "

    fi
    #
    # For virtual env in pew
    [[ -z "${VIRTUAL_ENV}" ]] || PS1="(\$(basename '$VIRTUAL_ENV'))$PS1"
    export PS1
fi
