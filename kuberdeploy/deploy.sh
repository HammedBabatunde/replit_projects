#!/bin/bash

# Variables
RESOURCE_GROUP=resourceGroup
CLUSTER_NAME=aks_cluster
LOCATION=eastus
KF_VERSION=1.3.0
KUSTOMIZE_VERSION=5.2.0

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster
az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 2 --enable-addons monitoring --generate-ssh-keys

# Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

# Deploy Kubeflow
KF_DIR=kubeflow
mkdir $KF_DIR && cd $KF_DIR

# Download Kubeflow manifests
curl -sSL "https://github.com/kubeflow/manifests/archive/refs/tags/v${KF_VERSION}.tar.gz" | tar xz

# Install kfctl
curl -sSL "https://github.com/kubeflow/kfctl/releases/download/v${KF_VERSION}/kfctl_v${KF_VERSION}_darwin.tar.gz" | tar xz

# Set kfctl path
export PATH=$PATH:$PWD

# Deploy Kubeflow
kfctl apply -V -f manifests-${KF_VERSION}/kfdef/kfctl_azure.v1.2.0.yaml

# Wait for Kubeflow to be deployed
kubectl wait --for=condition=Ready pod --all -n kubeflow --timeout=600s

# Clean up temporary files
cd ..
rm -rf $KF_DIR

echo "Kubeflow successfully deployed."