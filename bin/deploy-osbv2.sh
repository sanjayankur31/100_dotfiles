#!/bin/bash

# Copyright 2021 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : start OSBv2 deployment

# depends on how you install it
CLOUD_HARNESS_DIR="$HOME/Documents/02_Code/00_mine/2020-OSB/osbv2/cloud-harness"
CLOUD_HARNESS_BRANCH="master"
SKAFFOLD="skaffold-linux-amd64"

# Py version
# Cloud harness doesn't always work on newer versions
PY_VERSION="python3.7"
# if not, specify location of virtualenv here
# I run this from the OSBv2 repo, so I create my venv there
VENV_DIR=".venv"

if ! command -v helm >/dev/null || ! command -v $SKAFFOLD >/dev/null || !  command -v harness-deployment  >/dev/null ; then
    echo "helm, skaffold, and cloud-harness are required but were not found."
    exit 1
fi

deploy () {
    echo "-> deploying"
    echo "-> checking (and starting) docker daemon"
    systemctl is-active docker --quiet || sudo systemctl start docker.service
    echo "-> starting minkube"
    minikube start --memory="8000mb" --cpus=6 --disk-size="50000mb" --kubernetes-version=v1.21.2 --driver=docker || notify_fail "Failed: minikube start"
    echo "-> enabling ingress addon"
    minikube addons enable ingress || notify_fail "Failed: ingress add on"
    echo "-> setting up osblocal namespace"
    kubectl get ns osblocal || kubectl create ns osblocal || notify_fail "Failed: ns set up"
    echo "-> setting up minikube docker env"
    eval $(minikube docker-env) || notify_fail "Failed: env setup"
    echo "-> harnessing deployment"
    # `-e local` does not build nwbexplorer/netpyne
    # use -e dev for that, but that will send e-mails to Filippo and Zoraan
    # suggested: create a new file in deploy/values-ankur.yaml where you use
    # your e-mail address, and then use `-e ankur` to use these values.
    harness-deployment ../cloud-harness . -l  -n osblocal -d osb.local -u -dtls -m build -e local -i osb-portal || notify_fail "Failed: harness-deployment"
    echo "-> running skaffold"
    $SKAFFOLD dev --cleanup=false || notify_fail "Failed: skaffold"
}

notify_fail () {
    if ! command -v notify-send >/dev/null
    then
        echo "-> $1"
    else
        notify-send -t 1000 -i "org.gnome.Terminal" -a "Terminal" "OSBv2 deployment" "$1"
    fi
    exit 1
}

function update_cloud_harness() {
    echo "Updating cloud harness"
    pushd "$CLOUD_HARNESS_DIR" && git checkout ${CLOUD_HARNESS_BRANCH} && git pull && pip install -r requirements.txt && popd
}

function activate_venv() {
    if [ -f "${VENV_DIR}/bin/activate" ]
    then
        source "${VENV_DIR}/bin/activate"
    else
        echo "No virtual environment found at ${VENV_DIR}. Creating"
        ${PY_VERSION} -m venv "${VENV_DIR}"
    fi
}

# don't actually need this because when the script exists, the environment is
# lost anyway
function deactivate_venv() {
    deactivate
}

function print_versions() {
    echo "** docker **"
    docker version
    echo "\n** minikube **"
    minikube version
    echo "\n** cloud harness **"
    pushd "${CLOUD_HARNESS_DIR}" && git log --oneline | head -1 && popd
    echo "\n** helm **"
    helm version
    echo "\n** skaffold **"
    $SKAFFOLD version
    echo "\n** python **"
    python --version
}

clean () {
    echo "-> Cleaning up all images."
    docker image prune --all
    minikube stop
    minikube delete
}

usage () {
    echo "USAGE $0 -[dv]"
    echo
    echo "-d: deploy"
    echo "-v: print version information"
    echo "-u branch: use (and update) provided cloud_harness branch (default: master)"
    echo "-h: print this and exit"
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi


# parse options
while getopts "vdu:h" OPTION
do
    case $OPTION in
        v)
            activate_venv
            print_versions
            deactivate_venv
            exit 0
            ;;
        d)
            activate_venv
            deploy
            exit 0
            ;;
        u)
            CLOUD_HARNESS_BRANCH=${OPTARG}
            activate_venv
            update_cloud_harness
            deactivate_venv
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
