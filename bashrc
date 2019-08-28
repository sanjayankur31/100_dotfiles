# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Cluster head node
if [[ "$HOSTNAME" = "uhhpc.herts.ac.uk" ]] || [[ "$HOSTNAME" =~ headnode* ]] || [[ "$HOSTNAME" =~ ^(node)[0-9]+ ]] ; then
    export PATH=$HOME/bin/:$HOME/anaconda2/bin/:$HOME/installed-software/cmake/bin/:$PATH
    export MODULEPATH=$HOME/Documents/02_Code/00_mine/Sinha2016-scripts/modulefiles:$MODULEPATH
    # do not load any modules by default
    module unload mpi/mpich-x86_64
    source activate python3
fi

# Only when it is an interactive shell, not a login shell
if [[ $- == *i* ]] ; then
    # SSH agent - hostname based, why not?
    SSH_ENV="$HOME/.ssh/environment.""$(hostname)"
    # If no SSH agent found, run this function
    function start_ssh_agent {
        echo "Initialising new SSH agent..."
        /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
        echo succeeded
        chmod 600 "${SSH_ENV}"
        . "${SSH_ENV}" > /dev/null
        /usr/bin/ssh-add;
    }

    # Common settings
    # User specific aliases and functions
    source /usr/share/git-core/contrib/completion/git-prompt.sh

    #alias rm='trash-put'
    alias timestamp='date +%Y%m%d%H%M'
    alias rm='rm -i'
    alias lsd='ls -d */ --color=auto'
    alias lash='ls -lAsh --color=auto'
    #alias skype='LD_PRELOAD=/usr/lib/libv4l/v4l1compat.so /usr/bin/skype'
    alias egrep='egrep --color=auto'
    alias latex-clean='rm -fv *.aux *.bbl *.blg *.log *.nav *.out *.snm *.toc *.dvi *.vrb *.bcf *.run.xml *.cut *.lo*'
    alias bt='echo 0 | gdb -batch-silent -ex "run" -ex "set logging overwrite on" -ex "set logging file gdb.bt" -ex "set logging on" -ex "set pagination off" -ex "handle SIG33 pass nostop noprint" -ex "echo backtrace:\n" -ex "backtrace full" -ex "echo \n\nregisters:\n" -ex "info registers" -ex "echo \n\ncurrent instructions:\n" -ex "x/16i \$pc" -ex "echo \n\nthreads backtrace:\n" -ex "thread apply all backtrace" -ex "set logging off" -ex "quit" --args'
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWSTASHSTATE=1
    export GIT_PS1_SHOWUPSTREAM="auto"
    export GIT_PS1_SHOWUNTRACKEDFILES=1

    # Host specific settings. Cluster doesn't have vimx and cowsay, the
    # flags won't apply, and the path to NEST is different too.
    if [[ "$HOSTNAME" = "uhhpc.herts.ac.uk" ]] || [[ "$HOSTNAME" =~ headnode* ]] || [[ "$HOSTNAME" =~ ^(node)[0-9]+ ]] ; then
        vman() { /usr/bin/man $* | col -b | vim -c 'set ft=man ts=8 nomod nolist nonu noma' -c 'nmap q :q<cr>' -; }
    # for all my other machines
    else
        fortune | cowsay -f vader
        export PATH="$PATH:/usr/lib64/ccache:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$HOME/.local/bin:$HOME/bin:$HOME/.vim/plugged/vim-superman/bin"

        # Flags
        CFLAGS=$(rpm -E %optflags); export CFLAGS
        CXXFLAGS=$(rpm -E %optflags); export CXXFLAGS

        # Printing
        export CUPS_USER=as14ahs

        ulimit -c unlimited

        # Vim with X support
        alias vim='vimx --servername $(pwgen 8 1)'
        export EDITOR='vim'

        # image directory for research diary
        year=$(date +%G)
        year_research_diary="$year""_research_diary"
        xport RDIMGDIR="$HOME/Documents/02_Code/00_mine/$year_research_diary/diary/$year/images/"

        # For the vim man viewer
        complete -o default -o nospace -F _man vman
    fi
    alias man='vman'

    # Source SSH settings, if applicable
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        #ps ${SSH_AGENT_PID} doesn't work under cywgin
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
            start_ssh_agent;
        }
    else
        start_ssh_agent;
    fi

    # for gpg agent
    GPG_TTY="$(tty)"; export GPG_TTY

    # For 256 colours in xterm
    if [ "$TERM" == "xterm" ] || [ "$TERM" == "screen" ] || [ "$TERM" == "screen-256color" ] || [ "$TERM" == "xterm-256color" ]; then
        TERM=screen-256color
        export PROMPT_COMMAND='printf "\033]0;%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'

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
fi

# For virtual env in pew
[[ -z "${VIRTUAL_ENV}" ]] || PS1="(\$(basename '$VIRTUAL_ENV'))$PS1"
export PS1
