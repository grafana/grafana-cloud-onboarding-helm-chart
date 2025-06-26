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

- [ ] Add a golden record test for Alloy CR
- [ ] Documentation for values.yaml
- [ ] More examples
- [ ] More unit tests
- [ ] Integration tests
- [ ] Platform tests
