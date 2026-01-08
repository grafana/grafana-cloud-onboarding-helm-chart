# Grafana Cloud Onboarding

The Grafana Cloud Onboarding Helm Chart enables easy deployment of necessary components for onboarding a Kubernetes cluster to Grafana Cloud. 

It is designed to work specifically with [Fleet Management](https://grafana.com/docs/grafana-cloud/send-data/fleet-management/introduction/) and [Instrumentation Hub](https://grafana.com/docs/grafana-cloud/get-started/inst-hub-setup/), which enable pushing remote configurations to [Grafana Alloy](https://grafana.com/docs/alloy/latest/) and automatic configurable service discovery via [Beyla](https://grafana.com/docs/beyla/latest/).


## Usage

1. Create an access policy token that is required for Grafana Alloy to send metrics and logs to Grafana Cloud. The token must have `metrics:read` and `set:alloy-data-write` scopes. For more information, see [Create access policies and tokens](https://grafana.com/docs/grafana-cloud/security-and-account-management/authentication-and-permissions/access-policies/create-access-policies/).

2. Setup Grafana chart repository
    
    `helm repo add grafana https://grafana.github.io/helm-charts`

    `helm repo update`

3. Install the chart using the following command, replacing `<username>`, `<password>`, and `<url>` accordingly.

    `helm upgrade --install grafana-cloud -n monitoring --create-namespace grafana/grafana-cloud-onboarding --set "cluster.name=$(kubectl config current-context)" --set "grafanaCloud.fleetManagement.auth.password=<password>" --set "grafanaCloud.fleetManagement.auth.username=<username>" --set "grafanaCloud.fleetManagement.url=<url>" --wait`

### Build your values

If you are following a GitOps approach, you can modify the `values.yaml` file rather than directly passing values in the command line. The basic structure of the values file that include the required values is as follows:

```yaml
cluster: # Cluster configuration, including the cluster name
  name: my-cluster

# Connection information with Grafana Cloud
grafanaCloud:
  fleetManagement:
    url: https://fleet.grafana.com # Replace with your Fleet Management URL
    auth:
      type: basic
      username: 123456 # Replace with your username
      password: glc_thisismypassword # Replace with your actual access policy token
```

Here is more detail about the different sections:

#### Cluster

This section defines the name of your cluster, which will be set as labels to all telemetry data.

```yaml
cluster:
  name: my-cluster
```

*Note: the cluster name must consist of lower case alphanumeric characters or '-', and must start and end with an alphanumeric character.*

#### Collectors

This section defines the list of collectors to deploy. 

Each `collectors.<name>` field will deploy Alloy helm chart using `<name>`.

Under `<name>` field you can configure all options from the Alloy CRD, which matches the Alloy Helm chart values.yaml.

```yaml
collectors:
  alloy-daemon:
    alloy:
        storagePath: /var/lib/alloy
    # etc...
```

To see available fields, consult [Alloy helm chart's values.yaml](https://github.com/grafana/alloy/tree/main/operations/helm/charts/alloy).

#### Alloy Operator
This section defines the configuration for the Alloy Operator, which is responsible for managing Alloy instances and their lifecycle.

```yaml
alloyOperator:
  enabled: true
  # etc...
```

#### Beyla
This section defines the configuration for Beyla as astandalone Daemonset, which is responsible for service discovery and automatic instrumentation. 

*Note: Beyla is disabled by default as we are using the beyla embedded into Alloy.*

```yaml
beyla:
  enabled: false
  # etc...
```

#### Kube State Metrics
This section defines the configuration for Kube State Metrics, which is responsible for collecting Kubernetes cluster state and performance metrics. This is installed by default and can be controlled using fleet management.

```yaml
kubeStateMetrics:
  enabled: true
  # etc...
```

#### Node Exporter
This section defines the configuration for Node Exporter, which is responsible for collecting hardware and OS metrics from the nodes. This is installed by default and can be controlled using fleet management.

```yaml
prometheus-node-exporter:
  enabled: true
  # etc...
```

#### Windows Exporter
This section defines the configuration for Windows Exporter, which is responsible for collecting hardware and OS metrics from Windows nodes. This is disabled by default.

*Note: it must be enabled before utilizing it through Fleet Management remote configuration.*

```yaml
prometheus-windows-exporter:
  enabled: false
  # etc...
```

#### Kepler

This section defines the configuration for Kepler, which is responsible for collecting energy consumption metrics from the nodes. This is disabled by default.

*Note: it must be enabled before utilizing it through Fleet Management remote configuration.*

```yaml
kepler:
  enabled: false
  # etc...
```