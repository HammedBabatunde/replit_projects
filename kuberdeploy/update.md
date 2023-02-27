# The error message indicates that the deployment script is unable to locate the kustomize binary, which is required by Kubeflow to generate Kubernetes manifests

To fix this error, you can install kustomize on your machine and ensure that the script can find it. Here's how:

Download the kustomize binary by running the following command:

```sh
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
```

This will download the latest version of kustomize and place it in your current directory.

Move the kustomize binary to a directory in your $PATH. For example, you can move it to /usr/local/bin by running the following command:

```sh
sudo mv kustomize /usr/local/bin
```

This will make kustomize accessible from anywhere on your machine.

Edit the deployment script to ensure that it can find the kustomize binary, add this to the script.

```sh
KUSTOMIZE=/usr/local/bin/kustomize
```

This will tell the script to use the `kustomize` binary in the /usr/local/bin directory.

With these changes, the deployment script should be able to find the `kustomize` binary and generate the Kubernetes manifests successfully.
