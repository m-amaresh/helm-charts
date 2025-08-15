{{/* vim: set filetype=mustache: */}}

{{/*
Redis-specific helper functions using common library
*/}}

{{/*
Validate Redis authentication configuration with auto-generation
*/}}
{{- define "redis.validateAuth" -}}
{{- if and .Values.auth.enabled .Values.auth.existingSecret (not .Values.auth.existingSecretPasswordKey) -}}
{{- fail "ERROR: When using auth.existingSecret, you must provide auth.existingSecretPasswordKey" -}}
{{- end -}}
{{- end -}}

{{/*
Return Redis authentication arguments for redis-cli
*/}}
{{- define "redis.authArguments" -}}
{{- if .Values.auth.enabled -}}
-a $(REDIS_PASSWORD)
{{- end -}}
{{- end -}}


{{/*
Return the Redis secret name
*/}}
{{- define "redis.secretName" -}}
{{- if .Values.auth.existingSecret -}}
    {{ .Values.auth.existingSecret }}
{{- else -}}
    {{ include "common.names.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret password key
*/}}
{{- define "redis.secretPasswordKey" -}}
{{- if .Values.auth.existingSecret -}}
    {{ .Values.auth.existingSecretPasswordKey }}
{{- else -}}
    redis-password
{{- end -}}
{{- end -}}

{{/*
Validate Redis architecture
*/}}
{{- define "redis.validateValues.architecture" -}}
{{- if and (ne .Values.architecture "standalone") (ne .Values.architecture "replication") -}}
    redis: .Values.architecture
        Invalid architecture selected. Valid values are "standalone" and
        "replication". Please set a valid architecture (--set architecture="xxxx")
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "redis.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "redis.validateValues.architecture" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Generate Redis health probes (liveness, readiness, startup)
*/}}
{{- define "redis.healthProbes" -}}
{{- $port := .port | default 6379 -}}
{{- $component := .component | default "redis" -}}
{{- $probeSettings := .probeSettings -}}
livenessProbe:
  enabled: {{ $probeSettings.livenessProbe.enabled }}
  {{- if $probeSettings.livenessProbe.enabled }}
  initialDelaySeconds: {{ $probeSettings.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ $probeSettings.livenessProbe.periodSeconds }}
  timeoutSeconds: {{ $probeSettings.livenessProbe.timeoutSeconds }}
  successThreshold: {{ $probeSettings.livenessProbe.successThreshold }}
  failureThreshold: {{ $probeSettings.livenessProbe.failureThreshold }}
  exec:
    command:
      - sh
      - -c
      - /health/ping_liveness_local.sh {{ $port }}
  {{- end }}
readinessProbe:
  enabled: {{ $probeSettings.readinessProbe.enabled }}
  {{- if $probeSettings.readinessProbe.enabled }}
  initialDelaySeconds: {{ $probeSettings.readinessProbe.initialDelaySeconds }}
  periodSeconds: {{ $probeSettings.readinessProbe.periodSeconds }}
  timeoutSeconds: {{ $probeSettings.readinessProbe.timeoutSeconds }}
  successThreshold: {{ $probeSettings.readinessProbe.successThreshold }}
  failureThreshold: {{ $probeSettings.readinessProbe.failureThreshold }}
  exec:
    command:
      - sh
      - -c
      - /health/ping_readiness_local.sh {{ $port }}
  {{- end }}
startupProbe:
  enabled: {{ $probeSettings.startupProbe.enabled }}
  {{- if $probeSettings.startupProbe.enabled }}
  initialDelaySeconds: {{ $probeSettings.startupProbe.initialDelaySeconds }}
  periodSeconds: {{ $probeSettings.startupProbe.periodSeconds }}
  timeoutSeconds: {{ $probeSettings.startupProbe.timeoutSeconds }}
  successThreshold: {{ $probeSettings.startupProbe.successThreshold }}
  failureThreshold: {{ $probeSettings.startupProbe.failureThreshold }}
  exec:
    command:
      - sh
      - -c
      - /health/ping_liveness_local.sh {{ $port }}
  {{- end }}
{{- end -}}

{{/*
Generate Redis service ports
*/}}
{{- define "redis.servicePorts" -}}
{{- $port := .port | default 6379 -}}
- name: redis
  port: {{ $port }}
  protocol: TCP
  targetPort: redis
{{- end -}}

{{/*
Generate Redis environment variables
*/}}
{{- define "redis.environmentVariables" -}}
{{- $role := .role | default "master" -}}
{{- $root := .root -}}
- name: REDIS_REPLICATION_MODE
  value: {{ $role }}
{{- if $root.Values.auth.enabled }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "redis.secretName" $root }}
      key: {{ include "redis.secretPasswordKey" $root }}
{{- end }}
- name: REDIS_PORT
  value: {{ .port | default 6379 | quote }}
{{- end -}}

{{/*
Generate Redis volume mounts
*/}}
{{- define "redis.volumeMounts" -}}
- name: redis-data
  mountPath: /data
- name: redis-config
  mountPath: /opt/bitnami/redis/mounted-etc
- name: redis-tmp-conf
  mountPath: /opt/bitnami/redis/etc/
{{- end -}}

{{/*
Generate Redis volumes
*/}}
{{- define "redis.volumes" -}}
- name: redis-config
  configMap:
    name: {{ include "common.names.fullname" . }}
- name: redis-tmp-conf
  emptyDir: {}
{{- end -}}

{{/*
Return the Redis service account name
*/}}
{{- define "redis.serviceAccountName" -}}
{{- if .Values.redis.serviceAccount.create -}}
{{- default (include "common.names.fullname" .) .Values.redis.serviceAccount.name -}}
{{- else -}}
default
{{- end -}}
{{- end -}}

{{/*
Return the Redis name (for backward compatibility)
*/}}
{{- define "redis.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}
