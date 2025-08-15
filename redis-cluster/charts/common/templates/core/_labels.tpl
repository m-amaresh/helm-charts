{{/* vim: set filetype=mustache: */}}

{{/*
Kubernetes standard labels
Usage: {{ include "common.labels.standard" . }}
*/}}

{{- define "common.labels.standard" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if .Values.commonLabels }}
{{ include "common.tplvalues.render" (dict "value" .Values.commonLabels "context" .) }}
{{- end }}
{{- end }}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
Usage: {{ include "common.labels.matchLabels" . }}
*/}}

{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create labels with component
Usage: {{ include "common.labels.component" (dict "component" "master" "context" .) }}
*/}}

{{- define "common.labels.component" -}}
{{ include "common.labels.standard" .context }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{/*
Create match labels with component
Usage: {{ include "common.labels.matchLabels.component" (dict "component" "master" "context" .) }}
*/}}

{{- define "common.labels.matchLabels.component" -}}
{{ include "common.labels.matchLabels" .context }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{/*
Return platform-specific labels
Usage: {{ include "common.labels.platform" . }}
*/}}

{{- define "common.labels.platform" -}}
{{- if .Values.platform }}
{{- if .Values.platform.cloudProvider }}
platform.cloud-provider: {{ .Values.platform.cloudProvider | quote }}
{{- end }}
{{- if .Values.platform.region }}
platform.region: {{ .Values.platform.region | quote }}
{{- end }}
{{- if .Values.platform.zone }}
platform.zone: {{ .Values.platform.zone | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Return monitoring labels
Usage: {{ include "common.labels.monitoring" . }}
*/}}

{{- define "common.labels.monitoring" -}}
{{- if and .Values.commonMonitoring .Values.commonMonitoring.enabled }}
{{- if .Values.commonMonitoring.labels }}
{{ toYaml .Values.commonMonitoring.labels }}
{{- end }}
monitoring.scrape: "true"
{{- end }}
{{- end }}

{{/*
Comprehensive labels that include all contexts
Usage: {{ include "common.labels.comprehensive" (dict "component" "master" "monitoring" true "platform" true "context" .) }}
*/}}

{{- define "common.labels.comprehensive" -}}
{{ include "common.labels.component" (dict "component" .component "context" .context) }}
{{- if .monitoring }}
{{ include "common.labels.monitoring" .context }}
{{- end }}
{{- if .platform }}
{{ include "common.labels.platform" .context }}
{{- end }}
{{- end }}
