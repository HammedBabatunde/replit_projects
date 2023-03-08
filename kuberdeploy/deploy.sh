#!/bin/bash

# Set variables
RESOURCE_GROUP=resourceGroup
CLUSTER_NAME=aks_cluster
LOCATION=eastus
NAMESPACE=kubeflow-dev

#You can try different version of kuberflow 1.3.0

##login to azure
az login

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 2 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --kubernetes-version 1.24.6 \
    --location $LOCATION

# Connect to cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Create namespace
kubectl create namespace $NAMESPACE
# kubectl config set-context --current --namespace=$NAMESPACE

# Install kustomize
brew install kustomize

# Clone Kubeflow manifests repository
git clone --branch v1.4-branch --single-branch https://github.com/kubeflow/manifests.git

# Build Kubeflow manifests using kustomize
cd manifests/v1.4-branch/
kustomize build manifests/kustomize/env/azure > kubeflow.yaml

# Deploy Kubeflow
kubectl apply -f kubeflow.yaml -n $NAMESPACE

# Wait for deployment to finish
kubectl wait --for=condition=available --timeout=10m deployment --all -n $NAMESPACE

# Verify Kubeflow deployment
kubectl get pods -n $NAMESPACE

# Display Kubeflow endpoint
echo "Kubeflow endpoint:"
kubectl describe ingress -n istio-system | grep "Address:"
