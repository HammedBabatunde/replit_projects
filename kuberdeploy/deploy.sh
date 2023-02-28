#!/bin/bash

# Set variables
RESOURCE_GROUP=resourceGroup
CLUSTER_NAME=aks_cluster
LOCATION=eastus
NAMESPACE=kubeflow-dev
KF_VERSION=v1.3.0
KUSTOMIZE_VERSION=$(kustomize version | grep Version | awk '{print $2}')
# KUSTOMIZE=/usr/local/bin/kustomize

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster
az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 2 --enable-addons monitoring --generate-ssh-keys --kubernetes-version 1.24.6 --location $LOCATION

# Connect to cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Install kubeflow
kubectl create namespace $NAMESPACE
kubectl config set-context --current --namespace=$NAMESPACE
# kubectl apply -k "github.com/kubeflow/manifests/kustomize/${KF_VERSION}?ref=${KF_VERSION}"
kubectl kustomize "github.com/kubeflow/manifests/kustomize/${KF_VERSION}?ref=${KF_VERSION}" | $KUSTOMIZE_VERSION build - | kubectl apply -f -

# Wait for deployment to finish
kubectl wait --for=condition=available --timeout=10m deployment --all -n $NAMESPACE

# Display Kubeflow endpoint
echo "Kubeflow endpoint:"
kubectl describe ingress -n istio-system | grep "Address:"
