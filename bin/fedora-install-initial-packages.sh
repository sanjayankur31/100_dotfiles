#!/bin/bash
REL="$(rpm -E %fedora)"
echo "We are running Fedora $REL."

setup_repos() {
    # Neomutt
    sudo dnf copr enable flatcap/neomutt
    # taskjuggler
    sudo dnf copr enable ankursinha/rubygem-taskjuggler
    # NeuroFedora
    sudo dnf copr enable @neurofedora/neurofedora-extra

    # RPMFusion
    sudo dnf install \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$REL".noarch.rpm \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$REL".noarch.rpm \

    sudo dnf update --refresh
}

install_adobe () {
    sudo dnf install http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
    sudo dnf install flash-plugin
}

update_groups() {
    sudo dnf group upgrade --with-optional Multimedia

    # Music and multimedia
    # https://docs.fedoraproject.org/en-US/quick-docs/assembly_installing-plugins-for-playing-movies-and-music/
    # https://rpmfusion.org/Configuration
    sudo dnf groupupdate multimedia
    sudo dnf groupupdate sound-and-video

    # Fusion appstream data
    sudo dnf groupupdate core

}

install_basics() {
    # Basics
    sudo dnf install byobu tmux htop syncthing vit task taskopen tasksh neomutt \
    weechat mpv vimiv-qt vifm fedora-packager git-all offlineimap msmtp \
    notmuch gnuplot /usr/bin/rg aria2 qutebrowser cscope ctags fedora-review \
    vim-enhanced vim-X11 notmuch-vim notmuch-mutt rcm pwgen pass \
    python3-websocket-client xsel flash-plugin deja-dup \
    anka-coder-\* zathura zathura-plugins-all urlscan timew \
    /usr/bin/ps2pdf psutils gnome-pomodoro podman python3-unidecode \
    open-sans-fonts  /usr/bin/xindy rubygem-taskjuggler fzf wl-clipboard \
    qgnomeplatform cowsay fortune-mod ledger bat pew python3-devel \
    @python-science clang-devel @c-development w3m python3-mailmerge \
    qt5-qtwebengine{-freeworld,-devtools} \
    /usr/bin/texcount podman kubernetes-client \
    closure-compiler wofi fd-find /usr/bin/rstcheck /usr/bin/mypy \
    python3-peewee libolm-python3 python3-jedi /usr/bin/flake8 /usr/bin/perlcritic \
    trash-cli gnome-tweak-tool evolution bash-completion \
    gnome-extensions-app cmake npm newsboat \
    --setopt=strict=0

    # parcellite
    }

install_texlive_packages() {
    # texlive bits
    # some bits for muttprint
    sudo dnf install texlive /usr/bin/pdflatex /usr/bin/latexmk /usr/bin/chktex \
        /usr/bin/lacheck /usr/bin/biber texlive-epstopdf texlive-biblatex-nature \
        'tex(array.sty)' 'tex(babel.sty)' 'tex(fancyhdr.sty)' 'tex(fancyvrb.sty)' \
        'tex(fontenc.sty)' 'tex(graphicx.sty)' 'tex(inputenc.sty)' \
        'tex(lastpage.sty)' 'tex(marvosym.sty)' 'tex(textcomp.sty)' \
        texlive-beamertheme-metropolis pdfpc xdotool /usr/bin/latexindent --setopt=strict=0
}


install_flatpaks() {
    # Flatpaks
    echo "Installing flatpaks from Flathub"
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    flatpak --user install flathub com.skype.Client
    flatpak --user install flathub com.spotify.Client
    flatpak --user install flathub org.telegram.desktop
    flatpak --user install flathub org.signal.Signal
    flatpak --user install flathub com.uploadedlobster.peek
    flatpak --user install flathub com.jgraph.drawio.desktop
}

install_nvidia() {
    echo "Installing Nvidia drivers"
    echo "Do remember to disable secure boot"
    sudo dnf install akmod-nvidia
    sudo dnf install xorg-x11-drv-nvidia-cuda
}


usage() {
    echo "$0: Install packages and software"
    echo
    echo "Usage: $0 [-subtfanFh]"
    echo
    echo "-s: set up DNF repos"
    echo "-u: update groups: implies -s"
    echo "-b: install basics: implies -s"
    echo "-t: install TeXlive packages: implies -s"
    echo "-f: install flatpaks from flathub: also sets up flathub"
    echo "-a: do all of the above"
    echo "-n: install nvidia driver"
    echo "-F: install Flash plugin"
    echo "-h: print this usage text and exit"
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

# parse options
while getopts "usbtfahnF" OPTION
do
    case $OPTION in
        s)
            setup_repos
            exit 0
            ;;
        u)
            setup_repos
            update_groups
            exit 0
            ;;
        b)
            setup_repos
            install_basics
            exit 0
            ;;
        t)
            setup_repos
            install_texlive_packages
            exit 0
            ;;
        f)
            install_flatpaks
            exit 0
            ;;
        n)
            setup_repos
            install_nvidia
            exit 0
            ;;
        a)
            setup_repos
            update_groups
            install_basics
            install_texlive_packages
            install_flatpaks
            exit 0
            ;;
        F)
            install_adobe
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done
