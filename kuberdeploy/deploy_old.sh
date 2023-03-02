#!/bin/bash

# Set variables
RESOURCE_GROUP=resourceGroup
CLUSTER_NAME=aks_cluster
LOCATION=eastus
NAMESPACE=kubeflow-dev
KF_VERSION=v1.3.0


# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster
az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 2 --enable-addons monitoring --generate-ssh-keys --kubernetes-version 1.24.6 --location $LOCATION

# Connect to cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
export PATH=$PATH:$HOME/bin

# Set the KUSTOMIZE_PLUGIN_HOME environment variable
KUSTOMIZE_PLUGIN_HOME=$HOME/.config/kustomize/plugin

# Install kubeflow
kubectl create namespace $NAMESPACE
kubectl config set-context --current --namespace=$NAMESPACE

# Download the Kubeflow manifests and apply them using kustomize
mkdir -p $KUSTOMIZE_PLUGIN_HOME/kubeflow.org/v1alpha1/kustomizeconfig
curl -sSL "https://github.com/kubeflow/manifests/archive/refs/tags/v${KF_VERSION}.tar.gz" | tar xz
mv manifests-${KF_VERSION}/kustomize/* $KUSTOMIZE_PLUGIN_HOME/kubeflow.org/v1alpha1/kustomizeconfig/
kustomize build "github.com/kubeflow/manifests/kustomize/${KF_VERSION}?ref=${KF_VERSION}" | kubectl apply -f -

# kubectl apply -k "github.com/kubeflow/manifests/kustomize/${KF_VERSION}?ref=${KF_VERSION}"
# kubectl kustomize "github.com/kubeflow/manifests/kustomize/${KF_VERSION}?ref=${KF_VERSION}" | $KUSTOMIZE_VERSION build - | kubectl apply -f -
# kubectl kustomize "github.com/kubeflow/manifests/kustomize/${KF_VERSION}?ref=${KF_VERSION}" | kubectl apply --kustomize=- --kustomize-version=$KUSTOMIZE_VERSION

# Wait for deployment to finish
kubectl wait --for=condition=available --timeout=10m deployment --all -n $NAMESPACE

# Display Kubeflow endpoint
echo "Kubeflow endpoint:"
kubectl describe ingress -n istio-system | grep "Address:"
