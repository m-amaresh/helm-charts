# Redis Helm Chart

A production-ready Redis Helm chart for Kubernetes supporting standalone and master-replica architectures.

## Features

- Standalone and replication modes
- Security-hardened configuration
- Persistent storage with PVC support
- Configurable health probes
- Resource presets and custom resource management
- Network policies support
- Pod Security Standards compliance

## Prerequisites

- Kubernetes 1.29+
- Helm 3.2.0+
- PV Provisioner (for persistence)

## Installation

### Quick Start

```bash
# Standalone mode
helm install redis-standalone oci://ghcr.io/m-amaresh/helm-charts/redis

# Replication mode with authentication
helm install redis-replication oci://ghcr.io/m-amaresh/helm-charts/redis \
  --set architecture=replication \
  --set auth.enabled=true \
  --set auth.password="$(openssl rand -base64 32)" \
  --set replica.count=3
```

See [EXAMPLES.md](EXAMPLES.md) for detailed configuration examples.

## Configuration

Key configuration parameters are defined in `values.yaml`. For detailed parameter documentation, see the values file.

### Architecture Modes

- `architecture: standalone` - Single Redis instance
- `architecture: replication` - Master-replica setup with configurable replica count

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `architecture` | Redis deployment mode | `standalone` |
| `auth.enabled` | Enable password authentication | `false` |
| `auth.password` | Redis password | `""` |
| `redis.persistence.enabled` | Enable persistent storage | `true` |
| `redis.persistence.size` | Storage size | `8Gi` |
| `redis.resourcesPreset` | Resource preset (nano/micro/small/medium/large/xlarge/2xlarge) | `nano` |
| `replica.count` | Number of replicas (replication mode) | `1` |
| `networkPolicy.policies` | Network policies | `[]` |

## Security

The chart implements comprehensive security features:

- **Authentication**: Password-based authentication with secure secret management
- **Pod Security Standards**: Compliant with restricted profile (non-root, read-only filesystem, dropped capabilities)
- **Network Policies**: Configurable network-level access control
- **RBAC**: Minimal service account with least-privilege principle
- **Hardened Configuration**: Dangerous Redis commands disabled by default

### Basic Security Setup

```bash
# Enable authentication
helm install my-redis oci://ghcr.io/m-amaresh/helm-charts/redis --set auth.enabled=true --set auth.password="$(openssl rand -base64 32)"

# Create external secret
kubectl create secret generic redis-auth --from-literal=password="$(openssl rand -base64 32)"
helm install my-redis oci://ghcr.io/m-amaresh/helm-charts/redis --set auth.enabled=true --set auth.existingSecret=redis-auth
```

## Connecting to Redis

### Standalone Mode

```bash
# From within Kubernetes
kubectl exec -it my-redis-0 -- redis-cli

# With authentication
kubectl exec -it my-redis-0 -- redis-cli -a <password>
```

### Replication Mode

```bash
# Connect to master
kubectl exec -it my-redis-master-0 -- redis-cli

# Connect to replica
kubectl exec -it my-redis-replica-0 -- redis-cli
```

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
helm uninstall my-redis
```

## Additional Documentation

- **[EXAMPLES.md](EXAMPLES.md)** - Detailed configuration examples for various deployment scenarios

## License

This chart is licensed under the Apache License 2.0.

## Legal Notice

This chart is not affiliated with or endorsed by Redis Ltd. Redis is a trademark of Redis Ltd.
