#!/bin/bash
# Initial package installation

sudo dnf update --refresh

# Neomutt
sudo dnf copr enable flatcap/neomutt

# RPMFusion and adobe
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
sudo dnf group upgrade --with-optional Multimedia

# Music and multimedia
# https://docs.fedoraproject.org/en-US/quick-docs/assembly_installing-plugins-for-playing-movies-and-music/
# https://rpmfusion.org/Configuration

sudo dnf groupupdate multimedia
sudo dnf groupupdate sound-and-video

# Fusion appstream data
sudo dnf groupupdate core

# Basics
sudo dnf install byobu tmux htop syncthing vit task neomutt weechat ncmpcpp \
    mpv vimiv vifm fedora-packager git-all offlineimap msmtp notmuch gnuplot \
    /usr/bin/ag aria2 qutebrowser cscope ctags fedora-review mpd vim-enhanced \
    vim-X11 notmuch-vim notmuch-mutt rcm pwgen pass \
    python3-websocket-client xsel flash-plugin deja-dup parcellite \
    anka-coder-fonts zathura zathura-plugins-all urlscan timew \
    gnome-pomodoro docker podman

# texlive bits
sudo dnf install texlive /usr/bin/pdflatex /usr/bin/latexmk /usr/bin/chktex \
    /usr/bin/lacheck /usr/bin/biber /usr/bin/flake8-3 /usr/bin/perlcritic \
    /usr/bin/rstcheck texlive-epstopdf texlive-biblatex-nature \
    texlive beamertheme-metropolis pdfpc
