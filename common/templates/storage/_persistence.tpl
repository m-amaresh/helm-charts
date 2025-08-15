{{/* vim: set filetype=mustache: */}}

{{/*
Return a PVC spec for StatefulSet volumeClaimTemplates
Usage: 
{{ include "common.storage.pvc" (dict 
    "name" "data"
    "persistence" .Values.persistence 
    "context" .) }}
*/}}

{{- define "common.storage.pvc" -}}
{{- $persistence := .persistence -}}
{{- $storageClass := $persistence.storageClass -}}
{{- if .context.Values.global -}}
  {{- if .context.Values.global.storageClass -}}
    {{- $storageClass = .context.Values.global.storageClass -}}
  {{- end -}}
{{- end -}}
{{- if eq "-" $storageClass -}}
  {{- $storageClass = "" -}}
{{- end }}
metadata:
  name: {{ .name }}
  {{- if $persistence.annotations }}
  annotations:
    {{- include "common.tplvalues.render" (dict "value" $persistence.annotations "context" .context) | nindent 4 }}
  {{- end }}
spec:
  accessModes:
  {{- range $persistence.accessModes }}
    - {{ . | quote }}
  {{- end }}
  {{- if $storageClass }}
  storageClassName: {{ $storageClass | quote }}
  {{- end }}
  resources:
    requests:
      storage: {{ $persistence.size | quote }}
  {{- if $persistence.selector }}
  selector:
    {{- include "common.tplvalues.render" (dict "value" $persistence.selector "context" .context) | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Return a volume definition for persistence
Usage:
{{ include "common.storage.volume" (dict 
    "name" "data" 
    "persistence" .Values.persistence 
    "context" .) }}
*/}}

{{- define "common.storage.volume" -}}
{{- $persistence := .persistence -}}
- name: {{ .name }}
{{- if $persistence.enabled }}
  {{- if $persistence.existingClaim }}
  persistentVolumeClaim:
    claimName: {{ include "common.tplvalues.render" (dict "value" $persistence.existingClaim "context" .context) }}
  {{- else }}
  persistentVolumeClaim:
    claimName: {{ include "common.names.fullname" .context }}-{{ .name }}
  {{- end }}
{{- else }}
  emptyDir:
    {{- if $persistence.medium }}
    medium: {{ $persistence.medium | quote }}
    {{- end }}
    {{- if $persistence.sizeLimit }}
    sizeLimit: {{ $persistence.sizeLimit | quote }}
    {{- end }}
{{- end }}
{{- end }}
