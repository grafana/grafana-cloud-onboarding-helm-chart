# Config Snippets

These are config snippets that can be used in fleet management

## Kubernetes Infrastructure Observability

### Kubelet and cAdvisor

This shows how to discover and scrape metrics from the Kubelet's various endpoints:

* Kubelet
* Kubelet Resources
* Kubelet Probes
* cAdvisor

### kube-state-metrics

1. Beyla's discovery should assess if kube-state-metrics is running in the cluster.
2. If so, deploy an endpoints snippet with the following details:
    * The Service name (i.e. `kube-state-metrics`)
    * The Service namespace (i.e. `monitoring`)
    * The job name (i.e. `integrations/kubernetes/kube-state-metrics`)
    * The metrics allow list
3. If not, send a message to the user indicating that kube-state-metrics is not running in the cluster and should be installed.

### Node Exporter

1. Beyla's discovery should assess if Node Exporter is running in the cluster.
2. If so, deploy a pod snippet with the following details:
    * The Pod name (i.e. `kube-state-metrics`)
    * The Pods namespace (i.e. `monitoring`)
    * The job name (i.e. `integrations/node_exporter`)
    * The metrics allow list
3. If not, send a message to the user indicating that Node Exporter is not running in the cluster and should be installed.

