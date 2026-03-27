#!/bin/bash
REL="$(rpm -E %fedora)"
echo "We are running Fedora $REL."

setup_repos() {
    sudo dnf install dnf5-plugins
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

update_groups() {
    sudo dnf group upgrade --with-optional Multimedia

    # Music and multimedia
    # https://docs.fedoraproject.org/en-US/quick-docs/assembly_installing-plugins-for-playing-movies-and-music/
    # https://rpmfusion.org/Configuration
    sudo dnf groupupdate multimedia
    sudo dnf groupupdate sound-and-video

    # Fusion appstream data
    sudo dnf groupupdate core

    # https://rpmfusion.org/CommonBugs?highlight=%28ffmpeg%29
    # swap
    sudo dnf swap ffmpeg-free ffmpeg --allowerasing


}

install_basics() {
    # Basics
    sudo dnf install \
        --setopt=strict=0 \
        /usr/bin/mypy \
        /usr/bin/perlcritic \
        /usr/bin/rg \
        /usr/bin/rstcheck \
        @c-development \
        @python-science \
        ShellCheck \
        anka-coder-\* \
        ansi2html \
        aria2 \
        bash-completion \
        bat \
        byobu \
        clang-devel \
        closure-compiler \
        cmake \
        cowsay \
        cscope \
        ctags \
        deja-dup \
        evolution \
        evolution-ews \
        fbrnch \
        fd-find \
        fedora-packager \
        fedora-review \
        fedrq \
        firewall-config \
        fortune-mod \
        fzf \
        gcolor3 \
        git-all \
        gnome-extensions-app \
        gnome-pomodoro \
        gnome-tweak-tool \
        gnuplot \
        htop \
        kstart \
        kubernetes-client \
        ledger \
        mpv \
        msmtp \
        mupdf \
        neomutt \
        newsboat \
        notmuch \
        notmuch-mutt \
        notmuch-vim \
        npm \
        offlineimap \
        open-sans-fonts \
        pass \
        podman \
        psi-notify \
        psutils \
        pwgen \
        python3-devel \
        python3-jedi \
        python3-mailmerge \
        python3-msal \
        python3-peewee \
        python3-typer \
        python3-unidecode \
        python3-websocket-client \
        qt6-qtwebengine{,-devtools} \
        qutebrowser \
        rcm \
        rfpkg \
        rofi \
        rpmfusion-packager \
        rubygem-taskjuggler \
        rubygem-webrick \
        ruff \
        syncthing \
        task \
        taskopen \
        tasksh \
        timew \
        tmux \
        trash-cli \
        urlscan \
        uv \
        vim-X11 \
        vim-enhanced \
        vimiv-qt \
        vit \
        w3m \
        weechat \
        wl-clipboard \
        wofi \
        zathura \
        zathura-plugins-all
}

install_texlive_packages() {
    # texlive bits
    # some bits for muttprint
    sudo dnf install  \
        --setopt=strict=0 \
        'tex(array.sty)' \
        'tex(babel.sty)' \
        'tex(fancyhdr.sty)' \
        'tex(fancyvrb.sty)' \
        'tex(fontenc.sty)' \
        'tex(graphicx.sty)' \
        'tex(inputenc.sty)' \
        'tex(lastpage.sty)' \
        'tex(marvosym.sty)' \
        'tex(textcomp.sty)' \
        /usr/bin/biber \
        /usr/bin/chktex \
        /usr/bin/lacheck \
        /usr/bin/latexindent \
        /usr/bin/latexmk \
        /usr/bin/pdflatex \
        /usr/bin/ps2pdf \
        /usr/bin/texcount \
        /usr/bin/texexpand \
        /usr/bin/xindy \
        fedtex \
        pdfpc \
        proselint \
        texlive \
        texlive-beamertheme-metropolis \
        texlive-biblatex-nature \
        texlive-epstopdf \
        xdotool
}


install_flatpaks() {
    # Flatpaks
    echo "Installing flatpaks from Flathub"
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    #flatpak --user install flathub com.skype.Client
    #flatpak --user install flathub com.uploadedlobster.peek
    #flatpak --user install flathub com.jgraph.drawio.desktop

    flatpak --user install flathub com.spotify.Client
    flatpak --user install flathub org.telegram.desktop
    flatpak --user install flathub org.signal.Signal
    flatpak --user install flathub org.hdfgroup.HDFView
}

install_nvidia() {
    echo "Installing Nvidia drivers"
    echo "Do remember to disable secure boot"
    sudo dnf install akmod-nvidia
    sudo dnf install xorg-x11-drv-nvidia-cuda
}

enable_services () {
    echo "Starting/enabling syncthing"
    systemctl --user start syncthing.service
    systemctl --user enable syncthing.service

    echo "Starting/enabling psi-notify"
    systemctl --user start psi-notify.service
    systemctl --user enable psi-notify.service

    echo "Starting/enabling krenew"
    systemctl --user start krenew.service
    systemctl --user enable krenew.service

    # https://askubuntu.com/questions/340809/how-can-i-adjust-the-default-passphrase-caching-duration-for-gpg-pgp-ssh-keys/358514#358514
    echo "Configuring gnome-keyring to forget gpg passphrases after 7200 seconds"
    gsettings set org.gnome.crypto.cache gpg-cache-method "idle"
    gsettings set org.gnome.crypto.cache gpg-cache-ttl "7200"
}


usage() {
    echo "$0: Install packages and software"
    echo
    echo "Usage: $0 [-abefhnstu]"
    echo
    echo "-a: do all of the below"
    echo "-b: install basics: implies -s"
    echo "-e: enable services"
    echo "-f: install flatpaks from flathub: also sets up flathub"
    echo "-h: print this usage text and exit"
    echo "-n: install nvidia driver"
    echo "-s: set up DNF repos"
    echo "-t: install TeXlive packages: implies -s"
    echo "-u: update groups: implies -s"
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

# parse options
while getopts "abefhnstu" OPTION
do
    case $OPTION in
        a)
            setup_repos
            update_groups
            install_basics
            install_texlive_packages
            install_flatpaks
            enable_services
            exit 0
            ;;
        b)
            setup_repos
            install_basics
            enable_services
            exit 0
            ;;
        e)
            enable_services
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
        s)
            setup_repos
            exit 0
            ;;
        t)
            setup_repos
            install_texlive_packages
            exit 0
            ;;
        u)
            setup_repos
            update_groups
            enable_services
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
