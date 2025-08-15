{{/* vim: set filetype=mustache: */}}

{{/*
Return a resource object based on preset or custom values
Usage (Bitnami-compatible style): 
{{ include "common.resources.preset" (dict 
    "type" .Values.resourcesPreset 
    "resources" .Values.resources 
    "context" .) }}

Available presets: nano, micro, small, medium, large, xlarge, 2xlarge
*/}}

{{- define "common.resources.preset" -}}
{{- $preset := .type -}}
{{- $resources := .resources -}}

{{/* Define resource presets directly in template (Bitnami style) */}}

{{- $presets := dict 
  "nano" (dict 
    "requests" (dict "cpu" "100m" "memory" "128Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "150m" "memory" "192Mi" "ephemeral-storage" "2Gi")
  )
  "micro" (dict 
    "requests" (dict "cpu" "250m" "memory" "256Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "375m" "memory" "384Mi" "ephemeral-storage" "2Gi")
  )
  "small" (dict 
    "requests" (dict "cpu" "500m" "memory" "512Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "750m" "memory" "768Mi" "ephemeral-storage" "2Gi")
  )
  "medium" (dict 
    "requests" (dict "cpu" "500m" "memory" "1024Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "750m" "memory" "1536Mi" "ephemeral-storage" "2Gi")
  )
  "large" (dict 
    "requests" (dict "cpu" "1000m" "memory" "2048Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "1500m" "memory" "3072Mi" "ephemeral-storage" "2Gi")
  )
  "xlarge" (dict 
    "requests" (dict "cpu" "2000m" "memory" "4096Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "3000m" "memory" "6144Mi" "ephemeral-storage" "2Gi")
  )
  "2xlarge" (dict 
    "requests" (dict "cpu" "4000m" "memory" "8192Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "6000m" "memory" "12288Mi" "ephemeral-storage" "2Gi")
  )
-}}

{{- if and $preset (ne $preset "none") -}}
  {{- if hasKey $presets $preset -}}
    {{- get $presets $preset | toYaml -}}
  {{- else -}}
    {{- $available := keys $presets | sortAlpha | join ", " -}}
    {{- printf "ERROR: Resource preset '%s' not found. Available presets: %s" $preset $available | fail -}}
  {{- end -}}
{{- else if $resources -}}
  {{- $resources | toYaml -}}
{{- end -}}
{{- end -}}
