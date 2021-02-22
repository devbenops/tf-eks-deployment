#!/bin/bash -x

## Install metrics server on the kubernetes cluster ##

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml