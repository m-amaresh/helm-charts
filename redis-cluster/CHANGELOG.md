# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-08-15

### Added

- Initial release of Redis Cluster Helm chart
- Support for Redis cluster mode with configurable number of nodes (minimum 6)
- Automatic cluster initialization via Kubernetes Job
- Redis authentication support with password and existing secret options
- Persistent storage configuration with PVC templates
- Production-ready security contexts (non-root user, read-only filesystem)
- Comprehensive health checks (startup, readiness, and liveness probes)
- Anti-affinity rules for high availability deployment
- Service discovery with headless service for cluster communication
- Gossip protocol support on dedicated port (16379)
- Network policies support for enhanced security
- Resource management with preset configurations
- Configurable Redis configuration via ConfigMap
- Support for custom labels, annotations, and node selectors
- Integration with common chart library for consistent patterns
- Detailed deployment notes and connection instructions

### Security
- 🔒 Non-root user (UID 1001)
- 🔒 Read-only root filesystem
- 🔒 All capabilities dropped
- 🔒 Security context enforcement
- 🔒 Service account with minimal permissions

### Configuration

- Configurable cluster size and replica count
- Persistent volume claim templates for data persistence
- Service type configuration (ClusterIP, NodePort, LoadBalancer)
- Resource presets (small, medium, large) with custom override support
- Pod affinity and anti-affinity rules
- Tolerations and node selector support
- Custom volume mounts and sidecars support

---

## Legend

- 🆕 **Added** for new features
- 🔄 **Changed** for changes in existing functionality  
- 🗑️ **Deprecated** for soon-to-be removed features
- ❌ **Removed** for now removed features
- 🐛 **Fixed** for any bug fixes
- 🔒 **Security** for vulnerability fixes
