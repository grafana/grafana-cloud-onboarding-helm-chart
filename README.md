# Grafana Cloud Onboarding Helm Chart

This repository contains the new Grafana Cloud Onboarding Helm Chart. It is used for the new and improved onboarding workflow that
can leverage Alloy with remote Fleet Management and autoinstrumentation with Beyla.

Status: Work in progress

## Dependencies

- Helm: <https://helm.sh/>
- Taskfile: <https://taskfile.dev>

## Running tests

```shell
task test
```

## TODO

- [ ] Name of the repo `grafana-cloud-onboarding-helm-chart` vs. name of the chart `grafana-cloud-collector` - pick one name for both?
- [ ] `alloy-starter` as the default Alloy installation name - come up with something better?
- [ ] Documentation for values.yaml
- [ ] More examples
- [ ] GH actions CI
- [ ] More unit tests
- [ ] Integration tests
- [ ] Platform tests
- [ ] Protect main branch and require PR review workflow
