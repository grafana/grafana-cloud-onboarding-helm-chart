{{- define "collector.alloy.fullname" -}}
  {{- $collectorValues := (index .Values .collectorName) }}
  {{- if $collectorValues.fullnameOverride }}
    {{- $collectorValues.fullnameOverride | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $name := default .collectorName .Values.nameOverride }}
    {{- if contains $name .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "collector.alloy.labels" -}}
helm.sh/chart: {{ include "helper.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: alloy
{{- end }}

{{- define "collector.alloy.selectorLabels" -}}
app.kubernetes.io/name: {{ .collectorName }}
app.kubernetes.io/instance: {{ include "collector.alloy.fullname" . }}
{{- end }}

{{- define "collector.alloy.values.global"}}
{{- $globalValues := dict }}
{{- if dig "image" "registry" "" .Values.global }}
  {{- $globalValues = mergeOverwrite $globalValues (dict "global" (dict "image" (dict "registry" .Values.global.image.registry))) }}
{{- end }}
{{- if dig "image" "pullSecrets" "" .Values.global }}
  {{- $globalValues = mergeOverwrite $globalValues (dict "global" (dict "image" (dict "pullSecrets" .Values.global.image.pullSecrets))) }}
{{- end }}
{{- if dig "podSecurityContext" "" .Values.global }}
  {{- $globalValues = mergeOverwrite $globalValues (dict "global" (dict "podSecurityContext" .Values.global.podSecurityContext)) }}
{{- end }}
{{- $globalValues | toYaml }}
{{- end }}

{{- /* Gets the Alloy values. Input: $, .collectorName (string, collector name), .collectorValues (object) */ -}}
{{- define "collector.alloy.values" -}}
{{- $upstreamValues := "collectors/upstream/alloy-values.yaml" | .Files.Get | fromYaml }}
{{- $defaultValues := "collectors/alloy-values.yaml" | .Files.Get | fromYaml }}
{{- $globalValues := include "collector.alloy.values.global" . | fromYaml }}
{{- $userValues := $.collectorValues }}
{{- if not $.collectorValues }}
  {{- $userValues = (index $.Values.collectors .collectorName) }}
{{- end }}
{{- $alloyValues := mergeOverwrite $upstreamValues $defaultValues $globalValues $userValues }}
{{- $alloyConfigContent := include "collectors.remoteConfig.alloy" (deepCopy $ | merge (dict "collectorName" .collectorName "collectorValues" $alloyValues)) }}
{{- $alloyConfigContent = regexReplaceAll `[ \t]+(\r?\n)` $alloyConfigContent "\n" | trim }}
{{- $alloyConfig := dict "alloy" (dict "configMap" (dict "content" $alloyConfigContent)) }}
{{ mergeOverwrite $alloyValues $alloyConfig | toYaml }}
{{- end }}

{{/* Lists the fields that are not a part of Alloy itself, and should be removed before creating an Alloy instance. */}}
{{/* Inputs: (none) */}}
{{- define "collector.alloy.extraFields" }}
- attributes
{{- end }}
