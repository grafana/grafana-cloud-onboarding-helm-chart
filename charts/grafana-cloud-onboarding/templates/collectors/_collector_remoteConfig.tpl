{{- define "collectors.remoteConfig.defaultAttributes" }}
platform: kubernetes
source: {{ .Chart.Name }}
sourceVersion: {{ .Chart.Version }}
release: {{ .Release.Name }}
cluster: {{ .Values.cluster.name }}
namespace: {{ .Release.Namespace }}
workloadName: {{ .collectorName }}
workloadType: {{ .collectorValues.controller.type }}
{{- end }}

{{- /* Builds the alloy config for remoteConfig */ -}}
{{- define "collectors.remoteConfig.alloy" }}
{{- with merge .Values.grafanaCloud.fleetManagement (dict "type" "fleetManagement" "name" "fleet-management") }}
  {{- $attributes := (include "collectors.remoteConfig.defaultAttributes" $ | fromYaml) | merge .extraAttributes (index $.collectorValues "attributes") }}
  {{- if eq (include "secrets.usesKubernetesSecret" .) "true" }}
    {{- include "secret.alloy" (deepCopy $ | merge (dict "object" .)) | nindent 0 }}
  {{- end }}
remotecfg {
  id = sys.env("GCLOUD_FM_COLLECTOR_ID")
{{- if .urlFrom }}
  url = {{ .urlFrom }}
{{- else }}
  url = {{ .url | quote }}
{{- end }}
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
{{- if .tls }}
  tls_config {
    insecure_skip_verify = {{ .tls.insecureSkipVerify | default false }}
    {{- if .tls.caFile }}
    ca_file = {{ .tls.caFile | quote }}
    {{- else if eq (include "secrets.usesSecret" (dict "object" . "key" "tls.ca")) "true" }}
    ca_pem = {{ include "secrets.read" (dict "object" . "key" "tls.ca" "nonsensitive" true) }}
    {{- end }}
    {{- if .tls.certFile }}
    cert_file = {{ .tls.certFile | quote }}
    {{- else if eq (include "secrets.usesSecret" (dict "object" . "key" "tls.cert")) "true" }}
    cert_pem = {{ include "secrets.read" (dict "object" . "key" "tls.cert" "nonsensitive" true) }}
    {{- end }}
    {{- if .tls.keyFile }}
    key_file = {{ .tls.keyFile | quote }}
    {{- else if eq (include "secrets.usesSecret" (dict "object" . "key" "tls.key")) "true" }}
    key_pem = {{ include "secrets.read" (dict "object" . "key" "tls.key") }}
    {{- end }}
  }
{{- end }}
  poll_frequency = {{ .pollFrequency | quote }}
  attributes = {
{{- range $key, $value := $attributes }}
  {{- if $value }}
    {{ $key | quote }} = {{ $value | quote }},
  {{- end }}
{{- end }}
  }
}
  {{- end -}}
{{- end -}}

{{- define "secrets.list.fleetManagement" -}}
- auth.username
- auth.password
- tls.ca
- tls.cert
- tls.key
{{- end -}}
