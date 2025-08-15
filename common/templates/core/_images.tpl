{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper image name
Usage:
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
*/}}

{{- define "common.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $separator := ":" -}}
{{- $termination := .imageRoot.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
        {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if .imageRoot.digest }}
    {{- $separator = "@" -}}
    {{- $termination = .imageRoot.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image pull secrets
Usage:
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.metrics.image) "global" .Values.global) }}
*/}}

{{- define "common.images.pullSecrets" -}}
{{- $pullSecrets := list -}}

{{- if .global -}}
    {{- range .global.imagePullSecrets -}}
        {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
{{- end -}}

{{- range .images -}}
    {{- if .pullSecrets -}}
        {{- range .pullSecrets -}}
            {{- $pullSecrets = append $pullSecrets . -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
{{- range $pullSecrets | uniq }}
  - name: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}
