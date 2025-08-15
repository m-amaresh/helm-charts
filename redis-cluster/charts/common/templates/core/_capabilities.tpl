{{/* vim: set filetype=mustache: */}}

{{/*
Return the target Kubernetes version
*/}}

{{- define "common.capabilities.kubeVersion" -}}
{{- if .Values.global }}
    {{- if .Values.global.kubeVersion }}
    {{- .Values.global.kubeVersion -}}
    {{- else }}
    {{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
    {{- end -}}
{{- else -}}
{{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}

{{- define "common.capabilities.deployment.apiVersion" -}}
{{- if semverCompare "<1.14-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for daemonset.
*/}}

{{- define "common.capabilities.daemonset.apiVersion" -}}
{{- if semverCompare "<1.14-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for statefulset.
*/}}

{{- define "common.capabilities.statefulset.apiVersion" -}}
{{- if semverCompare "<1.14-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "apps/v1beta2" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}

{{- define "common.capabilities.networkPolicy.apiVersion" -}}
{{- if semverCompare "<1.7-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for poddisruptionbudget.
*/}}

{{- define "common.capabilities.policy.apiVersion" -}}
{{- if semverCompare "<1.21-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for horizontalpodautoscaler.
*/}}

{{- define "common.capabilities.hpa.apiVersion" -}}
{{- if semverCompare "<1.23-0" (include "common.capabilities.kubeVersion" .) -}}
{{- if semverCompare ">=1.12-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "autoscaling/v2beta1" -}}
{{- else -}}
{{- print "autoscaling/v1" -}}
{{- end -}}
{{- else -}}
{{- print "autoscaling/v2" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}

{{- define "common.capabilities.ingress.apiVersion" -}}
{{- if .Values.ingress -}}
{{- if .Values.ingress.apiVersion -}}
{{- .Values.ingress.apiVersion -}}
{{- else if semverCompare "<1.14-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "<1.19-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end }}
{{- else if semverCompare "<1.14-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "<1.19-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if the used Helm version is 3.3+.
A way to check the used Helm version is to check if certain capabilities are supported.
In Helm 3.3+, additional Lookup capabilities were introduced.
*/}}

{{- define "common.capabilities.supportsHelmVersion" -}}
{{- if .Capabilities.APIVersions.Has "v1/Secret" -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Check if the cluster supports certain features
*/}}

{{- define "common.capabilities.supportsFeature" -}}
{{- $feature := .feature -}}
{{- $version := include "common.capabilities.kubeVersion" .context -}}
{{- if eq $feature "podSecurityPolicy" -}}
  {{- if and (semverCompare ">=1.10-0" $version) (semverCompare "<1.25-0" $version) -}}
  true
  {{- end -}}
{{- else if eq $feature "podSecurityStandards" -}}
  {{- if semverCompare ">=1.23-0" $version -}}
  true
  {{- end -}}
{{- else if eq $feature "seccompProfile" -}}
  {{- if semverCompare ">=1.19-0" $version -}}
  true
  {{- end -}}
{{- else if eq $feature "topologySpreadConstraints" -}}
  {{- if semverCompare ">=1.19-0" $version -}}
  true
  {{- end -}}
{{- else if eq $feature "ephemeralStorageRequests" -}}
  {{- if semverCompare ">=1.8-0" $version -}}
  true
  {{- end -}}
{{- end -}}
{{- end -}}
