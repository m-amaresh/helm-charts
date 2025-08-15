# Redis Cluster Helm Chart Examples

This document contains various examples of deploying Redis Cluster using this Helm chart.

## Table of Contents

- [Basic Redis Cluster](#basic-redis-cluster)
- [Redis Cluster with Authentication](#redis-cluster-with-authentication)
- [Large Redis Cluster](#large-redis-cluster)
- [Redis Cluster with Custom Resources](#redis-cluster-with-custom-resources)
- [Redis Cluster with Persistence](#redis-cluster-with-persistence)
- [Redis Cluster with Anti-Affinity](#redis-cluster-with-anti-affinity)
- [Security-Hardened Deployment](#security-hardened-deployment)
- [Network Policy Enforcement](#network-policy-enforcement)
- [Quick Installation Commands](#quick-installation-commands)

## Basic Redis Cluster

Deploy a basic 6-node Redis cluster (3 masters + 3 replicas):

```bash
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster
```

Or with custom values:

```yaml
# basic-cluster.yaml
cluster:
  nodes: 6
  replicas: 1

redis:
  persistence:
    enabled: true
    size: 8Gi
  resourcesPreset: "nano"

auth:
  enabled: false
```

```bash
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster -f basic-cluster.yaml
```

## Redis Cluster with Authentication

Deploy Redis cluster with password authentication:

```yaml
# auth-cluster.yaml
auth:
  enabled: true
  password: "mySecurePassword123"

cluster:
  nodes: 6
  replicas: 1

redis:
  persistence:
    enabled: true
    size: 10Gi
  resourcesPreset: "nano"
```

```bash
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster -f auth-cluster.yaml
```

Or using existing secret:

```yaml
# auth-existing-secret.yaml
auth:
  enabled: true
  existingSecret: "my-redis-secret"
  existingSecretPasswordKey: "password"

cluster:
  nodes: 6
  replicas: 1

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
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster -f auth-existing-secret.yaml
```

## Large Redis Cluster

Deploy a larger Redis cluster with 9 nodes (3 masters + 6 replicas):

```yaml
# large-cluster.yaml
cluster:
  nodes: 9
  replicas: 2

redis:
  resourcesPreset: "large"
  persistence:
    enabled: true
    size: 32Gi
    storageClass: "fast-ssd"

auth:
  enabled: true
  password: "productionPassword"
```

```bash
helm install my-large-redis oci://ghcr.io/m-amaresh/helm-charts/redis-cluster -f large-cluster.yaml
```

## Redis Cluster with Custom Resources

Deploy with specific CPU and memory limits:

```yaml
# custom-resources.yaml
cluster:
  nodes: 6
  replicas: 1

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

auth:
  enabled: true
  password: "customResourcePassword"
```

```bash
helm install my-custom-redis oci://ghcr.io/m-amaresh/helm-charts/redis-cluster -f custom-resources.yaml
```

## Redis Cluster with Persistence

Deploy with custom persistence settings:

```yaml
# persistence-cluster.yaml
cluster:
  nodes: 6
  replicas: 1

redis:
  persistence:
    enabled: true
    storageClass: "premium-ssd"
    size: 50Gi
    accessModes:
      - ReadWriteOnce
    annotations:
      volume.beta.kubernetes.io/storage-class: "premium-ssd"
  resourcesPreset: "medium"

auth:
  enabled: true
  password: "persistentPassword"
```

```bash
helm install my-persistent-redis oci://ghcr.io/m-amaresh/helm-charts/redis-cluster -f persistence-cluster.yaml
```

## Redis Cluster with Anti-Affinity

Deploy with strict anti-affinity to ensure nodes are on different physical nodes:

```yaml
# anti-affinity-cluster.yaml
cluster:
  nodes: 6
  replicas: 1

redis:
  podAntiAffinityPreset: "hard"  # Force pods on different nodes
  resourcesPreset: "small"
  
  # Or use custom affinity
  # affinity:
  #   podAntiAffinity:
  #     requiredDuringSchedulingIgnoredDuringExecution:
  #       - labelSelector:
  #           matchLabels:
  #             app.kubernetes.io/name: redis-cluster
  #             app.kubernetes.io/instance: my-ha-redis
  #         topologyKey: kubernetes.io/hostname

  persistence:
    enabled: true
    size: 20Gi

  # Node selection
  nodeSelector:
    redis-node: "true"
  
  tolerations:
    - key: "redis-dedicated"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

auth:
  enabled: true
  password: "highAvailabilityPassword"
```

```bash
helm install my-ha-redis oci://ghcr.io/m-amaresh/helm-charts/redis-cluster -f anti-affinity-cluster.yaml
```

## Security-Hardened Deployment

Deploy with maximum security configuration:

```yaml
# security-hardened.yaml
cluster:
  nodes: 6
  replicas: 1

auth:
  enabled: true
  existingSecret: "redis-secure-secret"

# Enhanced Redis configuration for security
configuration: |-
  # Cluster configuration
  cluster-enabled yes
  cluster-config-file nodes.conf
  cluster-node-timeout 10000
  cluster-announce-port 6379
  cluster-announce-bus-port 16379
  
  # Memory policies
  maxmemory-policy allkeys-lru
  maxmemory 2gb
  
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
  resourcesPreset: "medium"
  persistence:
    enabled: true
    size: 20Gi
```

```bash
helm install my-redis-secure oci://ghcr.io/m-amaresh/helm-charts/redis-cluster -f security-hardened.yaml
```

## Network Policy Enforcement

Deploy with network policies for enhanced security:

```yaml
# network-policy.yaml
cluster:
  nodes: 6
  replicas: 1

networkPolicy:
  policies:
    - name: "redis-cluster-ingress"
      spec:
        podSelector:
          matchLabels:
            app.kubernetes.io/name: redis-cluster
        policyTypes:
          - Ingress
        ingress:
          - from:
              - namespaceSelector:
                  matchLabels:
                    name: "app-namespace"
            ports:
              - protocol: TCP
                port: 6379
              - protocol: TCP
                port: 16379  # Cluster bus port
    
    - name: "redis-cluster-egress"
      spec:
        podSelector:
          matchLabels:
            app.kubernetes.io/name: redis-cluster
        policyTypes:
          - Egress
        egress:
          # DNS resolution
          - to:
              - namespaceSelector:
                  matchLabels:
                    name: kube-system
            ports:
              - protocol: UDP
                port: 53
              - protocol: TCP
                port: 53
          
          # Inter-cluster communication
          - to:
              - podSelector:
                  matchLabels:
                    app.kubernetes.io/name: redis-cluster
            ports:
              - protocol: TCP
                port: 6379
              - protocol: TCP
                port: 16379

redis:
  resourcesPreset: "small"
  persistence:
    enabled: true
    size: 10Gi

auth:
  enabled: true
  password: "networkSecurePassword"
```

```bash
helm install my-secure-redis oci://ghcr.io/m-amaresh/helm-charts/redis-cluster -f network-policy.yaml
```

## Quick Installation Commands

### Development Environment
```bash
# Basic Redis cluster
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster

# With authentication
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster \
  --set auth.enabled=true \
  --set auth.password="mypassword"
```

### Production Environment
```bash
# Large cluster with authentication and persistence
helm install my-redis-prod oci://ghcr.io/m-amaresh/helm-charts/redis-cluster \
  --set cluster.nodes=9 \
  --set cluster.replicas=2 \
  --set auth.enabled=true \
  --set auth.password="$(openssl rand -base64 32)" \
  --set redis.persistence.size=50Gi \
  --set redis.resourcesPreset=large
```

### Security-Focused Deployment
```bash
# Maximum security configuration
helm install my-redis-secure oci://ghcr.io/m-amaresh/helm-charts/redis-cluster \
  --set auth.enabled=true \
  --set auth.existingSecret=redis-secure-secret \
  --set redis.podSecurityContext.enabled=true \
  --set redis.containerSecurityContext.readOnlyRootFilesystem=true \
  --set redis.podAntiAffinityPreset=hard
```

## Testing Your Deployment

After deployment, you can test your Redis cluster:

```bash
# Get the password (if auth is enabled)
export REDIS_PASSWORD=$(kubectl get secret --namespace default my-redis-cluster -o jsonpath="{.data.redis-password}" | base64 -d)

# Run a test pod
kubectl run --namespace default redis-client --restart='Never' --env REDIS_PASSWORD=$REDIS_PASSWORD --image docker.io/redis:8.2.0-alpine --command -- sleep infinity

# Connect to the cluster (using headless service for proper cluster discovery)
kubectl exec --namespace default -it redis-client -- redis-cli -c -h my-redis-cluster-0.my-redis-cluster-headless -a $REDIS_PASSWORD

# Test cluster operations
> CLUSTER INFO
> SET key1 "Hello"
> GET key1
> CLUSTER NODES
> CLUSTER SLOTS

# Test cross-slot operations
> SET user:1001 "Alice"
> SET user:1002 "Bob"
> GET user:1001
> GET user:1002
```

## Monitoring Cluster Health

```bash
# Check cluster status
kubectl exec --namespace default my-redis-cluster-0 -- redis-cli cluster info

# Check all nodes
kubectl exec --namespace default my-redis-cluster-0 -- redis-cli cluster nodes

# Monitor cluster initialization
kubectl logs job/my-redis-cluster-init

# Check pod status
kubectl get pods -l app.kubernetes.io/name=redis-cluster
```

## Cleanup

To remove the deployment:

```bash
helm uninstall my-redis-cluster
```
