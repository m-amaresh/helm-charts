# Redis Cluster Helm Chart

A production-ready Redis Cluster Helm chart for Kubernetes providing high availability and automatic sharding capabilities.

## Features

- Redis cluster with configurable number of nodes (minimum 6)
- Automatic cluster initialization via Job
- Security-hardened configuration
- Persistent storage with PVC support
- Configurable health probes
- Resource presets and custom resource management
- Network policies support
- Pod Security Standards compliance
- Anti-affinity rules for high availability

## Prerequisites

- Kubernetes 1.29+
- Helm 3.2.0+
- PV Provisioner (for persistence)

## Installation

### Quick Start

```bash
# Basic Redis cluster (6 nodes)
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster

# Redis cluster with authentication
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster \
  --set auth.enabled=true \
  --set auth.password="$(openssl rand -base64 32)"

# Large Redis cluster (9 nodes)
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster \
  --set cluster.nodes=9 \
  --set cluster.replicas=2
```

See [EXAMPLES.md](EXAMPLES.md) for detailed configuration examples.

## Configuration

Key configuration parameters are defined in `values.yaml`. For detailed parameter documentation, see the values file.

### Cluster Configuration

- `cluster.nodes: 6` - Total number of cluster nodes (minimum 6, must be even)
- `cluster.replicas: 1` - Number of replicas per master
- `cluster.init.enabled: true` - Automatic cluster initialization

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cluster.nodes` | Total number of Redis cluster nodes (must be >= 6) | `6` |
| `cluster.replicas` | Number of replicas per master | `1` |
| `auth.enabled` | Enable password authentication | `false` |
| `auth.password` | Redis password | `""` |
| `redis.persistence.enabled` | Enable persistent storage | `true` |
| `redis.persistence.size` | Storage size | `8Gi` |
| `redis.resourcesPreset` | Resource preset (nano/micro/small/medium/large/xlarge/2xlarge) | `nano` |
| `redis.service.type` | Redis service type | `ClusterIP` |
| `networkPolicy.policies` | Network policies | `[]` |

## Security

The chart implements comprehensive security features:

- **Authentication**: Password-based authentication with secure secret management
- **Pod Security Standards**: Compliant with restricted profile (non-root, read-only filesystem, dropped capabilities)  
- **Network Policies**: Configurable network-level access control
- **RBAC**: Minimal service account with least-privilege principle
- **Hardened Configuration**: Dangerous Redis commands disabled by default
- **Cluster Validation**: Pre-deployment validation of cluster configuration

### Basic Security Setup

```bash
# Enable authentication
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster --set auth.enabled=true --set auth.password="$(openssl rand -base64 32)"

# Create external secret
kubectl create secret generic redis-cluster-auth --from-literal=password="$(openssl rand -base64 32)"
helm install my-redis-cluster oci://ghcr.io/m-amaresh/helm-charts/redis-cluster --set auth.enabled=true --set auth.existingSecret=redis-cluster-auth
```

## Cluster Management

### Monitoring Cluster Health

```bash
# Check cluster status
kubectl exec my-redis-cluster-0 -- redis-cli cluster info

# View cluster nodes
kubectl exec my-redis-cluster-0 -- redis-cli cluster nodes

# Monitor initialization job
kubectl logs job/my-redis-cluster-init
```

### Connecting to the Cluster

```bash
# From within Kubernetes (recommended)
kubectl exec -it my-redis-cluster-0 -- redis-cli -c

# Using headless service for cluster discovery
redis-cli -c -h my-redis-cluster-0.my-redis-cluster-headless.default.svc.cluster.local -p 6379
```

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
helm uninstall my-redis-cluster
```

## Additional Documentation

- **[EXAMPLES.md](EXAMPLES.md)** - Detailed configuration examples for various deployment scenarios

## License

This chart is licensed under the Apache License 2.0.

## Legal Notice

This chart is not affiliated with or endorsed by Redis Ltd. Redis is a trademark of Redis Ltd.
