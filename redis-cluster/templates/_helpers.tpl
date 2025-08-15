{{/* vim: set filetype=mustache: */}}

{{/*
Redis Cluster Helm Chart Helper Functions
*/}}

{{/*
Return the Redis service account name - using redis chart pattern
*/}}

{{- define "redis-cluster.serviceAccountName" -}}
{{- if .Values.redis.serviceAccount.create -}}
{{- default (include "common.names.fullname" .) .Values.redis.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.redis.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Get the password secret name
*/}}

{{- define "redis-cluster.secretName" -}}
{{- if .Values.auth.existingSecret -}}
{{- .Values.auth.existingSecret -}}
{{- else -}}
{{- include "common.names.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Get the password secret key
*/}}

{{- define "redis-cluster.secretPasswordKey" -}}
{{- if and .Values.auth.existingSecret .Values.auth.existingSecretPasswordKey -}}
{{- .Values.auth.existingSecretPasswordKey -}}
{{- else -}}
redis-password
{{- end -}}
{{- end -}}

{{/*
Validate Redis authentication configuration - using redis chart pattern with auto-generation
*/}}

{{- define "redis-cluster.validateAuth" -}}
{{- if and .Values.auth.enabled .Values.auth.existingSecret (not .Values.auth.existingSecretPasswordKey) -}}
{{- fail "ERROR: When using auth.existingSecret, you must provide auth.existingSecretPasswordKey" -}}
{{- end -}}
{{- end -}}

{{/*
Validate Redis cluster configuration
*/}}

{{- define "redis-cluster.validateCluster" -}}
{{- if lt (.Values.cluster.nodes | int) 6 -}}
{{- fail "ERROR: Redis cluster requires minimum 6 nodes (3 masters + 3 replicas)" -}}
{{- end -}}
{{- if ne (mod (.Values.cluster.nodes | int) 2) 0 -}}
{{- fail "ERROR: Redis cluster nodes must be an even number for proper master/replica distribution" -}}
{{- end -}}
{{- $masters := div (.Values.cluster.nodes | int) 2 -}}
{{- $expectedReplicas := mul $masters (.Values.cluster.replicas | int) -}}
{{- if ne (.Values.cluster.nodes | int) (add $masters $expectedReplicas) -}}
{{- fail (printf "ERROR: Invalid cluster configuration. With %d masters and %d replicas per master, expected %d total nodes but got %d" $masters (.Values.cluster.replicas | int) (add $masters $expectedReplicas) (.Values.cluster.nodes | int)) -}}
{{- end -}}
{{- if lt (.Values.cluster.replicas | int) 1 -}}
{{- fail "ERROR: Redis cluster requires at least 1 replica per master" -}}
{{- end -}}
{{- end -}}

{{/*
Get the ConfigMap name for Redis configuration
*/}}

{{- define "redis-cluster.configMapName" -}}
{{- if .Values.existingConfigmap -}}
{{- .Values.existingConfigmap -}}
{{- else -}}
{{- include "common.names.fullname" . -}}-configuration
{{- end -}}
{{- end -}}

{{/*
Generate Redis cluster node list for initialization
*/}}

{{- define "redis-cluster.nodeList" -}}
{{- $fullname := include "common.names.fullname" . -}}
{{- $namespace := include "common.names.namespace" . -}}
{{- $nodeCount := int .Values.cluster.nodes -}}
{{- $nodeList := list -}}
{{- range $i := until $nodeCount }}
{{- $nodeList = append $nodeList (printf "%s-%d.%s-headless.%s.svc.%s:6379" $fullname $i $fullname $namespace $.Values.clusterDomain) }}
{{- end }}
{{- join " " $nodeList -}}
{{- end -}}
