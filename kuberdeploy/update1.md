If you have kustomize installed and it's working when you run the `kubectl kustomize` command, then the issue might be related to the version of kustomize that's being used by Kubeflow.

To fix this issue, you can specify the KUSTOMIZE_VERSION environment variable to use the version of kustomize that's installed on your machine. Here's how you can modify the deployment script to do this:

Add the following line at the beginning of the script to set the KUSTOMIZE_VERSION environment variable:

javascript

```sh
KUSTOMIZE_VERSION=$(kustomize version | grep Version | awk '{print $2}')
```

This will set the KUSTOMIZE_VERSION environment variable to the version of kustomize that's installed on your machine.

Replace the following line in the script:

bash

```sh
kubectl apply -k "github.com/kubeflow/manifests/kustomize/${KF_VERSION}?ref=${KF_VERSION}"
```

with the following line:

```sh
kubectl kustomize "github.com/kubeflow/manifests/kustomize/${KF_VERSION}?ref=${KF_VERSION}" | $KUSTOMIZE_VERSION build - | kubectl apply -f -
```

This will tell kubectl to use the kustomize binary that's installed on your machine.

After making these changes, try running the deployment script again. It should use the correct version of kustomize and generate the Kubernetes manifests successfully.
