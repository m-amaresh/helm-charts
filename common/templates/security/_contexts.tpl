{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Security Context for pods
Usage: {{ include "common.security.podSecurityContext" (dict "securityContext" .Values.podSecurityContext "context" .) }}
*/}}

{{- define "common.security.podSecurityContext" -}}
{{- $securityContext := .securityContext -}}
{{- if $securityContext.enabled -}}
runAsNonRoot: {{ $securityContext.runAsNonRoot | default true }}
runAsUser: {{ $securityContext.runAsUser | default 1001 }}
runAsGroup: {{ $securityContext.runAsGroup | default 1001 }}
fsGroup: {{ $securityContext.fsGroup | default 1001 }}
fsGroupChangePolicy: {{ $securityContext.fsGroupChangePolicy | default "Always" | quote }}
{{- if $securityContext.seccompProfile }}
seccompProfile:
  type: {{ $securityContext.seccompProfile.type | default "RuntimeDefault" }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Security Context for containers
Usage: {{ include "common.security.containerSecurityContext" (dict "securityContext" .Values.containerSecurityContext "context" .) }}
*/}}

{{- define "common.security.containerSecurityContext" -}}
{{- $securityContext := .securityContext -}}
{{- if $securityContext.enabled -}}
runAsNonRoot: {{ $securityContext.runAsNonRoot | default true }}
runAsUser: {{ $securityContext.runAsUser | default 1001 }}
runAsGroup: {{ $securityContext.runAsGroup | default 1001 }}
allowPrivilegeEscalation: {{ $securityContext.allowPrivilegeEscalation | default false }}
readOnlyRootFilesystem: {{ $securityContext.readOnlyRootFilesystem | default true }}
{{- if $securityContext.capabilities }}
capabilities:
  drop: {{ $securityContext.capabilities.drop | default (list "ALL") | toYaml | nindent 2 }}
{{- end }}
{{- if $securityContext.seccompProfile }}
seccompProfile:
  type: {{ $securityContext.seccompProfile.type | default "RuntimeDefault" }}
{{- end }}
{{- end -}}
{{- end -}}
