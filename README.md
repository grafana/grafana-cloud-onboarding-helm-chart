# Grafana Cloud Onboarding Helm Chart

This repository contains the new Grafana Cloud Onboarding Helm Chart. It is used for the new and improved onboarding workflow that
can leverage Alloy with remote Fleet Management and autoinstrumentation with Beyla to configure the instrumentaion via Grafana Cloud UI.

Status: Work in progress

## Dependencies

- Helm: <https://helm.sh/>
- Taskfile: <https://taskfile.dev>
- kubectl: <https://kubernetes.io/docs/tasks/tools/>

## Running tests

```shell
task test
```

## TODO

- [ ] Markdown documentation for values.yaml
- [ ] More examples
- [ ] More unit tests
- [ ] Integration tests
- [ ] Platform tests
