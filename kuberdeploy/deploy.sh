#!/bin/bash

# Set variables
RESOURCE_GROUP=resourceGroup
CLUSTER_NAME=aks_cluster
LOCATION=eastus
NAMESPACE=kubeflow-dev

#Remember to try different version
# export KF_VERSION=1.3.0
export KF_VERSION=1.4.1


# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster
az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 2 --enable-addons monitoring --generate-ssh-keys --kubernetes-version 1.24.6 --location $LOCATION

# Connect to cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Create namespace
kubectl create namespace $NAMESPACE
kubectl config set-context --current --namespace=$NAMESPACE

# Install Kuberflow
mkdir kubeflow
cd kubeflow
curl -sSL "https://github.com/kubeflow/manifests/archive/v${KF_VERSION}.tar.gz" | tar xz
cd manifests-${KF_VERSION}/kustomize
kubectl apply -k ${NAMESPACE}/base

# Wait for deployment to finish
kubectl wait --for=condition=available --timeout=10m deployment --all -n $NAMESPACE

# Display Kubeflow endpoint
echo "Kubeflow endpoint:"
kubectl describe ingress -n istio-system | grep "Address:"
