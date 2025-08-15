{{/* vim: set filetype=mustache: */}}

{{/*
Renders a value that contains template.
Usage:
{{ include "common.tplvalues.render" (dict "value" .Values.path.to.the.Value "context" $) }}
*/}}

{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Merge two dictionaries recursively
Usage:
{{ include "common.utils.merge" (dict "base" .Values.base "override" .Values.override "context" .) }}
*/}}

{{- define "common.utils.merge" -}}
{{- $base := .base -}}
{{- $override := .override -}}
{{- range $key, $value := $override -}}
  {{- if hasKey $base $key -}}
    {{- if and (kindIs "map" $value) (kindIs "map" (index $base $key)) -}}
      {{- $_ := set $base $key (include "common.utils.merge" (dict "base" (index $base $key) "override" $value "context" $.context) | fromYaml) -}}
    {{- else -}}
      {{- $_ := set $base $key $value -}}
    {{- end -}}
  {{- else -}}
    {{- $_ := set $base $key $value -}}
  {{- end -}}
{{- end -}}
{{- $base | toYaml -}}
{{- end -}}

{{/*
Convert a string to a valid Kubernetes resource name
Usage: {{ include "common.utils.toResourceName" "My Invalid Name!" }}
*/}}

{{- define "common.utils.toResourceName" -}}
{{- . | lower | replace " " "-" | replace "_" "-" | replace "." "-" | regexReplaceAll "[^a-z0-9-]" "" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate a random string
Usage: {{ include "common.utils.randomString" 10 }}
*/}}

{{- define "common.utils.randomString" -}}
{{- $length := . | int -}}
{{- $chars := "abcdefghijklmnopqrstuvwxyz0123456789" -}}
{{- $result := "" -}}
{{- range $i := until $length -}}
  {{- $result = printf "%s%s" $result (index (splitList "" $chars) (randInt 0 (len $chars))) -}}
{{- end -}}
{{- $result -}}
{{- end -}}

{{/*
Check if a value is empty or nil
Usage: {{ if include "common.utils.isEmpty" .Values.someValue }}empty{{ end }}
*/}}

{{- define "common.utils.isEmpty" -}}
{{- if or (not .) (eq . "") (eq . "null") (eq . "nil") (eq . "<nil>") -}}
true
{{- end -}}
{{- end -}}

{{/*
Get a nested value from a dictionary safely
Usage: {{ include "common.utils.get" (dict "path" "a.b.c" "data" .Values "default" "defaultValue") }}
*/}}

{{- define "common.utils.get" -}}
{{- $keys := splitList "." .path -}}
{{- $current := .data -}}
{{- range $key := $keys -}}
  {{- if hasKey $current $key -}}
    {{- $current = index $current $key -}}
  {{- else -}}
    {{- $current = $.default -}}
    {{- break -}}
  {{- end -}}
{{- end -}}
{{- $current -}}
{{- end -}}
