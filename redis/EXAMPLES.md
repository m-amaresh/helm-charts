# Redis Helm Chart Examples

This document contains various examples of deploying Redis using this Helm chart.

## Table of Contents

- [Basic Standalone Redis](#basic-standalone-redis)
- [Redis with Authentication](#redis-with-authentication)
- [High Availability Replication](#high-availability-replication)
- [Redis with Custom Resources](#redis-with-custom-resources)
- [Security-Hardened Deployment](#security-hardened-deployment)
- [Network Policy Enforcement](#network-policy-enforcement)
- [Quick Installation Commands](#quick-installation-commands)

## Basic Standalone Redis

Deploy a basic standalone Redis instance:

```bash
helm install my-redis oci://ghcr.io/m-amaresh/helm-charts/redis
```

Or with custom values:

```yaml
# basic-standalone.yaml
architecture: standalone

redis:
  persistence:
    enabled: true
    size: 8Gi
  resourcesPreset: "small"

auth:
  enabled: false
```

```bash
helm install my-redis oci://ghcr.io/m-amaresh/helm-charts/redis -f basic-standalone.yaml
```

## Redis with Authentication

Deploy Redis with password authentication:

```yaml
# auth-redis.yaml
architecture: standalone
auth:
  enabled: true
  password: "mySecurePassword123"

redis:
  persistence:
    enabled: true
    size: 10Gi
  resourcesPreset: "small"
```

```bash
helm install my-redis oci://ghcr.io/m-amaresh/helm-charts/redis -f auth-redis.yaml
```

Or using existing secret:

```yaml
# auth-existing-secret.yaml
architecture: standalone
auth:
  enabled: true
  existingSecret: "my-redis-secret"
  existingSecretPasswordKey: "password"

redis:
  persistence:
    enabled: true
    size: 10Gi
```

First create the secret:
```bash
kubectl create secret generic my-redis-secret --from-literal=password=mySecurePassword123
```

Then deploy:
```bash
helm install my-redis oci://ghcr.io/m-amaresh/helm-charts/redis -f auth-existing-secret.yaml
```

## High Availability Replication

Deploy Redis with master-replica architecture:

```yaml
# replication-redis.yaml
architecture: replication
auth:
  enabled: true
  existingSecret: "redis-production-secret"
  existingSecretPasswordKey: "password"

master:
  persistence:
    enabled: true
    size: 50Gi
    storageClass: "premium-ssd"
  resourcesPreset: "large"
  podAntiAffinityPreset: "hard"
  nodeAffinityPreset:
    type: "hard"
    key: "node-type"
    values: ["redis-optimized"]

replica:
  count: 3
  persistence:
    enabled: true
    size: 50Gi
    storageClass: "premium-ssd"
  resourcesPreset: "medium"
  podAntiAffinityPreset: "hard"
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: DoNotSchedule
```

```bash
helm install my-redis-replication oci://ghcr.io/m-amaresh/helm-charts/redis -f replication-redis.yaml
```

## Redis with Custom Resources

Deploy with specific CPU and memory limits:

```yaml
# custom-resources.yaml
architecture: standalone

redis:
  resourcesPreset: "none"  # Override preset
  resources:
    limits:
      memory: "2Gi"
      cpu: "1000m"
    requests:
      memory: "1Gi"
      cpu: "500m"
  persistence:
    enabled: true
    size: 16Gi
    storageClass: "ssd"
  containerPorts:
    redis: 6380
  service:
    ports:
      redis: 6380

auth:
  enabled: true
  password: "customResourcePassword"
```

```bash
helm install my-custom-redis oci://ghcr.io/m-amaresh/helm-charts/redis -f custom-resources.yaml
```

## Security-Hardened Deployment

Deploy with maximum security configuration:

```yaml
# security-hardened.yaml
architecture: replication
auth:
  enabled: true
  existingSecret: "redis-secure-secret"

# Enhanced Redis configuration for security
configuration: |-
  # Memory Management with limits
  maxmemory 4gb
  maxmemory-policy allkeys-lru
  
  # Secure persistence
  appendonly yes
  appendfsync everysec
  save ""  # Disable RDB
  
  # Performance with security
  lazyfree-lazy-eviction yes
  tcp-keepalive 300
  timeout 300
  
  # Security hardening
  rename-command FLUSHDB ""
  rename-command FLUSHALL ""
  rename-command EVAL ""
  rename-command DEBUG ""
  rename-command CONFIG ""
  rename-command SHUTDOWN SHUTDOWN_SECURE_KEY_2024
  
  # Logging for security monitoring
  loglevel notice

# Security contexts
redis:
  podSecurityContext:
    enabled: true
    fsGroup: 1001
    runAsUser: 1001
    runAsGroup: 1001
    runAsNonRoot: true
  containerSecurityContext:
    enabled: true
    runAsUser: 1001
    runAsGroup: 1001
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"

master:
  resourcesPreset: "medium"
  persistence:
    enabled: true
    size: 20Gi

replica:
  count: 2
  resourcesPreset: "small"
  persistence:
    enabled: true
    size: 20Gi
```

```bash
helm install my-redis-secure oci://ghcr.io/m-amaresh/helm-charts/redis -f security-hardened.yaml
```

## Network Policy Enforcement

Deploy with network policies for enhanced security:

```yaml
# network-policy.yaml
architecture: replication
auth:
  enabled: true
  password: "networkSecurePassword"

networkPolicy:
  policies:
    # Strict ingress control
    - name: redis-ingress-whitelist
      podSelector:
        matchLabels:
          app.kubernetes.io/name: redis
      policyTypes:
        - Ingress
      ingress:
        # Allow from application namespace
        - from:
            - namespaceSelector:
                matchLabels:
                  name: web-applications
            - podSelector:
                matchLabels:
                  app.type: "redis-client"
          ports:
            - protocol: TCP
              port: 6379
        
        # Allow monitoring systems
        - from:
            - namespaceSelector:
                matchLabels:
                  name: monitoring
            - podSelector:
                matchLabels:
                  app: "prometheus"
          ports:
            - protocol: TCP
              port: 6379

    # Controlled egress
    - name: redis-egress-control
      podSelector:
        matchLabels:
          app.kubernetes.io/name: redis
      policyTypes:
        - Egress
      egress:
        # DNS resolution
        - to:
            - namespaceSelector:
                matchLabels:
                  name: kube-system
            - podSelector:
                matchLabels:
                  k8s-app: kube-dns
          ports:
            - protocol: UDP
              port: 53
            - protocol: TCP
              port: 53
        
        # Inter-redis communication
        - to:
            - podSelector:
                matchLabels:
                  app.kubernetes.io/name: redis
          ports:
            - protocol: TCP
              port: 6379

redis:
  resourcesPreset: "small"
  persistence:
    enabled: true
    size: 10Gi

master:
  resourcesPreset: "small"

replica:
  count: 2
  resourcesPreset: "nano"
```

```bash
helm install my-redis-secure oci://ghcr.io/m-amaresh/helm-charts/redis -f network-policy.yaml
```

## Quick Installation Commands

### Development Environment
```bash
# Basic standalone Redis
helm install my-redis oci://ghcr.io/m-amaresh/helm-charts/redis

# With authentication
helm install my-redis oci://ghcr.io/m-amaresh/helm-charts/redis \
  --set auth.enabled=true \
  --set auth.password="mypassword"
```

### Production Environment
```bash
# Replication with authentication and persistence
helm install my-redis-prod oci://ghcr.io/m-amaresh/helm-charts/redis \
  --set architecture=replication \
  --set auth.enabled=true \
  --set auth.password="$(openssl rand -base64 32)" \
  --set replica.count=3 \
  --set master.persistence.size=50Gi \
  --set replica.persistence.size=50Gi
```

### Security-Focused Deployment
```bash
# Maximum security configuration
helm install my-redis-secure oci://ghcr.io/m-amaresh/helm-charts/redis \
  --set architecture=replication \
  --set auth.enabled=true \
  --set auth.existingSecret=redis-secure-secret \
  --set redis.podSecurityContext.enabled=true \
  --set redis.containerSecurityContext.readOnlyRootFilesystem=true
```

## Testing Your Deployment

After deployment, you can test your Redis instance:

```bash
# Get the password (if auth is enabled)
export REDIS_PASSWORD=$(kubectl get secret --namespace default my-redis -o jsonpath="{.data.redis-password}" | base64 -d)

# Run a test pod
kubectl run --namespace default redis-client --restart='Never' --env REDIS_PASSWORD=$REDIS_PASSWORD --image docker.io/redis:8.2.0-alpine --command -- sleep infinity

# Connect to Redis (standalone)
kubectl exec --namespace default -it redis-client -- redis-cli -h my-redis -a $REDIS_PASSWORD

# Connect to Redis (replication - master)
kubectl exec --namespace default -it redis-client -- redis-cli -h my-redis-master -a $REDIS_PASSWORD

# Test basic operations
> PING
> SET key1 "Hello"
> GET key1
> INFO replication
```

## Cleanup

To remove the deployment:

```bash
helm uninstall my-redis
```
