{{/* vim: set filetype=mustache: */}}

{{/*
Return a pod affinity/anti-affinity definition
Usage:
{{- include "common.affinities.pods" (dict "type" .Values.podAntiAffinityPreset "component" "master" "context" $) }}
Params:
  - type - String - Affinity preset type (soft/hard)
  - component - String - Component name for label matching  
  - context - Dict - Template context with Release, Chart, Values etc
*/}}

{{- define "common.affinities.pods" -}}
{{- $type := .type -}}
{{- $component := .component -}}
{{- $context := .context -}}
{{- if eq $type "soft" }}
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    podAffinityTerm:
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: {{ include "common.names.name" $context }}
          app.kubernetes.io/instance: {{ $context.Release.Name }}
          app.kubernetes.io/component: {{ $component }}
      topologyKey: kubernetes.io/hostname
{{- else if eq $type "hard" }}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels:
        app.kubernetes.io/name: {{ include "common.names.name" $context }}
        app.kubernetes.io/instance: {{ $context.Release.Name }}
        app.kubernetes.io/component: {{ $component }}
    topologyKey: kubernetes.io/hostname
{{- end -}}
{{- end -}}

{{/*
Return a node affinity definition
Usage:
{{- include "common.affinities.nodes" (dict "type" .Values.nodeAffinityPreset.type "key" .Values.nodeAffinityPreset.key "values" .Values.nodeAffinityPreset.values) }}
Params:
  - type - String - Affinity preset type (soft/hard)
  - key - String - Node label key to match
  - values - List - Node label values to match
*/}}

{{- define "common.affinities.nodes" -}}
{{- $type := .type -}}
{{- $key := .key -}}
{{- $values := .values -}}
{{- if eq $type "soft" }}
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    preference:
      matchExpressions:
        - key: {{ $key }}
          operator: In
          values:
          {{- range $values }}
            - {{ . | quote }}
          {{- end }}
{{- else if eq $type "hard" }}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ $key }}
          operator: In
          values:
          {{- range $values }}
            - {{ . | quote }}
          {{- end }}
{{- end -}}
{{- end -}}
