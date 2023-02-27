#!/bin/bash

# Install the Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install kubectl
echo "Installing kubectl..."
az aks install-cli
