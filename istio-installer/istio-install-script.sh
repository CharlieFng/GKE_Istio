#!/bin/bash

echo "Downlaod Istio"
curl -L https://github.com/istio/istio/releases/download/1.1.13/istio-1.1.13-linux.tar.gz | tar xz

echo "Add Istio to path"
cd  istio-1.1.13
export PATH=$PATH:${PWD}/bin

echo "Create istio-system namespace"
kubectl create namespace istio-system

echo "Copy CA to istio-system namespace"
kubectl get secret istio-ca-secret --namespace=kube-system --export -o yaml | kubectl apply --validate=false --namespace=istio-system -f -

echo "Install Istio CRD's"
helm template install/kubernetes/helm/istio-init \
  --name istio-init --namespace istio-system | kubectl apply -f -

echo "Wait for CRD's to be completed"
kubectl -n istio-system wait --for=condition=complete job --all


