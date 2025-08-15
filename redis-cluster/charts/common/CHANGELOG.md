# Common Chart Changelog

All notable changes to the Common library chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-15

### Added
- Initial release of common library chart
- Core Kubernetes resource helpers:
  - `_affinities.tpl` - Pod affinities and anti-affinities
  - `_capabilities.tpl` - Kubernetes API version detection
  - `_images.tpl` - Image reference utilities
  - `_labels.tpl` - Standard Kubernetes labels
  - `_names.tpl` - Resource naming conventions
  - `_resources.tpl` - Resource preset configurations
- Security templates:
  - `_contexts.tpl` - Pod and container security contexts
- Storage templates:
  - `_persistence.tpl` - PVC and storage helpers
- Utility templates:
  - `_tplvalues.tpl` - Template value rendering utilities
- Professional legal disclaimers and documentation
- Apache 2.0 licensing

### Features
- Resource presets (nano, micro, small, medium, large, xlarge, 2xlarge)
- Security-first defaults (non-root, read-only filesystem, dropped capabilities)
- Kubernetes API version compatibility checks
- Standardized labeling and naming conventions
- Reusable PVC and storage configurations

### Security
- Non-root container defaults
- Read-only root filesystem enforcement
- Capability dropping (ALL capabilities removed by default)
- Pod Security Standards compliance
- Secure default security contexts

---

## Legend

- 🆕 **Added** for new features
- 🔄 **Changed** for changes in existing functionality  
- 🗑️ **Deprecated** for soon-to-be removed features
- ❌ **Removed** for now removed features
- 🐛 **Fixed** for any bug fixes
- 🔒 **Security** for vulnerability fixes
