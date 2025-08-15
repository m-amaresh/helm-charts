{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}

{{- define "common.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "common.names.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}

{{- define "common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Allow the release namespace to be overridden
*/}}

{{- define "common.names.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}

{{- define "common.names.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate a short name with component suffix
Usage: {{ include "common.names.component" (dict "name" "redis" "component" "master" "context" .) }}
*/}}

{{- define "common.names.component" -}}
{{- if .component -}}
{{- printf "%s-%s" .name .component | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Generate resource names with validation
Usage: {{ include "common.names.resource" (dict "name" "myapp" "type" "service" "component" "master" "context" .) }}
*/}}

{{- define "common.names.resource" -}}
{{- $baseName := include "common.names.fullname" .context -}}
{{- $componentName := include "common.names.component" (dict "name" $baseName "component" .component) -}}
{{- if .suffix -}}
{{- printf "%s-%s" $componentName .suffix | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $componentName -}}
{{- end -}}
{{- end -}}
