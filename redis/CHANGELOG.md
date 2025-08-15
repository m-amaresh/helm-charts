# Redis Chart Changelog

All notable changes to the Redis chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-08-15

### Added
- Initial release of Redis Helm chart
- Two deployment architectures:
  - **Standalone**: Single Redis instance for development/testing
  - **Replication**: Master-replica setup for production
- Single StatefulSet architecture (simplified from complex master/replica separation)
- Horizontal Pod Autoscaler (HPA) support for replication mode
- Security features:
  - Non-root containers with security contexts
  - Read-only root filesystem
  - Dropped capabilities (ALL)
  - Pod Security Standards compliance
- Resource management:
  - Resource presets (nano to 2xlarge)
  - Configurable persistence with PVCs
  - Pod Disruption Budgets
- Authentication:
  - Optional Redis AUTH password
  - Existing secret integration
- Networking:
  - Service account with minimal permissions
  - Network policies (optional)
  - Headless and regular services
- Professional documentation and legal disclaimers

### Dependencies
- `common` chart v1.0.0 for reusable templates

### Configuration
- Redis 8.2.0-alpine as default image
- Authentication disabled by default
- Persistence enabled by default with 8Gi storage
- Resource preset: "small" by default
- Kubernetes 1.31+ required

### Security
- 🔒 Non-root user (UID 1001)
- 🔒 Read-only root filesystem
- 🔒 All capabilities dropped
- 🔒 Security context enforcement
- 🔒 Service account with minimal permissions

---

## Legend

- 🆕 **Added** for new features
- 🔄 **Changed** for changes in existing functionality  
- 🗑️ **Deprecated** for soon-to-be removed features
- ❌ **Removed** for now removed features
- 🐛 **Fixed** for any bug fixes
- 🔒 **Security** for vulnerability fixes
