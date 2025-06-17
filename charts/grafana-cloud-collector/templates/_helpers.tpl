{{ define "helper.kubernetesName" }}
{{- . | lower | replace " " "-" | replace "_" "-" -}}
{{ end }}

{{ define "helper.alloyName" }}
{{- . | lower | replace " " "_" | replace "-" "_" -}}
{{ end }}
