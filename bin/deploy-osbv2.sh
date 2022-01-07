#!/bin/bash

# Copyright 2021 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : start OSBv2 deployment

# depends on how you install it
SCAFFOLD="skaffold-linux-amd64"

if ! command -v helm >/dev/null || ! command -v $SCAFFOLD >/dev/null || !  command -v harness-deployment  >/dev/null ; then
    echo "helm, scaffold, and cloud-harness are required but were not found."
    exit -1
fi

sudo systemctl start docker.service
minikube start --memory="6000mb" --cpus=4 --disk-size=60000mb --kubernetes-version=v1.21.2 --driver=docker
minikube addons enable ingress
kubectl create ns osblocal
eval $(minikube docker-env)
harness-deployment ../cloud-harness . -l  -n osblocal -d osb.local -u -dtls -m build -e local -i osb-portal
$SCAFFOLD dev
