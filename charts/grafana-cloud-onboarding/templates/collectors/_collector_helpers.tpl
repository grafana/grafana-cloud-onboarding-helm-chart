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

{{- define "collector.alloy.loggingConfig" -}}
{{- if .collectorValues.logging }}
logging {
{{- if .collectorValues.logging.level }}
  level = {{ .collectorValues.logging.level | quote }}
{{- end }}
{{- if .collectorValues.logging.format }}
  format = {{ .collectorValues.logging.format | quote }}
{{- end }}
}
{{- end }}
{{- end }}

{{- define "collector.alloy.liveDebuggingConfig" -}}
{{- if .collectorValues.liveDebugging }}
livedebugging {
  enabled = {{ .collectorValues.liveDebugging.enabled }}
}
{{- end }}
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

{{- /* Prepend built-in environment variables to extraEnv */ -}}
{{- $clusterNameEnv := list (dict "name" "CLUSTER_NAME" "value" $.Values.cluster.name) }}
{{- $fleetManagementObject := merge .Values.grafanaCloud.fleetManagement (dict "type" "fleetManagement" "name" "fleet-management") }}

{{- /* Determine the GCLOUD_RW_API_KEY environment variable */ -}}
{{- $gcloudApiKeyEnv := list }}
{{- if eq (include "secrets.usesKubernetesSecret" $fleetManagementObject) "true" }}
  {{- $secretName := include "secrets.kubernetesSecretName" (deepCopy $ | merge (dict "object" $fleetManagementObject)) }}
  {{- $secretNamespace := include "secrets.kubernetesSecretNamespace" (deepCopy $ | merge (dict "object" $fleetManagementObject)) }}
  {{- $secretKey := include "secrets.getSecretKey" (deepCopy $ | merge (dict "object" $fleetManagementObject "key" "auth.password")) }}
  {{- $gcloudApiKeyEnv = list (dict "name" "GCLOUD_RW_API_KEY" "valueFrom" (dict "secretKeyRef" (dict "name" $secretName "key" $secretKey "namespace" $secretNamespace))) }}
{{- end }}

{{- /* Determine the NAMESPACE environment variable */ -}}
{{- $namespaceEnv := list (dict "name" "NAMESPACE" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.namespace"))) }}

{{- /* Determine the POD_NAME environment variable */ -}}
{{- $podNameEnv := list (dict "name" "POD_NAME" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.name"))) }}

{{- /* Determine the GCLOUD_FM_COLLECTOR_ID environment variable */ -}}
{{- $gcloudFmCollectorIdEnv := list (dict "name" "GCLOUD_FM_COLLECTOR_ID" "value" "alloy-$(CLUSTER_NAME)-$(NAMESPACE)-$(POD_NAME)") }}

{{- /* Add the environment variables to the Alloy values */ -}}
{{- $additionalEnvs := concat $clusterNameEnv $gcloudApiKeyEnv $namespaceEnv $podNameEnv $gcloudFmCollectorIdEnv }}
{{- if $alloyValues.alloy.extraEnv }}
  {{- $alloyValues = mergeOverwrite $alloyValues (dict "alloy" (dict "extraEnv" (concat $additionalEnvs $alloyValues.alloy.extraEnv))) }}
{{- else }}
  {{- $alloyValues = mergeOverwrite $alloyValues (dict "alloy" (dict "extraEnv" $additionalEnvs)) }}
{{- end }}

{{- $alloyConfigContent := include "collectors.remoteConfig.alloy" (deepCopy $ | merge (dict "collectorName" .collectorName "collectorValues" $alloyValues)) }}
{{- $loggingConfig := include "collector.alloy.loggingConfig" (deepCopy $ | merge (dict "collectorName" .collectorName "collectorValues" $alloyValues)) }}
{{- $liveDebuggingConfig := include "collector.alloy.liveDebuggingConfig" (deepCopy $ | merge (dict "collectorName" .collectorName "collectorValues" $alloyValues)) }}
{{- $alloyConfigContent = cat $alloyConfigContent $loggingConfig $liveDebuggingConfig }}
{{- $alloyConfigContent = regexReplaceAll `[ \t]+(\r?\n)` $alloyConfigContent "\n" | trim }}
{{- $alloyConfig := dict "alloy" (dict "configMap" (dict "content" $alloyConfigContent)) }}
{{ mergeOverwrite $alloyValues $alloyConfig | toYaml }}
{{- end }}

{{/* Lists the fields that are not a part of Alloy itself, and should be removed before creating an Alloy instance. */}}
{{/* Inputs: (none) */}}
{{- define "collector.alloy.extraFields" }}
- attributes
- logging
- liveDebugging
{{- end }}
