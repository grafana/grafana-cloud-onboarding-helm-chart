{- /* Builds the alloy config for remoteConfig */ -}}
{{- define "collectors.remoteConfig.alloy" -}}
{{- with merge .Values.grafanaCloud.fleetManagement (dict "type" "fleetManagement" "name" "fleet-management") }}
  {{- if eq (include "secrets.usesKubernetesSecret" .) "true" }}
    {{- include "secret.alloy" (deepCopy $ | merge (dict "object" .)) | nindent 0 }}
  {{- end }}
remotecfg {
  id = sys.env("GCLOUD_FM_COLLECTOR_ID")
  url = {{ .url | quote }}
{{- if .proxyURL }}
  proxy_url = {{ .proxyURL | quote }}
{{- end }}
{{- if .noProxy }}
  no_proxy = {{ .noProxy | quote }}
{{- end }}
{{- if .proxyConnectHeader }}
  proxy_connect_header = {
{{- range $k, $v := .proxyConnectHeader }}
    {{ $k | quote }} = {{ $v | toJson }},
{{- end }}
  }
{{- end }}
{{- if .proxyFromEnvironment }}
  proxy_from_environment = {{ .proxyFromEnvironment }}
{{- end }}
{{- if eq (include "secrets.authType" .) "basic" }}
  basic_auth {
    username = {{ include "secrets.read" (dict "object" . "key" "auth.username" "nonsensitive" true) }}
    password = {{ include "secrets.read" (dict "object" . "key" "auth.password") }}
  }
{{- end }}
  poll_frequency = {{ .pollFrequency | quote }}
  attributes = {
    "platform" = "kubernetes",
    "source" = "{{ $.Chart.Name }}",
    "sourceVersion" = "{{ $.Chart.Version }}",
    "release" = "{{ $.Release.Name }}",
    "cluster" = {{ $.Values.cluster.name | quote }},
    "namespace" = {{ $.Release.Namespace | quote }},
{{/*    "workloadName" = {{ $.collectorName | quote }},*/}}
{{/*    "workloadType" = {{ $collectorValues.controller.type | quote }},*/}}
{{- range $key, $value := .extraAttributes }}
    {{ $key | quote }} = {{ $value | quote }},
{{- end }}
  }
}
  {{- end -}}
{{- end -}}

{{- define "secrets.list.remoteConfig" -}}
- auth.username
- auth.password
{{- end -}}
